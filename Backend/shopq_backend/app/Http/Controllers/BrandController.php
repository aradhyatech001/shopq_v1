<?php

namespace App\Http\Controllers;

use App\Models\Brand;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class BrandController extends Controller
{
    // ── PUBLIC ────────────────────────────────────────────────────

    /** GET /brands — active brands for the storefront. */
    public function index()
    {
        $brands = Brand::where('is_active', 1)
            ->orderBy('position')->orderBy('id')
            ->get()
            ->map(fn($b) => $this->row($b));

        return response()->json(['success' => true, 'data' => $brands]);
    }

    /** GET /brands/{id}/products — products of one brand (pincode-aware). */
    public function products(Request $request, int $id)
    {
        $brand = Brand::find($id);
        if (!$brand) {
            return response()->json(['success' => false, 'message' => 'Brand not found'], 404);
        }

        $pc = app(ProductController::class);
        $products = Product::with([
                'category:id,name,image', 'subcategory:id,name', 'brand:id,name,image',
                'variants', 'info', 'highlights', 'images',
            ])
            ->visible()
            ->servingPincode($this->resolvePincodeId($request))
            ->where('brand_id', $id)
            ->orderByDesc('id')
            ->get()
            ->map(fn($p) => $pc->buildProductResponse($p));

        return response()->json([
            'success'  => true,
            'brand'    => $this->row($brand),
            'products' => $products,
        ]);
    }

    // ── ADMIN ─────────────────────────────────────────────────────

    /** GET /admin/brands — all brands (incl. inactive). */
    public function adminIndex()
    {
        $brands = Brand::orderBy('position')->orderBy('id')->get()
            ->map(fn($b) => $this->row($b));
        return response()->json(['success' => true, 'data' => $brands]);
    }

    /** POST /admin/brands/add */
    public function add(Request $request)
    {
        $name = trim($request->input('name', ''));
        if ($name === '') {
            return response()->json(['success' => false, 'message' => 'Name is required']);
        }

        $brand = Brand::create([
            'name'      => $name,
            'image'     => $this->storeImage($request),
            'is_active' => 1,
            'position'  => (int) $request->input('position', (Brand::max('position') ?? 0) + 1),
        ]);

        return response()->json(['success' => true, 'message' => 'Brand added', 'data' => $this->row($brand)]);
    }

    /** POST /admin/brands/edit */
    public function edit(Request $request)
    {
        $brand = Brand::find($request->input('id'));
        if (!$brand) {
            return response()->json(['success' => false, 'message' => 'Brand not found'], 404);
        }

        $brand->name = trim($request->input('name', $brand->name));
        if ($request->filled('position')) {
            $brand->position = (int) $request->input('position');
        }
        $newImage = $this->storeImage($request);
        if ($newImage) {
            if ($brand->image) Storage::disk('public')->delete($brand->image);
            $brand->image = $newImage;
        }
        $brand->save();

        return response()->json(['success' => true, 'message' => 'Brand updated', 'data' => $this->row($brand)]);
    }

    /** POST /admin/brands/toggle */
    public function toggle(Request $request)
    {
        $brand = Brand::find($request->input('id'));
        if (!$brand) {
            return response()->json(['success' => false, 'message' => 'Brand not found'], 404);
        }
        $brand->update(['is_active' => $brand->is_active ? 0 : 1]);
        return response()->json(['success' => true, 'is_active' => $brand->is_active]);
    }

    /** POST /admin/brands/reorder — body: { brands: [{id, position}, …] } */
    public function reorder(Request $request)
    {
        foreach ($request->input('brands', []) as $item) {
            if (isset($item['id'])) {
                Brand::where('id', $item['id'])->update(['position' => (int) ($item['position'] ?? 0)]);
            }
        }
        return response()->json(['success' => true]);
    }

    /** POST /admin/brands/delete — unlinks products, then deletes. */
    public function delete(Request $request)
    {
        $brand = Brand::find($request->input('id'));
        if (!$brand) {
            return response()->json(['success' => false, 'message' => 'Brand not found'], 404);
        }
        Product::where('brand_id', $brand->id)->update(['brand_id' => null]);
        if ($brand->image) Storage::disk('public')->delete($brand->image);
        $brand->delete();

        return response()->json(['success' => true, 'message' => 'Brand deleted']);
    }

    // ── Helpers ───────────────────────────────────────────────────

    private function row(Brand $b): array
    {
        return [
            'id'             => $b->id,
            'name'           => $b->name,
            'image'          => $this->imageUrl($b->image),
            'is_active'      => $b->is_active,
            'position'       => $b->position,
            'products_count' => $b->products()->count(),
        ];
    }

    /** Accepts base64 `data` + `filename` (same as the other admin uploads). */
    private function storeImage(Request $request): ?string
    {
        if ($request->filled('data') && $request->filled('filename')) {
            $path = 'brands/' . $request->input('filename');
            Storage::disk('public')->put($path, base64_decode($request->input('data')));
            return $path;
        }
        return null;
    }
}
