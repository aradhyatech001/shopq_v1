<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\OrderAssignment;
use App\Models\CartItem;
use App\Models\ProductVariant;
use App\Models\DeliveryAddress;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;

class OrderController extends Controller
{
    public function place(Request $request)
    {
        // all() merges JSON body and form-encoded input, so this works either way.
        $data           = $request->all();
        $userId         = (int) ($data['user_id'] ?? 0);
        $couponCode     = $data['coupon_code'] ?? null;
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

        if (!$userId) return response()->json(['success' => false, 'message' => 'User ID missing']);
        if (!\App\Models\User::whereKey($userId)->exists()) {
            return response()->json(['success' => false, 'code' => 'invalid_user', 'message' => 'Session expired. Please log in again.']);
        }

        // Validate the delivery address (orders.location_id has an FK to
        // delivery_address). A stale/missing address id would 500 otherwise.
        $validAddress = $locationId
            ? DeliveryAddress::where('id', $locationId)->where('user_id', $userId)->exists()
            : false;
        if (!$validAddress) {
            return response()->json(['success' => false, 'code' => 'no_address', 'message' => 'Please select a delivery address.']);
        }

        // Fetch cart — LEFT JOIN so items without a variant (or null variant_id) are included
        $cartItems = DB::select("
            SELECT c.product_id, c.variant_id, c.quantity, c.image_url,
                   COALESCE(v.selling_price, v.price, 0) AS price,
                   p.name as product_name
            FROM cart_items c
            LEFT JOIN product_variants v ON c.variant_id = v.id
            JOIN products p ON c.product_id = p.id
            WHERE c.user_id = ?
        ", [$userId]);

        if (empty($cartItems)) {
            return response()->json(['success' => false, 'message' => 'Cart is empty']);
        }

        $cartTotal = 0;
        $items     = [];
        foreach ($cartItems as $row) {
            $cartTotal += (float) $row->price * (int) $row->quantity;
            $items[] = (array) $row;
        }

        $finalAmount = ($cartTotal - $discountAmount) + $deliveryCharge + $handlingCharge;

        // Insert order
        $order = Order::create([
            'user_id'         => $userId,
            'total_amount'    => $cartTotal,
            'coupon_code'     => $couponCode,
            'discount_amount' => $discountAmount,
            'delivery_charge' => $deliveryCharge,
            'handling_charge' => $handlingCharge,
            'final_amount'    => $finalAmount,
            'status'          => 'pending',
            'payment_method'  => $paymentMethod,
            'order_datetime'  => $dateTimeNow,
            'delivery_date'   => $deliveryDate,
            'delivery_time'   => $deliverTime,
            'location_id'     => $locationId,
            'gift'            => $gift,
        ]);

        // Order items + stock
        foreach ($items as $item) {
            OrderItem::create([
                'order_id'   => $order->id,
                'product_id' => $item['product_id'],
                'variant_id' => $item['variant_id'],
                'quantity'   => $item['quantity'],
                'price'      => $item['price'],      // selling_price at time of order
                'image_url'  => $item['image_url'],
            ]);
            DB::statement("UPDATE product_variants SET stock = stock - ? WHERE id = ? AND stock >= ?",
                [$item['quantity'], $item['variant_id'], $item['quantity']]);
        }

        // Clear cart
        CartItem::where('user_id', $userId)->delete();

        // Send emails async
        $this->sendOrderEmails($order, $items, $userName, $userEmail, $discountAmount, $deliveryCharge, $handlingCharge, $finalAmount, $cartTotal);

        return response()->json([
            'success'      => true,
            'message'      => 'Order placed successfully',
            'order_id'     => $order->id,
            'final_amount' => $finalAmount,
        ]);
    }

    private function sendOrderEmails($order, $items, $userName, $userEmail, $discount, $deliveryCharge, $handlingCharge, $finalAmount, $cartTotal)
    {
        $companyEmail = config('mail.from.address');
        $subject      = "Order Confirmation - #{$order->id}";

        $itemsHtml = '';
        foreach ($items as $item) {
            $itemsHtml .= "
                    <div style='padding:10px;border-bottom:1px solid #eee;'>
                        <p style='margin:0;'><strong>" . htmlspecialchars($item['product_name']) . "</strong></p>
                        <p style='margin:4px 0 0;'>Quantity: {$item['quantity']} × ₹" . number_format((float)$item['price'], 2) . "</p>
                    </div>";
        }

        $discountHtml = $discount > 0
            ? "<p><strong>Discount:</strong> -₹" . number_format($discount, 2) . "</p>"
            : '';

        $userBody = "
        <!DOCTYPE html>
        <html lang='en'>
        <head>
            <meta charset='UTF-8'>
            <meta name='viewport' content='width=device-width, initial-scale=1.0'>
            <title>Order Confirmation</title>
        </head>
        <body style='font-family:Arial,sans-serif;line-height:1.6;color:#333;margin:0;padding:0;background-color:#f9f9f9;'>
            <div style='max-width:600px;margin:0 auto;background-color:#ffffff;padding:20px;border:1px solid #ddd;border-radius:5px;'>
                <div style='text-align:center;padding-bottom:20px;border-bottom:1px solid #eee;'>
                    <h1 style='color:#2c3e50;margin:0;'>Order Confirmation</h1>
                </div>

                <p>Dear " . htmlspecialchars((string)$userName) . ",</p>
                <p>Thank you for your order! We are pleased to confirm that we have received your order and it is now being processed.</p>

                <div style='margin:20px 0;padding:15px;background-color:#f8f9fa;border-radius:5px;'>
                    <h2>Order Details</h2>
                    <p><strong>Order ID:</strong> <span style='background-color:#f1c40f;padding:2px 5px;border-radius:3px;'>#" . $order->id . "</span></p>
                    <p><strong>Order Date:</strong> " . $order->order_datetime . "</p>
                    <p><strong>Payment Method:</strong> " . $order->payment_method . "</p>
                    <p><strong>Delivery Date:</strong> " . $order->delivery_date . " at " . $order->delivery_time . "</p>
                </div>

                <div style='margin:20px 0;padding:15px;background-color:#f8f9fa;border-radius:5px;'>
                    <h2>Ordered Items</h2>
                    $itemsHtml
                </div>

                <div style='margin:20px 0;padding:15px;background-color:#f8f9fa;border-radius:5px;'>
                    <h2>Order Summary</h2>
                    <p><strong>Subtotal:</strong> ₹" . number_format($cartTotal, 2) . "</p>
                    $discountHtml
                    <p><strong>Delivery Charge:</strong> ₹" . number_format($deliveryCharge, 2) . "</p>
                    <p><strong>Handling Charge:</strong> ₹" . number_format($handlingCharge, 2) . "</p>
                    <div style='font-size:18px;font-weight:bold;color:#27ae60;margin-top:10px;padding-top:10px;border-top:1px solid #ddd;'>
                        <strong>Total Amount: ₹" . number_format($finalAmount, 2) . "</strong>
                    </div>
                </div>

                <p>We will notify you once your order has been shipped. If you have any questions, please contact our customer service team.</p>

                <div style='margin-top:30px;padding-top:20px;border-top:1px solid #eee;text-align:center;color:#7f8c8d;font-size:14px;'>
                    <p>Thank you for shopping with us!</p>
                    <p>© " . date('Y') . " DxMart. All rights reserved.</p>
                </div>
            </div>
        </body>
        </html>";

        $companyBody = "
        <!DOCTYPE html>
        <html lang='en'>
        <head><meta charset='UTF-8'><title>New Order</title></head>
        <body style='font-family:Arial,sans-serif;line-height:1.6;color:#333;margin:0;padding:0;'>
            <div style='max-width:600px;margin:0 auto;padding:20px;'>
                <div style='text-align:center;padding-bottom:20px;border-bottom:1px solid #eee;'>
                    <h1>New Order Received</h1>
                </div>
                <div style='margin:20px 0;padding:15px;background-color:#f8f9fa;border-radius:5px;'>
                    <h2>Order Details</h2>
                    <p><strong>Order ID:</strong> <span style='background-color:#f1c40f;padding:2px 5px;border-radius:3px;'>#" . $order->id . "</span></p>
                    <p><strong>Customer:</strong> " . htmlspecialchars((string)$userName) . " (" . htmlspecialchars((string)$userEmail) . ")</p>
                    <p><strong>Order Date:</strong> " . $order->order_datetime . "</p>
                    <p><strong>Payment Method:</strong> " . $order->payment_method . "</p>
                    <p><strong>Delivery Date:</strong> " . $order->delivery_date . " at " . $order->delivery_time . "</p>
                    <p style='color:#e74c3c;font-weight:bold;'><strong>Total Amount:</strong> ₹" . number_format($finalAmount, 2) . "</p>
                </div>
                <div style='margin:20px 0;'>
                    <h2>Ordered Items</h2>
                    $itemsHtml
                </div>
                <p>This order requires your attention. Please process it according to the delivery schedule.</p>
            </div>
        </body>
        </html>";

        try {
            if ($userEmail) {
                Mail::html($userBody, function ($msg) use ($userEmail, $subject) {
                    $msg->to($userEmail)->subject($subject);
                });
            }
            Mail::html($companyBody, function ($msg) use ($companyEmail, $order) {
                $msg->to($companyEmail)->subject("New Order #{$order->id}");
            });
        } catch (\Exception $e) {
            // Email failure should not block order
        }
    }

    private function fetchOrdersWithItems($query)
    {
        $orders = $query->get();
        return $orders->map(function ($order) {
            $address = $order->address;
            $items   = DB::select("
                SELECT oi.id AS order_item_id, oi.product_id, p.name AS product_name,
                       oi.variant_id, pv.name AS variant_name, pv.price, pv.selling_price, pv.stock,
                       oi.quantity, oi.image_url
                FROM order_items oi
                JOIN products p ON oi.product_id = p.id
                LEFT JOIN product_variants pv ON oi.variant_id = pv.id
                WHERE oi.order_id = ?
            ", [$order->id]);
            return [
                'order' => array_merge($order->toArray(), [
                    'name'         => $address->name ?? null,
                    'phone'        => $address->phone ?? null,
                    'full_address' => $address->full_address ?? null,
                    'pin_code'     => $address->pin_code ?? null,
                    'landmark'     => $address->landmark ?? null,
                ]),
                'items' => $items,
            ];
        });
    }

    public function getByUser(Request $request)
    {
        $userId = (int) $request->input('user_id', 0);
        if (!$userId) return response()->json(['success' => false, 'message' => 'User ID missing']);

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

        // order_datetime is stored as "dd-MM-yyyy hh:mm a" string — use STR_TO_DATE to parse it
        $todayRow = DB::select("
            SELECT COALESCE(SUM(final_amount), 0) AS total
            FROM orders
            WHERE DATE(STR_TO_DATE(order_datetime, '%d-%m-%Y %h:%i %p')) = CURDATE()
        ");
        $todaySales = (float) ($todayRow[0]->total ?? 0);

        $weeklySales = DB::select("
            SELECT DATE(STR_TO_DATE(order_datetime, '%d-%m-%Y %h:%i %p')) as sale_date,
                   SUM(final_amount) as total_sales
            FROM orders
            WHERE DATE(STR_TO_DATE(order_datetime, '%d-%m-%Y %h:%i %p')) >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
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
        return response()->json(['success' => true, 'message' => 'Order status updated successfully with stock adjustment']);
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
        $orderId       = $request->input('order_id');
        $deliveryBoyId = $request->input('delivery_boy_id');
        $dateTime      = $request->input('date_time');
        if (!$orderId || !$deliveryBoyId || !$dateTime) {
            return response()->json(['success' => false, 'message' => 'All fields are required']);
        }
        OrderAssignment::create(['order_id' => $orderId, 'delivery_boy_id' => $deliveryBoyId, 'date_time' => $dateTime]);
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
