<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\OrderAssignment;
use App\Models\OrderStatusHistory;
use App\Models\CartItem;
use App\Models\ProductVariant;
use App\Models\DeliveryAddress;
use App\Models\User;
use App\Services\NotificationService;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    public function place(Request $request)
    {
        // all() merges JSON body and form-encoded input, so this works either way.
        $data           = $request->all();
        // Always derive the acting user from the verified Sanctum token — never
        // trust a user_id sent in the request body (IDOR prevention).
        $userId         = $request->user()->id;
        $couponCode     = $data['coupon_code'] ?? null;
        // Treat empty / literal "null" (sent by some clients when no coupon is
        // applied) as no coupon, so it isn't looked up as a real code.
        if ($couponCode === '' || strtolower((string) $couponCode) === 'null') {
            $couponCode = null;
        }
        $discountAmount = (float) ($data['discount_amount'] ?? 0);
        $deliveryCharge = (float) ($data['delivery_charge'] ?? 0);
        $handlingCharge = (float) ($data['handling_charge'] ?? 0);
        $paymentMethod  = $data['payment_method'] ?? 'COD';
        $dateTimeNow    = $data['dateTimeNow'] ?? '';
        $deliveryDate   = $data['deliveryDate'] ?? '';
        $deliverTime    = $data['deliverTime'] ?? '';
        $locationId     = (int) ($data['location_id'] ?? 0);
        $gift           = $data['gift'] ?? '';   // column is NOT NULL
        $userEmail      = $data['user_email'] ?? null;
        $userName       = $data['user_name'] ?? null;

        // $userId comes from the token; skip the redundant existence check
        // (Sanctum already guards the route; a missing user returns 401 before here).

        // Validate the delivery address (orders.location_id has an FK to
        // delivery_address). A stale/missing address id would 500 otherwise.
        $validAddress = $locationId
            ? DeliveryAddress::where('id', $locationId)->where('user_id', $userId)->exists()
            : false;
        if (!$validAddress) {
            return response()->json(['success' => false, 'code' => 'no_address', 'message' => 'Please select a delivery address.']);
        }

        // Fetch cart — LEFT JOIN so items without a variant (or null variant_id) are included.
        // `price` = selling price (what the line is sold at, stored on order_items).
        // `mrp`   = original price (struck-through), used for the items subtotal so the
        //           discount line isn't double-counted in the final amount.
        $cartItems = DB::select("
            SELECT c.product_id, c.variant_id, c.quantity, c.image_url,
                   COALESCE(v.selling_price, v.price, 0) AS price,
                   COALESCE(v.price, v.selling_price, 0)  AS mrp,
                   p.name as product_name, p.vendor_id AS vendor_id
            FROM cart_items c
            LEFT JOIN product_variants v ON c.variant_id = v.id
            JOIN products p ON c.product_id = p.id
            WHERE c.user_id = ?
        ", [$userId]);

        if (empty($cartItems)) {
            return response()->json(['success' => false, 'message' => 'Cart is empty']);
        }

        // ── Pricing inputs (computed once, then frozen) ────────────
        // mrp subtotal  → total_amount (struck-through reference)
        // selling subtotal per vendor → settlement weights
        // The frontend's `discount_amount` bundles MRP→selling savings AND any
        // coupon. Coupon-only ₹ = discount_amount − MRP savings; that is the
        // amount actually allocated across vendors as the coupon pool.
        $cartTotal       = 0;   // MRP subtotal
        $sellingSubtotal = 0;   // selling subtotal (all vendors)
        $vendorTotals    = [];  // vendor_id (0 = platform) => selling subtotal
        $items           = [];
        foreach ($cartItems as $row) {
            $r    = (array) $row;
            $qty  = (int) $r['quantity'];
            $line = (float) $r['price'] * $qty;
            $cartTotal       += (float) $r['mrp'] * $qty;
            $sellingSubtotal += $line;
            $vid = $r['vendor_id'] ?: 0;
            $vendorTotals[$vid] = ($vendorTotals[$vid] ?? 0) + $line;
            $items[] = $r;
        }

        $mrpSavings     = max(0, $cartTotal - $sellingSubtotal);
        $couponDiscount = max(0, $discountAmount - $mrpSavings); // coupon-only ₹

        // ── H4: Validate coupon min_amount before applying ─────────
        if ($couponCode) {
            // Match the coupon the same way CouponController@validate does:
            // case-insensitive code_name + expiry check. (`status` is a
            // visibility type like "Public", NOT a 1/0 active flag.)
            $coupon = \App\Models\Coupon::whereRaw('LOWER(code_name) = ?', [strtolower($couponCode)])->first();
            $expired = false;
            if ($coupon) {
                try {
                    $expired = \Carbon\Carbon::createFromFormat('d-m-Y', $coupon->expri_date)
                        ->endOfDay()->isPast();
                } catch (\Throwable $e) {
                    $expired = false;
                }
            }
            if (!$coupon || $expired) {
                return response()->json(['success' => false, 'message' => 'Invalid or expired coupon.']);
            }
            $minAmt = (float) ($coupon->min_amount ?? 0);
            if ($minAmt > 0 && $sellingSubtotal < $minAmt) {
                return response()->json([
                    'success' => false,
                    'message' => 'Minimum order value of ₹' . number_format($minAmt, 0) . ' required for this coupon.',
                ]);
            }
        }

        // ── Freeze the settlement (largest-remainder split) ────────
        $settlement  = \App\Services\SettlementService::freeze(
            $vendorTotals, $couponDiscount, $deliveryCharge, $handlingCharge
        );
        $finalAmount = $settlement['grand_total']; // whole-rupee grand total

        // ── Frozen coupon snapshot (immune to later coupon changes) ─
        $couponTitle = null; $couponType = null; $couponValue = 0;
        if ($couponCode) {
            $c = \App\Models\Coupon::where('code_name', $couponCode)->first();
            if ($c) { $couponTitle = $c->title; $couponType = 'percent'; $couponValue = (float) $c->discount; }
        }

        // Insert order
        $order = Order::create([
            'user_id'         => $userId,
            'total_amount'    => $cartTotal,
            'coupon_code'     => $couponCode,
            'coupon_title'    => $couponTitle,
            'coupon_type'     => $couponType,
            'coupon_value'    => $couponValue,
            'coupon_discount' => $settlement['coupon_discount'],
            'discount_amount' => $discountAmount,
            'delivery_charge' => $deliveryCharge,
            'handling_charge' => $handlingCharge,
            'final_amount'    => $finalAmount,
            'settlement_frozen' => true,
            'status'          => 'pending',
            'payment_method'  => $paymentMethod,
            'payment_status'  => 'pending',
            'order_datetime'  => $dateTimeNow,
            'ordered_at'      => now(),
            'delivery_date'   => $deliveryDate,
            'delivery_time'   => $deliverTime,
            'location_id'     => $locationId,
            'gift'            => $gift,
        ]);

        // ── Multi-vendor: create one sub-order each, carrying its frozen
        // settlement shares. Platform (vid 0) items have no sub-order; their
        // value is reflected in the grand total but collected by the platform.
        $defaultCommission = (float) (\App\Models\AppSetting::where('key', 'platform_commission_rate')->value('value') ?? 0);

        $vendorOrderIds = []; // vendor_id => vendor_order id
        foreach ($vendorTotals as $vid => $subtotal) {
            if ($vid == 0) continue;
            $s = $settlement['vendors'][$vid];
            // Commission is taken on net goods value only (delivery/handling are
            // platform's money even though the rider collects them).
            $rate       = \App\Models\Vendor::where('id', $vid)->value('commission_rate');
            $rate       = $rate !== null ? (float) $rate : $defaultCommission;
            $netGoods   = $s['goods_subtotal'] - $s['coupon_share'];
            $commission = (int) round($netGoods * $rate / 100);
            $vendorOrderIds[$vid] = \App\Models\VendorOrder::create([
                'parent_order_id'   => $order->id,
                'vendor_id'         => $vid,
                'status'            => 'pending',
                'items_subtotal'    => $subtotal,
                'goods_subtotal'    => $s['goods_subtotal'],
                'coupon_share'      => $s['coupon_share'],
                'delivery_share'    => $s['delivery_share'],
                'handling_share'    => $s['handling_share'],
                'collect_amount'    => $s['collect_amount'],
                'payment_status'    => 'pending',
                'commission_rate'   => $rate,
                'commission_amount' => $commission,
                'vendor_earning'    => $netGoods - $commission,
            ])->id;
        }

        // Order items (tagged to their vendor sub-order) + stock decrement.
        foreach ($items as $item) {
            $vid = $item['vendor_id'] ?: null;
            OrderItem::create([
                'order_id'        => $order->id,
                'vendor_order_id' => $vid ? ($vendorOrderIds[$vid] ?? null) : null,
                'product_id'      => $item['product_id'],
                'vendor_id'       => $vid,
                'variant_id'      => $item['variant_id'],
                'quantity'        => $item['quantity'],
                'price'           => $item['price'],      // selling_price at time of order
                'image_url'       => $item['image_url'],
            ]);
            DB::statement("UPDATE product_variants SET stock = stock - ? WHERE id = ? AND stock >= ?",
                [$item['quantity'], $item['variant_id'], $item['quantity']]);
        }

        // Parent derived status starts at pending; record creation in history.
        \App\Models\OrderStatusHistory::create([
            'parent_order_id' => $order->id,
            'actor_type'      => 'customer',
            'actor_id'        => $userId,
            'from_status'     => null,
            'to_status'       => 'pending',
            'note'            => 'Order placed',
            'created_at'      => now(),
        ]);

        // Clear cart
        CartItem::where('user_id', $userId)->delete();

        // Dispatch email in a queue job so SMTP latency doesn't block checkout.
        \App\Jobs\SendOrderConfirmationEmail::dispatch(
            $order->id, $items, $userName, $userEmail,
            $discountAmount, $deliveryCharge, $handlingCharge, $finalAmount, $cartTotal
        );

        // Notify each vendor of their new order (push + inbox; best-effort).
        $notifier = app(\App\Services\NotificationService::class);
        foreach (array_keys($vendorOrderIds) as $vid) {
            $vendor = \App\Models\Vendor::find($vid);
            if ($vendor) {
                $notifier->notify(
                    $vendor,
                    'new_order',
                    'New order received',
                    "You have a new order #{$order->id}.",
                    ['order_id' => (string) $order->id, 'deeplink' => 'shopq://order'],
                );
            }
        }

        return response()->json([
            'success'      => true,
            'message'      => 'Order placed successfully',
            'order_id'     => $order->id,
            'final_amount' => $finalAmount,
        ]);
    }

    // N+1 fix: batch-load all items for all orders in two queries instead of N+1.
    private function fetchOrdersWithItems($query)
    {
        $orders = $query->get();
        if ($orders->isEmpty()) return collect();

        $orderIds = $orders->pluck('id')->toArray();

        // Single query for all items across all orders in this page/set.
        $rawItems = DB::select("
            SELECT oi.order_id, oi.id AS order_item_id, oi.product_id, p.name AS product_name,
                   oi.variant_id, pv.name AS variant_name, pv.price, pv.selling_price, pv.stock,
                   oi.quantity, oi.image_url,
                   (SELECT pi.image_url FROM product_images pi
                      WHERE pi.product_id = oi.product_id ORDER BY pi.id ASC LIMIT 1) AS product_image
            FROM order_items oi
            JOIN products p ON oi.product_id = p.id
            LEFT JOIN product_variants pv ON oi.variant_id = pv.id
            WHERE oi.order_id IN (" . implode(',', array_fill(0, count($orderIds), '?')) . ")
        ", $orderIds);

        // Group items by order_id.
        $grouped = [];
        foreach ($rawItems as $it) {
            $raw = !empty($it->image_url) ? $it->image_url : ($it->product_image ?? '');
            $it->image_url = $this->imageUrl($raw);
            $it->image     = $it->image_url;
            $grouped[$it->order_id][] = $it;
        }

        return $orders->map(function ($order) use ($grouped) {
            $address = $order->address;
            return [
                'order' => array_merge($order->toArray(), [
                    'name'         => $address->name ?? null,
                    'phone'        => $address->phone ?? null,
                    'full_address' => $address->full_address ?? null,
                    'pin_code'     => $address->pin_code ?? null,
                    'landmark'     => $address->landmark ?? null,
                ]),
                'items' => $grouped[$order->id] ?? [],
            ];
        });
    }

    public function getByUser(Request $request)
    {
        $userId = $request->user()->id;

        $query  = Order::with('address')->where('user_id', $userId)->orderByDesc('id');
        $orders = $this->fetchOrdersWithItems($query);

        if ($orders->isEmpty()) return response()->json(['success' => false, 'message' => 'No orders found']);
        return response()->json(['success' => true, 'orders' => $orders]);
    }

    public function getAll(Request $request)
    {
        $page   = max(1, (int) $request->query('page', 1));
        $limit  = max(1, (int) $request->query('limit', 10));
        $total  = Order::count();
        $pages  = (int) ceil($total / $limit);

        $query  = Order::with('address')->orderByDesc('id')->skip(($page - 1) * $limit)->take($limit);
        $orders = $this->fetchOrdersWithItems($query);

        if ($orders->isEmpty()) {
            return response()->json(['success' => false, 'message' => 'No orders found',
                'pagination' => ['current_page' => $page, 'total_pages' => $pages, 'total_orders' => $total]]);
        }
        return response()->json(['success' => true, 'orders' => $orders,
            'pagination' => ['current_page' => $page, 'total_pages' => $pages, 'total_orders' => $total,
                'has_next' => $page < $pages, 'has_prev' => $page > 1, 'limit' => $limit]]);
    }

    public function getAllDashboard()
    {
        $query  = Order::with('address')->orderByDesc('id')->limit(200);
        $orders = $this->fetchOrdersWithItems($query);

        // Use the indexed ordered_at DATETIME column (added in migration 000003).
        // Falls back to 0 gracefully for old rows that haven't been backfilled.
        $todayRow = DB::select("
            SELECT COALESCE(SUM(final_amount), 0) AS total
            FROM orders
            WHERE DATE(ordered_at) = CURDATE()
        ");
        $todaySales = (float) ($todayRow[0]->total ?? 0);

        $weeklySales = DB::select("
            SELECT DATE(ordered_at) as sale_date, SUM(final_amount) as total_sales
            FROM orders
            WHERE ordered_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
            GROUP BY sale_date
            ORDER BY sale_date ASC
        ");

        return response()->json([
            'success'   => true,
            'orders'    => $orders,
            'dashboard' => [
                'today_sales'  => $todaySales,
                'weekly_sales' => array_map(fn($r) => ['date' => $r->sale_date, 'sales' => (float) $r->total_sales], $weeklySales),
            ],
        ]);
    }

    // ── POST /orders/{id}/cancel (auth:sanctum) ───────
    public function cancel(Request $request, int $id)
    {
        $order = Order::find($id);
        if (!$order) return response()->json(['success' => false, 'message' => 'Order not found'], 404);
        if ($order->user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $status = strtolower($order->status);
        if (in_array($status, ['delivered', 'cancelled'], true)) {
            return response()->json(['success' => false, 'message' => "Cannot cancel an order that is '$status'"]);
        }
        if (!in_array($status, ['pending', 'confirmed'], true)) {
            return response()->json(['success' => false, 'message' => 'Order can only be cancelled before it is packed']);
        }

        DB::transaction(function () use ($order, $request) {
            // Restore stock for every item.
            $items = OrderItem::where('order_id', $order->id)->get();
            foreach ($items as $item) {
                if ($item->variant_id) {
                    DB::statement("UPDATE product_variants SET stock = stock + ? WHERE id = ?",
                        [$item->quantity, $item->variant_id]);
                }
            }

            // Cancel all non-terminal vendor sub-orders.
            \App\Models\VendorOrder::where('parent_order_id', $order->id)
                ->whereNotIn('status', ['delivered', 'cancelled'])
                ->update(['status' => 'cancelled', 'cancelled_at' => now()]);

            $order->update(['status' => 'cancelled', 'payment_status' => 'refund_pending']);

            \App\Models\OrderStatusHistory::create([
                'parent_order_id' => $order->id,
                'actor_type'      => 'customer',
                'actor_id'        => $request->user()->id,
                'from_status'     => $order->getOriginal('status'),
                'to_status'       => 'cancelled',
                'note'            => 'Cancelled by customer',
                'created_at'      => now(),
            ]);
        });

        return response()->json(['success' => true, 'message' => 'Order cancelled successfully']);
    }

    // ── GET /admin/orders/{id}/settlement (auth:admin) ─
    public function getSettlement(int $id)
    {
        $order = Order::with(['vendorOrders.vendor:id,name,shop_name', 'vendorOrders.items.product:id,name'])->find($id);
        if (!$order) return response()->json(['success' => false, 'message' => 'Order not found'], 404);

        $vendorBreakdown = $order->vendorOrders->map(function ($vo) {
            return [
                'vendor_order_id'   => $vo->id,
                'vendor_id'         => $vo->vendor_id,
                'vendor_name'       => $vo->vendor?->shop_name ?: $vo->vendor?->name,
                'status'            => $vo->status,
                'items_subtotal'    => (float) $vo->items_subtotal,
                'goods_subtotal'    => (float) $vo->goods_subtotal,
                'coupon_share'      => (float) $vo->coupon_share,
                'delivery_share'    => (float) $vo->delivery_share,
                'handling_share'    => (float) $vo->handling_share,
                'collect_amount'    => (float) $vo->collect_amount,
                'commission_rate'   => (float) $vo->commission_rate,
                'commission_amount' => (float) $vo->commission_amount,
                'vendor_earning'    => (float) $vo->vendor_earning,
                'payment_status'    => $vo->payment_status,
                'cod_collected'     => (float) ($vo->cod_collected_amount ?? 0),
                'payout_id'         => $vo->payout_id,
            ];
        });

        return response()->json([
            'success'   => true,
            'order_id'  => $order->id,
            'summary'   => [
                'total_amount'    => (float) $order->total_amount,
                'discount_amount' => (float) $order->discount_amount,
                'coupon_code'     => $order->coupon_code,
                'coupon_discount' => (float) $order->coupon_discount,
                'delivery_charge' => (float) $order->delivery_charge,
                'handling_charge' => (float) $order->handling_charge,
                'final_amount'    => (float) $order->final_amount,
                'payment_method'  => $order->payment_method,
                'payment_status'  => $order->payment_status,
            ],
            'vendors'   => $vendorBreakdown,
            'platform'  => [
                'delivery_charge'  => (float) $order->delivery_charge,
                'handling_charge'  => (float) $order->handling_charge,
                'total_commission' => $vendorBreakdown->sum('commission_amount'),
            ],
        ]);
    }

    public function updateStatus(Request $request)
    {
        $orderId   = (int) $request->input('order_id', 0);
        $newStatus = strtolower($request->input('status', ''));
        if (!$orderId || !$newStatus) return response()->json(['success' => false, 'message' => 'Missing order_id or status']);

        $order = Order::find($orderId);
        if (!$order) return response()->json(['success' => false, 'message' => 'Order not found']);

        $oldStatus = strtolower($order->status);
        if ($oldStatus === $newStatus) return response()->json(['success' => true, 'message' => "Order status is already '$newStatus'"]);

        $items = OrderItem::where('order_id', $orderId)->get();
        foreach ($items as $item) {
            if ($newStatus === 'cancelled' && $oldStatus !== 'cancelled') {
                DB::statement("UPDATE product_variants SET stock = stock + ? WHERE id = ?", [$item->quantity, $item->variant_id]);
            } elseif ($oldStatus === 'cancelled' && $newStatus !== 'cancelled') {
                DB::statement("UPDATE product_variants SET stock = stock - ? WHERE id = ? AND stock >= ?", [$item->quantity, $item->variant_id, $item->quantity]);
            }
        }

        $order->update(['status' => $newStatus]);

        OrderStatusHistory::create([
            'parent_order_id' => $order->id,
            'vendor_order_id' => null,
            'actor_type'      => 'admin',
            'actor_id'        => null,
            'from_status'     => $oldStatus,
            'to_status'       => $newStatus,
            'note'            => 'Status updated by admin',
            'created_at'      => now(),
        ]);

        // Notify the customer (best-effort).
        $user = User::find($order->user_id);
        if ($user) {
            $label = ucwords(str_replace('_', ' ', $newStatus));
            app(NotificationService::class)->notify(
                $user,
                'order_update',
                'Order Update',
                "Your order #{$order->id} is now: {$label}.",
                ['order_id' => (string) $order->id, 'status' => $newStatus,
                 'deeplink' => "shopq://order/{$order->id}"]
            );
        }

        return response()->json(['success' => true, 'message' => 'Order status updated successfully with stock adjustment']);
    }

    // ── GET /orders/{id}/history (auth:sanctum) ────────
    // Returns the status-change audit log for the order.
    public function getHistory(Request $request, int $id)
    {
        $order = Order::find($id);
        if (!$order) return response()->json(['success' => false, 'message' => 'Order not found'], 404);
        if ($order->user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $history = OrderStatusHistory::where('parent_order_id', $id)
            ->orderBy('created_at')
            ->get()
            ->map(fn($h) => [
                'from_status' => $h->from_status,
                'to_status'   => $h->to_status,
                'actor_type'  => $h->actor_type,
                'note'        => $h->note,
                'created_at'  => $h->created_at,
            ]);

        return response()->json(['success' => true, 'history' => $history]);
    }

    public function getSalesReport()
    {
        $rows = DB::select("
            SELECT o.id AS order_id, o.order_datetime, o.status,
                   p.id AS product_id, p.name AS product_name,
                   v.id AS variant_id, v.name AS variant_name, v.price, v.selling_price
            FROM orders o
            JOIN order_items oi ON o.id = oi.order_id
            JOIN products p ON oi.product_id = p.id
            LEFT JOIN product_variants v ON oi.variant_id = v.id
            ORDER BY o.order_datetime DESC
        ");

        $orders = [];
        foreach ($rows as $row) {
            $oid = $row->order_id;
            if (!isset($orders[$oid])) {
                $orders[$oid] = ['order_id' => $oid, 'order_datetime' => $row->order_datetime, 'status' => $row->status, 'items' => []];
            }
            $orders[$oid]['items'][] = [
                'product_id' => $row->product_id, 'product_name' => $row->product_name,
                'variant_id' => $row->variant_id, 'variant_name' => $row->variant_name,
                'price' => $row->price, 'selling_price' => $row->selling_price,
            ];
        }

        if (empty($orders)) return response()->json(['success' => false, 'message' => 'No orders found']);
        return response()->json(['success' => true, 'orders' => array_values($orders)]);
    }

    public function assign(Request $request)
    {
        $orderId       = (int) $request->input('order_id');
        $deliveryBoyId = (int) $request->input('delivery_boy_id');
        $dateTime      = $request->input('date_time');
        if (!$orderId || !$deliveryBoyId || !$dateTime) {
            return response()->json(['success' => false, 'message' => 'All fields are required']);
        }
        // Legacy assignment record (used by admin panel order list).
        OrderAssignment::create(['order_id' => $orderId, 'delivery_boy_id' => $deliveryBoyId, 'date_time' => $dateTime]);

        // Also stamp every vendor_order in this parent order so the delivery app
        // (which reads vendor_orders.delivery_boy_id) shows the assignment.
        \App\Models\VendorOrder::where('parent_order_id', $orderId)
            ->whereNotIn('status', ['delivered', 'cancelled'])
            ->update(['delivery_boy_id' => $deliveryBoyId]);

        // Notify the delivery boy of the new assignment (push + inbox).
        $rider = \App\Models\DeliveryBoy::find($deliveryBoyId);
        if ($rider) {
            app(\App\Services\NotificationService::class)->notify(
                $rider,
                'new_assignment',
                'New delivery assigned',
                "Order #{$orderId} has been assigned to you.",
                ['order_id' => (string) $orderId, 'deeplink' => 'shopq://order'],
            );
        }

        return response()->json(['success' => true, 'message' => 'Order assignment successful']);
    }

    public function fetchDeliveryOrders(Request $request)
    {
        $deliveryBoyId = (int) $request->query('delivery_boy_id', 0);
        if ($deliveryBoyId < 1) return response()->json(['success' => false, 'message' => 'Invalid delivery boy ID']);

        $page   = max(1, (int) $request->query('page', 1));
        $limit  = max(1, (int) $request->query('limit', 10));
        $offset = ($page - 1) * $limit;

        $total  = OrderAssignment::where('delivery_boy_id', $deliveryBoyId)->count();
        $pages  = (int) ceil($total / $limit);

        $assignments = DB::select("
            SELECT o.*, da.name, da.phone, da.full_address, da.pin_code, da.landmark, oa.date_time as assigned_date
            FROM order_assignment oa
            JOIN orders o ON oa.order_id = o.id
            LEFT JOIN delivery_address da ON o.location_id = da.id
            WHERE oa.delivery_boy_id = ?
            ORDER BY oa.date_time DESC
            LIMIT ? OFFSET ?
        ", [$deliveryBoyId, $limit, $offset]);

        if (empty($assignments)) {
            return response()->json(['success' => false, 'message' => 'No orders found for this delivery boy',
                'pagination' => ['current_page' => $page, 'total_pages' => $pages, 'total_orders' => $total]]);
        }

        $orders = array_map(function ($order) {
            $items = DB::select("
                SELECT oi.id AS order_item_id, oi.product_id, p.name AS product_name,
                       oi.variant_id, pv.*, oi.quantity, oi.image_url
                FROM order_items oi
                JOIN products p ON oi.product_id = p.id
                LEFT JOIN product_variants pv ON oi.variant_id = pv.id
                WHERE oi.order_id = ?
            ", [$order->id]);
            return ['order' => $order, 'items' => $items];
        }, $assignments);

        return response()->json(['success' => true, 'orders' => $orders,
            'pagination' => ['current_page' => $page, 'total_pages' => $pages, 'total_orders' => $total,
                'has_next' => $page < $pages, 'has_prev' => $page > 1, 'limit' => $limit]]);
    }

    // ── GET /orders/{id} (auth:sanctum) ──────────────
    public function getSingle(Request $request, int $id)
    {
        $order = Order::with(['items.product', 'items.variant', 'address'])->find($id);

        if (!$order) {
            return response()->json(['success' => false, 'message' => 'Order not found']);
        }

        // Users can only see their own orders
        if ($order->user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        return response()->json([
            'success' => true,
            'order'   => $this->fetchOrdersWithItems(
                Order::where('id', $id)
            )[0] ?? null,
        ]);
    }

    // ── GET /delivery-boys (admin) ────────────────────
    public function getDeliveryBoys(Request $request)
    {
        $boys = DB::table('delivery_boy')
            ->select('id', 'name', 'email', 'mobile', 'status')
            ->orderBy('name')
            ->get();

        return response()->json(['success' => true, 'data' => $boys]);
    }
}
