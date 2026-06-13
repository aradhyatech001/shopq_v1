<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\ProductInfo;
use App\Models\ProductHighlight;
use App\Models\ProductImage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Storage;

class VendorProductController extends Controller
{
    // ── GET /vendor/products ──────────────────────────
    public function index(Request $request)
    {
        $vendor   = $request->user();
        $products = Product::with(['category:id,name', 'variants'])
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
        $product = Product::with(['category:id,name', 'variants'])
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

        $subColNew = Schema::hasColumn('products', 'subcategory_id');
        $subColOld = Schema::hasColumn('products', 'sub_category_id');
        $subId     = $data['subcategory_id'] ?? $data['sub_category_id'] ?? null;

        $createData = [
            'vendor_id'        => $vendor->id,
            'name'             => $data['name'],
            'description'      => $data['description'] ?? '',
            'main_category_id' => $data['main_category_id'],
            'types'            => $data['types'] ?? '',
            'is_active'        => 1,
        ];

        if ($subId) {
            if ($subColNew) $createData['subcategory_id']  = $subId;
            if ($subColOld) $createData['sub_category_id'] = $subId;
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

        $subColNew = Schema::hasColumn('products', 'subcategory_id');
        $subColOld = Schema::hasColumn('products', 'sub_category_id');
        if (isset($data['subcategory_id'])) {
            if ($subColNew) $updateData['subcategory_id']  = $data['subcategory_id'];
            if ($subColOld) $updateData['sub_category_id'] = $data['subcategory_id'];
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
            $fileName  = uniqid() . '_' . $file->getClientOriginalName();
            $path      = $file->storeAs('uploads', $fileName, 'public');
            ProductImage::create(['product_id' => $product->id, 'image_url' => $path]);
        } elseif ($request->has('data') && $request->has('name')) {
            $path = 'products/' . $request->input('name');
            Storage::disk('public')->put($path, base64_decode($request->input('data')));
            $product->images()->create(['image_url' => $path]);
        } else {
            return response()->json(['success' => false, 'message' => 'Missing image or upload data']);
        }

        return response()->json(['success' => true, 'message' => 'Image uploaded']);
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
    public function orders(Request $request)
    {
        $vendor = $request->user();

        // Get orders that contain at least one product belonging to this vendor
        $orders = \App\Models\Order::with(['items.product', 'user:id,name,email'])
            ->whereHas('items', function ($q) use ($vendor) {
                $q->whereHas('product', fn($pq) => $pq->where('vendor_id', $vendor->id));
            })
            ->orderByDesc('id')
            ->get()
            ->map(function ($order) use ($vendor) {
                // Only include items for this vendor
                $vendorItems = $order->items->filter(
                    fn($item) => $item->product?->vendor_id == $vendor->id
                );
                return [
                    'id'           => $order->id,
                    'status'       => $order->status,
                    'total'        => $vendorItems->sum(fn($i) => $i->price * $i->quantity),
                    'created_at'   => $order->order_datetime,
                    'user'         => ['name' => $order->user?->name, 'email' => $order->user?->email],
                    'items'        => $vendorItems->map(fn($i) => [
                        'product_name' => $i->product?->name,
                        'quantity'     => $i->quantity,
                        'price'        => $i->price,
                    ])->values()->toArray(),
                ];
            });

        return response()->json(['success' => true, 'orders' => $orders]);
    }

    // ── POST /vendor/orders/update-status ─────────────
    public function updateOrderStatus(Request $request)
    {
        $vendor   = $request->user();
        $orderId  = (int) $request->input('order_id');
        $status   = (string) $request->input('status');

        $allowed = ['pending', 'confirmed', 'out_for_delivery', 'delivered', 'cancelled'];
        if (!in_array($status, $allowed, true)) {
            return response()->json(['success' => false, 'message' => 'Invalid status']);
        }

        // Vendor may only act on an order that contains one of their products.
        $order = \App\Models\Order::where('id', $orderId)
            ->whereHas('items', fn($q) => $q->whereHas('product',
                fn($pq) => $pq->where('vendor_id', $vendor->id)))
            ->first();

        if (!$order) return response()->json(['success' => false, 'message' => 'Order not found']);

        $order->update(['status' => $status]);

        return response()->json(['success' => true, 'message' => 'Order status updated', 'status' => $status]);
    }

    // ── Helper ────────────────────────────────────────
    private function formatProduct($p): array
    {
        return [
            'id'               => $p->id,
            'name'             => $p->name,
            'description'      => $p->description,
            'main_category_id' => $p->main_category_id,
            'subcategory_id'   => Schema::hasColumn('products', 'subcategory_id') ? $p->subcategory_id : $p->sub_category_id,
            'category_name'    => $p->category?->name,
            'types'            => $p->types,
            'is_active'        => $p->is_active,
            // Variants with explicit field names the form expects.
            'variants'         => ProductVariant::where('product_id', $p->id)->get()->map(fn($v) => [
                'id'              => $v->id,
                'name'            => $v->name,
                'price'           => $v->price,
                'selling_price'   => $v->selling_price,
                'wholesale_price' => $v->wholesale_price,
                'stock'           => $v->stock,
            ])->toArray(),
            'highlights'       => ProductHighlight::where('product_id', $p->id)
                ->get(['id', 'attribute', 'value'])->toArray(),
            'info'             => ProductInfo::where('product_id', $p->id)
                ->get(['id', 'attribute', 'value'])->toArray(),
            // Full /api/files/ URLs — these pass through Laravel's CORS middleware
            // (unlike the static /storage/ path), so they load on Flutter web where
            // images are painted to canvas. syncImages() strips the prefix on save.
            'images'           => $p->images()->pluck('image_url')
                ->map(fn($u) => $this->imageUrl($u))->toArray(),
        ];
    }
}
