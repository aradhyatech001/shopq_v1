<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\ProductInfo;
use App\Models\ProductHighlight;
use App\Models\ProductImage;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    /** Safely get subcategory_id — works whether or not column exists yet */
    private function getSubcategoryId($product): ?int
    {
        static $hasNew = null;
        static $hasOld = null;
        if ($hasNew === null) $hasNew = Schema::hasColumn('products', 'subcategory_id');
        if ($hasOld === null) $hasOld = Schema::hasColumn('products', 'sub_category_id');

        if ($hasNew && !empty($product->subcategory_id))  return (int) $product->subcategory_id;
        if ($hasOld && !empty($product->sub_category_id)) return (int) $product->sub_category_id;
        return null;
    }

    public function buildProductResponse($product)
    {
        $info = $product->info()->select('attribute', 'value')->get()->toArray();
        $brandInfo = collect($info)->first(function ($item) {
            return isset($item['attribute']) && strcasecmp(trim($item['attribute']), 'brand') === 0;
        });
        // Prefer the real brand (brands table); fall back to the legacy
        // "Brand" info attribute / category for products without a brand_id.
        $brandName  = $product->brand?->name ?? $brandInfo['value'] ?? null;
        $brandImage = $product->brand?->image
            ? $this->imageUrl($product->brand->image)
            : ($product->category?->image ? $this->imageUrl($product->category->image) : null);
        $subId      = $this->getSubcategoryId($product);

        $subcategoryName = $product->subcategory?->name ?? null;
        $subcategoryName = $subcategoryName ?: ($product->category?->name ?? null);

        return [
            'id'                 => $product->id,
            'name'               => $product->name,
            'description'        => $product->description,
            'main_category_id'   => $product->main_category_id,
            'main_category_name' => $product->category?->name ?? null,
            'category_id'        => $product->main_category_id,
            'category'           => $product->category?->name ?? null,
            'subcategory_id'     => $subId,
            'sub_category_id'    => $subId,   // legacy alias
            'subcategory_name'   => $product->subcategory?->name ?? null,
            'sub_category_name'  => $product->subcategory?->name ?? null,
            'subcategory'        => $subcategoryName,
            'brand_id'           => $product->brand_id ?? null,
            'brand_name'         => $brandName ?? $product->category?->name ?? null,
            'brand_image'        => $brandImage,
            'types'              => $product->types,
            'variants'           => $product->variants()->get()->toArray(),
            'info'               => $info,
            'highlights'         => $product->highlights()->select('attribute', 'value')->get()->toArray(),
            'images'             => $product->images()->pluck('image_url')
                                        ->map(fn($url) => $this->imageUrl($url))
                                        ->toArray(),
        ];
    }

    public function insert(Request $request)
    {
        $data = $request->json()->all();
        if (empty($data['name']) || empty($data['description']) || empty($data['main_category_id'])) {
            return response()->json(['success' => false, 'message' => 'Missing required fields']);
        }
        $subColNew = Schema::hasColumn('products', 'subcategory_id');
        $subColOld = Schema::hasColumn('products', 'sub_category_id');
        $subId     = $data['subcategory_id'] ?? $data['sub_category_id'] ?? null;

        $createData = [
            'name'             => $data['name'],
            'description'      => $data['description'],
            'main_category_id' => $data['main_category_id'] ?? $data['category_id'],
            'brand_id'         => $data['brand_id'] ?? null,
            'types'            => $data['types'] ?? '',
        ];
        if ($subColNew) $createData['subcategory_id']   = $subId;
        if ($subColOld) $createData['sub_category_id']  = $subId;

        $product = Product::create($createData);
        return response()->json(['success' => true, 'id' => $product->id]);
    }

    public function getAll(Request $request)
    {
        $page       = max(1, (int) $request->query('page', 1));
        $limit      = max(1, (int) $request->query('limit', 10));
        $search     = $request->query('search', '');
        $categoryId = $request->query('category_id');

        $query = Product::with(['category:id,name', 'subcategory:id,name', 'brand:id,name,image', 'variants', 'info', 'highlights', 'images'])->visible();
        $query->servingPincode($this->resolvePincodeId($request));
        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%$search%")->orWhere('description', 'like', "%$search%");
            });
        }
        if ($categoryId) $query->where('main_category_id', $categoryId);

        // Accept both 'subcategory_id' and legacy 'sub_category_id' param names
        $subcategoryId = $request->query('subcategory_id') ?? $request->query('sub_category_id');
        if ($subcategoryId) {
            if (Schema::hasColumn('products', 'subcategory_id')) {
                $query->where('subcategory_id', $subcategoryId);
            } elseif (Schema::hasColumn('products', 'sub_category_id')) {
                $query->where('sub_category_id', $subcategoryId);
            }
        }

        $total   = $query->count();
        $products = $query->orderByDesc('id')->skip(($page - 1) * $limit)->take($limit)->get()
            ->map(fn($p) => $this->buildProductResponse($p));

        return response()->json([
            'success'    => true,
            'products'   => $products,
            'total'      => $total,
            'count'      => $products->count(),
            'page'       => $page,
            'limit'      => $limit,
            'totalPages' => (int) ceil($total / $limit),
        ]);
    }

    public function getByCategory(Request $request)
    {
        $categoryId    = (int) $request->query('category_id', 0);
        // Accept both param name variants for subcategory
        $subcategoryId = (int) ($request->query('subcategory_id') ?? $request->query('sub_category_id') ?? 0);
        // Optional product type filter (matches comma-separated 'types' column)
        $type = trim($request->query('type', ''));

        $hasSubNew = Schema::hasColumn('products', 'subcategory_id');
        $hasSubOld = Schema::hasColumn('products', 'sub_category_id');

        $query = Product::with(['category:id,name,image', 'subcategory:id,name', 'brand:id,name,image', 'variants', 'info', 'highlights', 'images'])->visible();
        $query->servingPincode($this->resolvePincodeId($request));

        // category_id=0 or missing = no category filter (used for deals/all-products tabs)
        if ($categoryId > 0) {
            $query->where('main_category_id', $categoryId);
        }

        if ($subcategoryId > 0) {
            if ($hasSubNew) {
                $query->where('subcategory_id', $subcategoryId);
            } elseif ($hasSubOld) {
                $query->where('sub_category_id', $subcategoryId);
            }
        }

        if ($type !== '') {
            $query->whereRaw("FIND_IN_SET(?, types)", [$type]);
        }

        $products = $query->orderByDesc('id')
            ->get()
            ->map(fn($p) => $this->buildProductResponse($p));

        return response()->json(['success' => true, 'count' => $products->count(), 'products' => $products]);
    }

    public function getByType(Request $request)
    {
        $page   = max(1, (int) $request->query('page', 1));
        $limit  = max(1, (int) $request->query('limit', 10));
        $type   = $request->query('type', '');

        $query = Product::with(['category:id,name,image', 'brand:id,name,image', 'variants', 'info', 'highlights', 'images'])->visible();
        $query->servingPincode($this->resolvePincodeId($request));
        if ($type) $query->whereRaw("FIND_IN_SET(?, types)", [$type]);

        $total    = $query->count();
        $products = $query->orderByDesc('id')->skip(($page - 1) * $limit)->take($limit)->get()
            ->map(fn($p) => $this->buildProductResponse($p));

        return response()->json(['success' => true, 'total' => $total, 'page' => $page, 'limit' => $limit, 'products' => $products]);
    }

    public function getBySubcategory(Request $request)
    {
        $subcategoryId = (int) $request->query('subcategory_id', 0);
        $categoryId = (int) $request->query('category_id', 0);
        if ($subcategoryId <= 0 && $categoryId <= 0) {
            return response()->json(['success' => false, 'message' => 'subcategory_id or category_id required'], 400);
        }

        $query = Product::with(['category:id,name,image', 'brand:id,name,image', 'variants', 'info', 'highlights', 'images'])->visible();
        $query->servingPincode($this->resolvePincodeId($request));
        if ($subcategoryId > 0 && Schema::hasColumn('products', 'subcategory_id')) {
            $query->where('subcategory_id', $subcategoryId);
        } elseif ($categoryId > 0) {
            $query->where('main_category_id', $categoryId);
        } elseif ($subcategoryId > 0) {
            $query->where('main_category_id', $subcategoryId);
        }

        $products = $query->orderByDesc('id')->get()
            ->map(fn($p) => $this->buildProductResponse($p));

        return response()->json(['success' => true, 'products' => $products]);
    }

    public function single(Request $request)
    {
        $id = $request->query('product_id');
        if (!$id) return response()->json(['success' => false, 'message' => 'Missing product_id']);
        $product = Product::visible()->find($id);
        if (!$product) return response()->json(['success' => false, 'message' => 'Product not found']);
        return response()->json(['success' => true, 'product' => $this->buildProductResponse($product)]);
    }

    public function update(Request $request)
    {
        $data      = $request->json()->all();
        $productId = $data['id'] ?? null;
        if (!$productId) return response()->json(['success' => false, 'message' => 'Invalid or missing product ID']);

        $product = Product::find($productId);
        if (!$product) return response()->json(['success' => false, 'message' => 'Product not found']);

        $subColNew  = Schema::hasColumn('products', 'subcategory_id');
        $subColOld  = Schema::hasColumn('products', 'sub_category_id');
        $subId      = $data['subcategory_id'] ?? $data['sub_category_id'] ?? null;

        $updateData = [
            'name'             => $data['name'] ?? $product->name,
            'description'      => $data['description'] ?? $product->description,
            'main_category_id' => $data['main_category_id'] ?? $data['category_id'] ?? $product->main_category_id,
            'brand_id'         => $data['brand_id'] ?? $product->brand_id,
            'types'            => $data['types'] ?? $product->types,
        ];
        if ($subColNew) $updateData['subcategory_id']  = $subId ?? $product->subcategory_id;
        if ($subColOld) $updateData['sub_category_id'] = $subId ?? (Schema::hasColumn('products', 'sub_category_id') ? $product->sub_category_id : null);

        $product->update($updateData);

        // Variants
        $existingIds    = ProductVariant::where('product_id', $productId)->pluck('id')->toArray();
        $frontendIds    = [];
        foreach ($data['variants'] ?? [] as $v) {
            if ($v['id'] ?? null) {
                $frontendIds[] = $v['id'];
                ProductVariant::where('id', $v['id'])->update([
                    'name' => $v['name'], 'price' => $v['price'], 'selling_price' => $v['selling_price'],
                    'wholesale_price' => $v['wholesale_price'], 'stock' => $v['stock_quantity'],
                ]);
            } else {
                ProductVariant::create([
                    'product_id' => $productId, 'name' => $v['name'], 'price' => $v['price'],
                    'selling_price' => $v['selling_price'], 'wholesale_price' => $v['wholesale_price'],
                    'stock' => $v['stock_quantity'],
                ]);
            }
        }
        ProductVariant::where('product_id', $productId)->whereIn('id', array_diff($existingIds, $frontendIds))->delete();

        // Info
        $this->syncKeyValue(ProductInfo::class, $productId, $data['info'] ?? []);

        // Highlights
        $this->syncKeyValue(ProductHighlight::class, $productId, $data['highlights'] ?? []);

        // Images — reduce each submitted URL back to a relative storage path,
        // host-agnostically (the URL may use the LAN IP / a different host than
        // config('app.url'), which previously broke the match and wiped images).
        $existingImages = ProductImage::where('product_id', $productId)->pluck('image_url')->toArray();
        $incoming = array_values(array_filter(array_map(
            fn($url) => $this->relativeImagePath($url),
            $data['images'] ?? []
        )));
        // Only reconcile images when the client actually sent an `images` list.
        // (Without this guard, an update payload that omits images would treat
        // the incoming list as empty and delete every image of the product.)
        // Whatever the frontend keeps stays; anything it dropped gets removed
        // from the DB and disk. New images are added separately via uploadImage.
        if (array_key_exists('images', $data)) {
            $toDelete = array_diff($existingImages, $incoming);
            foreach ($toDelete as $url) {
                ProductImage::where('product_id', $productId)->where('image_url', $url)->delete();
                Storage::disk('public')->delete($url);
            }
        }

        return response()->json(['success' => true, 'message' => 'Product updated successfully']);
    }

    private function syncKeyValue($model, $productId, array $items)
    {
        $existingIds = $model::where('product_id', $productId)->pluck('id')->toArray();
        $frontendIds = [];
        foreach ($items as $item) {
            if ($item['id'] ?? null) {
                $frontendIds[] = $item['id'];
                $model::where('id', $item['id'])->update(['attribute' => $item['attribute'], 'value' => $item['value']]);
            } else {
                $model::create(['product_id' => $productId, 'attribute' => $item['attribute'], 'value' => $item['value']]);
            }
        }
        $model::where('product_id', $productId)->whereIn('id', array_diff($existingIds, $frontendIds))->delete();
    }

    public function delete(Request $request)
    {
        $productId = (int) $request->input('id');
        if (!$productId) return response()->json(['success' => false, 'message' => 'Product ID is required']);

        $images = ProductImage::where('product_id', $productId)->get();
        foreach ($images as $img) {
            Storage::disk('public')->delete($img->image_url);
        }
        Product::destroy($productId);
        return response()->json(['success' => true, 'message' => 'Product deleted successfully']);
    }

    public function updateStock(Request $request)
    {
        $variantId = (int) $request->input('variant_id');
        $stock     = (int) $request->input('stock');
        if (!$variantId) return response()->json(['success' => false, 'message' => 'Invalid input']);
        ProductVariant::where('id', $variantId)->update(['stock' => $stock]);
        return response()->json(['success' => true, 'message' => 'Stock updated successfully']);
    }

    public function updateType(Request $request)
    {
        $id   = $request->input('id');
        $type = $request->input('type');
        Product::where('id', $id)->update(['types' => $type]);
        return response()->json(['status' => 'success']);
    }

    // ── GET /admin/products/low-stock (auth:admin) ─────
    // Returns all active variants with stock <= threshold across all vendors.
    public function lowStock(Request $request)
    {
        $threshold = max(1, (int) $request->query('threshold', 5));

        $rows = DB::select("
            SELECT p.id AS product_id, p.name AS product_name, p.image_url,
                   p.vendor_id,
                   pv.id AS variant_id, pv.name AS variant_name, pv.stock
            FROM product_variants pv
            JOIN products p ON pv.product_id = p.id
            WHERE pv.stock <= ? AND p.is_active = 1
            ORDER BY pv.stock ASC
        ", [$threshold]);

        return response()->json([
            'success'   => true,
            'threshold' => $threshold,
            'count'     => count($rows),
            'items'     => array_map(fn($r) => [
                'product_id'   => $r->product_id,
                'product_name' => $r->product_name,
                'image_url'    => $this->imageUrl($r->image_url),
                'vendor_id'    => $r->vendor_id,
                'variant_id'   => $r->variant_id,
                'variant_name' => $r->variant_name,
                'stock'        => (int) $r->stock,
            ], $rows),
        ]);
    }

    public function uploadImage(Request $request)
    {
        if (!$request->hasFile('image') || !$request->input('product_id')) {
            return response()->json(['success' => false, 'message' => 'Missing image or product_id']);
        }
        $productId = $request->input('product_id');
        $file      = $request->file('image');
        $fileName  = uniqid() . '_' . basename($file->getClientOriginalName());
        $path      = $file->storeAs('products', $fileName, 'public');

        ProductImage::create(['product_id' => $productId, 'image_url' => $path]);
        // Return the full, ready-to-display URL (not the raw relative path) so the
        // client can show the image immediately without re-fetching the product.
        return response()->json(['success' => true, 'image_url' => $this->imageUrl($path)]);
    }

    public function saveVariant(Request $request)
    {
        $productId     = $request->input('product_id');
        $name          = $request->input('name');
        $price         = $request->input('price');
        $sellingPrice  = $request->input('selling_price');
        if (!$productId || !$name || !$price || !$sellingPrice) {
            return response()->json(['success' => false, 'message' => 'Missing fields']);
        }
        ProductVariant::create([
            'product_id'      => $productId,
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
        $productId = $request->input('product_id');
        $attribute = $request->input('attribute');
        $value     = $request->input('value');
        if (!$productId || !$attribute || !$value) {
            return response()->json(['success' => false, 'message' => 'Missing fields']);
        }
        ProductHighlight::create(['product_id' => $productId, 'attribute' => $attribute, 'value' => $value]);
        return response()->json(['success' => true]);
    }

    public function saveInfo(Request $request)
    {
        $productId = $request->input('product_id');
        $attribute = $request->input('attribute');
        $value     = $request->input('value');
        if (!$productId || !$attribute || !$value) {
            return response()->json(['success' => false, 'message' => 'Missing fields']);
        }
        ProductInfo::create(['product_id' => $productId, 'attribute' => $attribute, 'value' => $value]);
        return response()->json(['success' => true]);
    }
}
