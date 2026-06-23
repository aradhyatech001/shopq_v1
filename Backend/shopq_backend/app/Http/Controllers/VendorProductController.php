<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\ProductInfo;
use App\Models\ProductHighlight;
use App\Models\ProductImage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class VendorProductController extends Controller
{
    // ── GET /vendor/products ──────────────────────────
    public function index(Request $request)
    {
        $vendor   = $request->user();
        // Eager-load all relationships up-front to avoid N+1 in formatProduct().
        $products = Product::with(['category:id,name', 'variants', 'highlights', 'info', 'images'])
            ->where('vendor_id', $vendor->id)
            ->orderByDesc('id')
            ->get()
            ->map(fn($p) => $this->formatProduct($p));

        return response()->json(['success' => true, 'products' => $products]);
    }

    // ── GET /vendor/products/single?product_id= ──────
    public function single(Request $request)
    {
        $vendor  = $request->user();
        $product = Product::with(['category:id,name', 'variants', 'highlights', 'info', 'images'])
            ->where('id', $request->query('product_id'))
            ->where('vendor_id', $vendor->id)
            ->first();

        if (!$product) return response()->json(['success' => false, 'message' => 'Product not found']);

        return response()->json(['success' => true, 'product' => $this->formatProduct($product)]);
    }

    // ── POST /vendor/products/insert ─────────────────
    public function insert(Request $request)
    {
        $vendor = $request->user();

        // Check active subscription
        if (!$vendor->hasActiveSubscription()) {
            return response()->json(['success' => false, 'message' => 'Active subscription required to add products']);
        }

        $data = $request->json()->all();
        if (empty($data['name']) || empty($data['main_category_id'])) {
            return response()->json(['success' => false, 'message' => 'name and main_category_id required']);
        }

        $subId = $data['subcategory_id'] ?? $data['sub_category_id'] ?? null;

        $createData = [
            'vendor_id'        => $vendor->id,
            'name'             => $data['name'],
            'description'      => $data['description'] ?? '',
            'main_category_id' => $data['main_category_id'],
            'types'            => $data['types'] ?? '',
            'is_active'        => 1,
        ];

        if ($subId) {
            $createData['subcategory_id'] = $subId;
        }

        $product = Product::create($createData);

        // Allow variants / highlights / info to be created in the same request.
        $this->syncVariants($product->id, $data['variants'] ?? []);
        $this->syncKeyValue(ProductHighlight::class, $product->id, $data['highlights'] ?? []);
        $this->syncKeyValue(ProductInfo::class, $product->id, $data['info'] ?? []);

        return response()->json(['success' => true, 'message' => 'Product added', 'id' => $product->id]);
    }

    // ── POST /vendor/products/update ─────────────────
    public function update(Request $request)
    {
        $vendor  = $request->user();
        $data    = $request->json()->all();
        $product = Product::where('id', $data['id'] ?? 0)->where('vendor_id', $vendor->id)->first();

        if (!$product) return response()->json(['success' => false, 'message' => 'Product not found']);

        $updateData = [];
        if (isset($data['name']))             $updateData['name']             = $data['name'];
        if (isset($data['description']))      $updateData['description']      = $data['description'];
        if (isset($data['main_category_id'])) $updateData['main_category_id'] = $data['main_category_id'];
        if (isset($data['types']))            $updateData['types']            = $data['types'];

        if (isset($data['subcategory_id'])) {
            $updateData['subcategory_id'] = $data['subcategory_id'];
        }

        $product->update($updateData);

        // Batch-sync variants / highlights / info / images when provided.
        if (array_key_exists('variants', $data))   $this->syncVariants($product->id, $data['variants']);
        if (array_key_exists('highlights', $data))  $this->syncKeyValue(ProductHighlight::class, $product->id, $data['highlights']);
        if (array_key_exists('info', $data))        $this->syncKeyValue(ProductInfo::class, $product->id, $data['info']);
        if (array_key_exists('images', $data))      $this->syncImages($product->id, $data['images']);

        return response()->json(['success' => true, 'message' => 'Product updated']);
    }

    // ── Sync helpers (create / update / delete to match submitted arrays) ──

    private function syncVariants(int $productId, array $variants): void
    {
        $existingIds = ProductVariant::where('product_id', $productId)->pluck('id')->toArray();
        $keptIds     = [];
        foreach ($variants as $v) {
            $payload = [
                'name'            => $v['name'] ?? '',
                'price'           => (float) ($v['price'] ?? 0),
                'selling_price'   => (float) ($v['selling_price'] ?? 0),
                'wholesale_price' => (float) ($v['wholesale_price'] ?? 0),
                'stock'           => (int) ($v['stock'] ?? $v['stock_quantity'] ?? 0),
            ];
            if (!empty($v['id']) && in_array($v['id'], $existingIds)) {
                ProductVariant::where('id', $v['id'])->update($payload);
                $keptIds[] = $v['id'];
            } else {
                $keptIds[] = ProductVariant::create($payload + ['product_id' => $productId])->id;
            }
        }
        ProductVariant::where('product_id', $productId)
            ->whereIn('id', array_diff($existingIds, $keptIds))->delete();
    }

    private function syncKeyValue(string $model, int $productId, array $items): void
    {
        $existingIds = $model::where('product_id', $productId)->pluck('id')->toArray();
        $keptIds     = [];
        foreach ($items as $item) {
            if (empty($item['attribute'])) continue;
            $payload = ['attribute' => $item['attribute'], 'value' => $item['value'] ?? ''];
            if (!empty($item['id']) && in_array($item['id'], $existingIds)) {
                $model::where('id', $item['id'])->update($payload);
                $keptIds[] = $item['id'];
            } else {
                $keptIds[] = $model::create($payload + ['product_id' => $productId])->id;
            }
        }
        $model::where('product_id', $productId)
            ->whereIn('id', array_diff($existingIds, $keptIds))->delete();
    }

    /// Removes image rows (and files) that are no longer in the submitted list.
    /// New images are uploaded separately via uploadImage(); this only prunes.
    private function syncImages(int $productId, array $images): void
    {
        // Normalise incoming entries to relative storage paths.
        $incoming = array_map(function ($u) {
            $u = (string) $u;
            foreach (['/api/files/', '/storage/'] as $marker) {
                $pos = strpos($u, $marker);
                if ($pos !== false) return substr($u, $pos + strlen($marker));
            }
            return ltrim($u, '/');
        }, $images);

        $existing = ProductImage::where('product_id', $productId)->pluck('image_url')->toArray();
        foreach (array_diff($existing, $incoming) as $url) {
            ProductImage::where('product_id', $productId)->where('image_url', $url)->delete();
            Storage::disk('public')->delete($url);
        }
    }

    // ── POST /vendor/products/delete ─────────────────
    public function delete(Request $request)
    {
        $vendor  = $request->user();
        $id      = $request->input('id');
        $product = Product::where('id', $id)->where('vendor_id', $vendor->id)->first();

        if (!$product) return response()->json(['success' => false, 'message' => 'Product not found']);

        $images = ProductImage::where('product_id', $product->id)->pluck('image_url')->toArray();
        foreach ($images as $imageUrl) {
            Storage::disk('public')->delete($imageUrl);
        }
        ProductImage::where('product_id', $product->id)->delete();
        ProductInfo::where('product_id', $product->id)->delete();
        ProductHighlight::where('product_id', $product->id)->delete();
        ProductVariant::where('product_id', $product->id)->delete();

        $product->delete();
        return response()->json(['success' => true, 'message' => 'Product deleted']);
    }

    // ── POST /vendor/products/upload-image ───────────
    public function uploadImage(Request $request)
    {
        $vendor  = $request->user();
        $product = Product::where('id', $request->input('product_id'))->where('vendor_id', $vendor->id)->first();

        if (!$product) return response()->json(['success' => false, 'message' => 'Product not found']);

        if ($request->hasFile('image') && $request->input('product_id')) {
            $file      = $request->file('image');
            $ext       = strtolower($file->getClientOriginalExtension());
            if (!in_array($ext, ['jpg', 'jpeg', 'png', 'gif', 'webp'], true)) {
                return response()->json(['success' => false, 'message' => 'Invalid image type'], 422);
            }
            $fileName  = uniqid() . '_' . basename($file->getClientOriginalName());
            // Store under products/ (same folder ProductController uses) so all
            // product images live in one place regardless of who uploaded them.
            $path      = $file->storeAs('products', $fileName, 'public');
            ProductImage::create(['product_id' => $product->id, 'image_url' => $path]);
        } elseif ($request->has('data') && $request->has('name')) {
            // Sanitize the submitted filename: strip directory components and
            // enforce image extension (prevents path-traversal writes).
            $path = $this->safeStorePath('products', $request->input('name'));
            if (!$path) {
                return response()->json(['success' => false, 'message' => 'Invalid image file type'], 422);
            }
            Storage::disk('public')->put($path, base64_decode($request->input('data')));
            $product->images()->create(['image_url' => $path]);
        } else {
            return response()->json(['success' => false, 'message' => 'Missing image or upload data']);
        }

        // Return the full, ready-to-display URL so the vendor app can render the
        // newly uploaded image without re-fetching the product list.
        return response()->json(['success' => true, 'message' => 'Image uploaded', 'image_url' => $this->imageUrl($path)]);
    }

    // ── POST /vendor/products/update-stock ───────────
    public function updateStock(Request $request)
    {
        $vendor = $request->user();
        $variantId = (int) $request->input('variant_id');
        $productId = (int) $request->input('product_id');

        if ($variantId > 0) {
            $variant = ProductVariant::where('id', $variantId)
                ->whereHas('product', fn($q) => $q->where('vendor_id', $vendor->id))
                ->first();
            if (!$variant) {
                return response()->json(['success' => false, 'message' => 'Variant not found']);
            }
            $variant->update(['stock' => (int) $request->input('stock', $variant->stock)]);
            return response()->json(['success' => true, 'message' => 'Variant stock updated']);
        }

        if ($productId > 0) {
            $product = Product::where('id', $productId)->where('vendor_id', $vendor->id)->first();
            if (!$product) {
                return response()->json(['success' => false, 'message' => 'Product not found']);
            }
            $product->update(['is_active' => (int) $request->input('is_active', $product->is_active)]);
            return response()->json(['success' => true, 'message' => 'Product stock status updated']);
        }

        return response()->json(['success' => false, 'message' => 'variant_id or product_id required']);
    }

    // ── GET /vendor/products/low-stock (auth:vendor) ──
    // Returns variants with stock <= threshold (default 5).
    public function lowStock(Request $request)
    {
        $vendor    = $request->user();
        $threshold = max(1, (int) $request->query('threshold', 5));

        $rows = DB::select("
            SELECT p.id AS product_id, p.name AS product_name, p.image_url,
                   pv.id AS variant_id, pv.name AS variant_name, pv.stock
            FROM product_variants pv
            JOIN products p ON pv.product_id = p.id
            WHERE p.vendor_id = ? AND pv.stock <= ? AND p.is_active = 1
            ORDER BY pv.stock ASC
        ", [$vendor->id, $threshold]);

        return response()->json([
            'success'   => true,
            'threshold' => $threshold,
            'count'     => count($rows),
            'items'     => array_map(fn($r) => [
                'product_id'   => $r->product_id,
                'product_name' => $r->product_name,
                'image_url'    => $this->imageUrl($r->image_url),
                'variant_id'   => $r->variant_id,
                'variant_name' => $r->variant_name,
                'stock'        => (int) $r->stock,
            ], $rows),
        ]);
    }

    public function updateType(Request $request)
    {
        $vendor = $request->user();
        $product = Product::where('id', $request->input('id'))->where('vendor_id', $vendor->id)->first();
        if (!$product) return response()->json(['success' => false, 'message' => 'Product not found']);

        $product->update(['types' => $request->input('type', '')]);
        return response()->json(['success' => true, 'message' => 'Product type updated']);
    }

    public function saveVariant(Request $request)
    {
        $vendor = $request->user();
        $product = Product::where('id', $request->input('product_id'))->where('vendor_id', $vendor->id)->first();
        if (!$product) return response()->json(['success' => false, 'message' => 'Product not found']);

        $name          = $request->input('name');
        $price         = $request->input('price');
        $sellingPrice  = $request->input('selling_price');

        if (!$name || $price === null || $sellingPrice === null) {
            return response()->json(['success' => false, 'message' => 'Missing fields']);
        }

        ProductVariant::create([
            'product_id'      => $product->id,
            'name'            => $name,
            'price'           => (float) $price,
            'selling_price'   => (float) $sellingPrice,
            'wholesale_price' => (float) $request->input('wholesale_price', 0),
            'stock'           => (int) $request->input('stock_quantity', 0),
        ]);

        return response()->json(['success' => true]);
    }

    public function saveHighlight(Request $request)
    {
        $vendor = $request->user();
        $product = Product::where('id', $request->input('product_id'))->where('vendor_id', $vendor->id)->first();
        if (!$product) return response()->json(['success' => false, 'message' => 'Product not found']);

        $attribute = $request->input('attribute');
        $value     = $request->input('value');
        if (!$attribute || !$value) {
            return response()->json(['success' => false, 'message' => 'Missing fields']);
        }

        ProductHighlight::create(['product_id' => $product->id, 'attribute' => $attribute, 'value' => $value]);
        return response()->json(['success' => true]);
    }

    public function saveInfo(Request $request)
    {
        $vendor = $request->user();
        $product = Product::where('id', $request->input('product_id'))->where('vendor_id', $vendor->id)->first();
        if (!$product) return response()->json(['success' => false, 'message' => 'Product not found']);

        $attribute = $request->input('attribute');
        $value     = $request->input('value');
        if (!$attribute || !$value) {
            return response()->json(['success' => false, 'message' => 'Missing fields']);
        }

        ProductInfo::create(['product_id' => $product->id, 'attribute' => $attribute, 'value' => $value]);
        return response()->json(['success' => true]);
    }

    // ── GET /vendor/orders ────────────────────────────
    // Returns this vendor's SUB-orders only (each vendor sees just their shop).
    public function orders(Request $request)
    {
        $vendor = $request->user();

        $orders = \App\Models\VendorOrder::with([
                'parent.user:id,name,email', 'parent.address',
                'items.product:id,name', 'items.product.images:id,product_id,image_url',
                'items.variant:id,name,price,selling_price',
            ])
            ->where('vendor_id', $vendor->id)
            ->orderByDesc('id')
            ->get()
            ->map(function ($vo) {
                $addr = $vo->parent?->address;
                return [
                    'id'              => $vo->id,                 // sub-order id
                    'parent_order_id' => $vo->parent_order_id,
                    'status'          => $vo->status,
                    // Frozen settlement — the vendor's authoritative figure.
                    'collect_amount'  => (int) $vo->collect_amount,
                    'total'           => (int) $vo->collect_amount, // headline = collect
                    'goods_subtotal'  => (int) $vo->goods_subtotal,
                    'coupon_share'    => (int) $vo->coupon_share,
                    'delivery_share'  => (int) $vo->delivery_share,
                    'handling_share'  => (int) $vo->handling_share,
                    'commission_amount' => (float) $vo->commission_amount,
                    'vendor_earning'  => (float) $vo->vendor_earning,
                    'payment_method'  => $vo->parent?->payment_method,
                    'payment_status'  => $vo->payment_status,
                    // Coupon (code + this vendor's discount impact only).
                    'coupon'          => $vo->parent?->coupon_code ? [
                        'code'    => $vo->parent->coupon_code,
                        'title'   => $vo->parent->coupon_title,
                        'impact'  => (int) $vo->coupon_share,
                    ] : null,
                    'tracking_number' => $vo->tracking_number,
                    'courier_name'    => $vo->courier_name,
                    'delivery_boy_id' => $vo->delivery_boy_id,
                    'created_at'      => $vo->parent?->order_datetime,
                    'user'            => ['name' => $vo->parent?->user?->name, 'email' => $vo->parent?->user?->email],
                    'address'         => $addr ? [
                        'name' => $addr->name, 'phone' => $addr->phone,
                        'full_address' => $addr->full_address, 'pin_code' => $addr->pin_code,
                    ] : null,
                    'items'           => $vo->items->map(function ($i) {
                        // `price` = selling price locked at order time. `mrp` = the
                        // variant's original price for the strike-through + discount.
                        $unit  = (float) $i->price;
                        $mrp   = (float) ($i->variant?->price ?? 0);
                        $disc  = ($mrp > $unit && $mrp > 0) ? round(($mrp - $unit) / $mrp * 100) : 0;
                        return [
                            'product_name' => $i->product?->name,
                            'variant_name' => $i->variant?->name,
                            'quantity'     => $i->quantity,
                            'price'        => $unit,                 // selling, per unit
                            'mrp'          => $mrp,                  // original, per unit
                            'discount'     => $disc,                 // % off
                            'line_total'   => $unit * (int) $i->quantity,
                            'image'        => $this->imageUrl($i->product?->images?->first()?->image_url),
                        ];
                    })->values()->toArray(),
                ];
            });

        return response()->json(['success' => true, 'orders' => $orders]);
    }

    /// Resolve the caller's own sub-order from a vendor_order id OR a parent order id.
    private function resolveVendorOrder($vendor, int $id): ?\App\Models\VendorOrder
    {
        return \App\Models\VendorOrder::where('vendor_id', $vendor->id)
            ->where(fn($q) => $q->where('id', $id)->orWhere('parent_order_id', $id))
            ->first();
    }

    // ── GET /vendor/dashboard ─────────────────────────
    // Summary counts for the vendor home/dashboard (admin-panel style).
    public function dashboard(Request $request)
    {
        $vendor = $request->user();
        $vid    = $vendor->id;

        $productsTotal  = Product::where('vendor_id', $vid)->count();
        $productsActive = Product::where('vendor_id', $vid)->where('is_active', 1)->count();

        // This vendor's sub-orders carry their own status + earning.
        $subs = \App\Models\VendorOrder::where('vendor_id', $vid)->get();

        $byStatus = ['pending' => 0, 'confirmed' => 0, 'packed' => 0, 'assigned' => 0, 'out_for_delivery' => 0, 'delivered' => 0, 'cancelled' => 0];
        $revenue  = 0.0;
        $pendingEarning = 0.0;
        foreach ($subs as $vo) {
            $key = strtolower((string) $vo->status);
            if (array_key_exists($key, $byStatus)) $byStatus[$key]++;
            if ($key === 'delivered') {
                $revenue += (float) $vo->vendor_earning;
                if ($vo->payout_id === null) $pendingEarning += (float) $vo->vendor_earning;
            }
        }

        $sub = $vendor->activeSubscription;

        return response()->json([
            'success' => true,
            'data'    => [
                'products_total'  => $productsTotal,
                'products_active' => $productsActive,
                'orders_total'    => $subs->count(),
                'orders_by_status'=> $byStatus,
                'revenue'         => round($revenue, 2),
                'pending_earning' => round($pendingEarning, 2),
                'subscription'    => $sub ? [
                    'plan_name'      => $sub->plan->name ?? null,
                    'end_date'       => $sub->end_date,
                    'days_remaining' => method_exists($sub, 'daysRemaining') ? $sub->daysRemaining() : null,
                ] : null,
            ],
        ]);
    }

    // ── POST /vendor/orders/update-status ─────────────
    // Acts on the vendor's OWN sub-order only and recomputes the parent status.
    public function updateOrderStatus(Request $request)
    {
        $vendor = $request->user();
        $id     = (int) ($request->input('vendor_order_id') ?? $request->input('order_id'));
        $status = (string) $request->input('status');

        $vo = $this->resolveVendorOrder($vendor, $id);
        if (!$vo) return response()->json(['success' => false, 'message' => 'Order not found']);

        [$ok, $msg] = app(\App\Services\OrderStatusService::class)
            ->setVendorOrderStatus($vo, $status, 'vendor', $vendor->id);

        if (!$ok) return response()->json(['success' => false, 'message' => $msg]);

        if ($request->filled('tracking_number') || $request->filled('courier_name')) {
            $vo->update([
                'tracking_number' => $request->input('tracking_number', $vo->tracking_number),
                'courier_name'    => $request->input('courier_name', $vo->courier_name),
            ]);
        }

        return response()->json(['success' => true, 'message' => 'Order status updated', 'status' => $vo->fresh()->status]);
    }

    // ── POST /vendor/orders/assign-delivery ───────────
    // Vendor packs then assigns a delivery boy → sub-order moves to 'assigned'.
    public function assignDelivery(Request $request)
    {
        $vendor        = $request->user();
        $id            = (int) ($request->input('vendor_order_id') ?? $request->input('order_id'));
        $deliveryBoyId = (int) $request->input('delivery_boy_id');

        $vo = $this->resolveVendorOrder($vendor, $id);
        if (!$vo) return response()->json(['success' => false, 'message' => 'Order not found']);
        if (!\Illuminate\Support\Facades\DB::table('delivery_boy')->where('id', $deliveryBoyId)->exists()) {
            return response()->json(['success' => false, 'message' => 'Delivery boy not found']);
        }

        $vo->update(['delivery_boy_id' => $deliveryBoyId]);
        app(\App\Services\OrderStatusService::class)
            ->setVendorOrderStatus($vo, 'assigned', 'vendor', $vendor->id, "Assigned delivery boy #$deliveryBoyId");

        return response()->json(['success' => true, 'message' => 'Delivery boy assigned']);
    }

    // ── GET /vendor/delivery-boys ─────────────────────
    // Hybrid: the platform pool (vendor_id NULL) + this vendor's own riders.
    public function deliveryBoys(Request $request)
    {
        $vendor = $request->user();
        $boys = \App\Models\DeliveryBoy::query()
            ->where(fn($q) => $q->whereNull('vendor_id')->orWhere('vendor_id', $vendor->id))
            ->where('status', 'active')
            ->orderBy('name')
            ->get()
            ->map(fn($b) => [
                'id' => $b->id, 'name' => $b->name, 'mobile' => $b->mobile,
                'pin_code' => $b->pin_code, 'status' => $b->status,
                'owned' => $b->vendor_id == $vendor->id, // true = this vendor's own
            ]);
        return response()->json(['success' => true, 'data' => $boys]);
    }

    // ── GET /vendor/delivery-boys/mine ────────────────
    public function myDeliveryBoys(Request $request)
    {
        $vendor = $request->user();
        $boys = \App\Models\DeliveryBoy::where('vendor_id', $vendor->id)
            ->orderByDesc('id')->get()
            ->map(fn($b) => [
                'id' => $b->id, 'name' => $b->name, 'email' => $b->email,
                'mobile' => $b->mobile, 'pin_code' => $b->pin_code, 'status' => $b->status,
            ]);
        return response()->json(['success' => true, 'data' => $boys]);
    }

    // ── POST /vendor/delivery-boys/add ────────────────
    public function addDeliveryBoy(Request $request)
    {
        $vendor = $request->user();
        return app(\App\Http\Controllers\DeliveryController::class)->createRider($request, $vendor->id);
    }

    // ── POST /vendor/delivery-boys/edit ───────────────
    // Vendor may only edit their OWN riders.
    public function editDeliveryBoy(Request $request)
    {
        $vendor = $request->user();
        $boy = \App\Models\DeliveryBoy::where('id', $request->input('id'))
            ->where('vendor_id', $vendor->id)->first();
        if (!$boy) return response()->json(['success' => false, 'message' => 'Rider not found']);
        return app(\App\Http\Controllers\DeliveryController::class)->updateRider($request, $boy);
    }

    // ── POST /vendor/delivery-boys/delete ─────────────
    public function deleteDeliveryBoy(Request $request)
    {
        $vendor = $request->user();
        $deleted = \App\Models\DeliveryBoy::where('id', $request->input('id'))
            ->where('vendor_id', $vendor->id)->delete();
        if (!$deleted) return response()->json(['success' => false, 'message' => 'Rider not found']);
        return response()->json(['success' => true, 'message' => 'Rider removed']);
    }

    // ── Helper ────────────────────────────────────────
    // All relationships are eager-loaded in index()/single() — no extra queries here.
    private function formatProduct($p): array
    {
        return [
            'id'               => $p->id,
            'name'             => $p->name,
            'description'      => $p->description,
            'main_category_id' => $p->main_category_id,
            'subcategory_id'   => $p->subcategory_id,
            'category_name'    => $p->category?->name,
            'types'            => $p->types,
            'is_active'        => $p->is_active,
            'variants'         => ($p->relationLoaded('variants') ? $p->variants : $p->variants()->get())
                ->map(fn($v) => [
                    'id'              => $v->id,
                    'name'            => $v->name,
                    'price'           => $v->price,
                    'selling_price'   => $v->selling_price,
                    'wholesale_price' => $v->wholesale_price,
                    'stock'           => $v->stock,
                ])->toArray(),
            'highlights'       => ($p->relationLoaded('highlights') ? $p->highlights : $p->highlights()->get())
                ->map(fn($h) => ['id' => $h->id, 'attribute' => $h->attribute, 'value' => $h->value])->toArray(),
            'info'             => ($p->relationLoaded('info') ? $p->info : $p->info()->get())
                ->map(fn($i) => ['id' => $i->id, 'attribute' => $i->attribute, 'value' => $i->value])->toArray(),
            // Full /api/files/ URLs pass through Laravel's CORS middleware (unlike /storage/),
            // so they render correctly on Flutter web. syncImages() strips the prefix on save.
            'images'           => ($p->relationLoaded('images') ? $p->images : $p->images()->get())
                ->pluck('image_url')->map(fn($u) => $this->imageUrl($u))->toArray(),
        ];
    }
}
