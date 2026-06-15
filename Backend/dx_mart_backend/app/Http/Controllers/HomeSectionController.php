<?php

namespace App\Http\Controllers;

use App\Models\HomeSection;
use App\Models\HomeTab;
use App\Models\MainCategory;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class HomeSectionController extends Controller
{
    // ─────────────────────────────────────────────────────────────
    // PUBLIC — GET /tab-layout?tab_id=X
    // Returns the tab's active sections, fully resolved with their data,
    // so the user app just renders them top to bottom.
    // ─────────────────────────────────────────────────────────────
    public function tabLayout(Request $request)
    {
        $tabId = (int) $request->query('tab_id', 0);
        $tab   = $tabId ? HomeTab::find($tabId) : null;
        $tabCategoryId = $tab?->category_id;

        $sections = HomeSection::where('is_active', 1)
            ->where('home_tab_id', $tabId)
            ->orderBy('position')->orderBy('id')
            ->get()
            ->map(fn($s) => $this->resolve($s, $tabCategoryId))
            ->filter()
            ->values();

        return response()->json(['success' => true, 'sections' => $sections]);
    }

    /// Turns a stored section config into a render-ready payload.
    private function resolve(HomeSection $s, $tabCategoryId): ?array
    {
        // A section may scope to its own category, else it inherits the tab's.
        $categoryId = $s->main_category_id ?: $tabCategoryId;

        switch ($s->section_type) {
            case 'banner':
                if (!$s->banner_image) return null;
                return [
                    'type'             => 'banner',
                    'title'            => $s->title,
                    'banner_image'     => $this->imageUrl($s->banner_image),
                    'link_category_id' => $s->link_category_id,
                ];

            case 'category_grid':
                if ($categoryId) {
                    // Subcategories of the scoped category (from sub_category).
                    $items = \App\Models\SubCategory::where('main_category_id', $categoryId)
                        ->where('is_active', 1)->orderBy('position')->orderBy('id')
                        ->limit($s->product_limit ?: 12)->get()
                        ->map(fn($c) => [
                            'id'          => $c->id,
                            'name'        => $c->name,
                            'image'       => $this->imageUrl($c->image_url),
                            'category_id' => $c->main_category_id,
                            'is_sub'      => true,
                        ])->toArray();
                } else {
                    // Top-level categories.
                    $items = MainCategory::where('is_active', 1)
                        ->orderBy('position')->orderBy('id')
                        ->limit($s->product_limit ?: 12)->get()
                        ->map(fn($c) => [
                            'id'          => $c->id,
                            'name'        => $c->name,
                            'image'       => $this->imageUrl($c->image),
                            'category_id' => $c->id,
                            'is_sub'      => false,
                        ])->toArray();
                }
                return ['type' => 'category_grid', 'title' => $s->title, 'items' => $items];

            case 'brand_grid':
                // "Brand-wise shopping" = top-level categories acting as brands.
                $items = MainCategory::where('is_active', 1)
                    ->orderBy('position')->orderBy('id')
                    ->limit($s->product_limit ?: 12)->get()
                    ->map(fn($c) => [
                        'id'          => $c->id,
                        'name'        => $c->name,
                        'image'       => $this->imageUrl($c->image),
                        'category_id' => $c->id,
                    ])->toArray();
                return ['type' => 'brand_grid', 'title' => $s->title, 'items' => $items];

            case 'shop_grid':
                // "Shop-wise shopping" — approved vendor shops.
                $shops = \App\Models\Vendor::where('status', 'approved')
                    ->orderByDesc('id')->limit($s->product_limit ?: 12)->get()
                    ->map(fn($v) => [
                        'id'        => $v->id,
                        'shop_name' => $v->shop_name ?: $v->name,
                        'logo'      => $this->imageUrl($v->logo),
                    ])->toArray();
                if (empty($shops)) return null;
                return ['type' => 'shop_grid', 'title' => $s->title, 'items' => $shops];

            case 'product_type':
            case 'products':
            case 'brand_row':
                $q = Product::with(['category:id,name,image', 'subcategory:id,name', 'variants', 'info', 'highlights', 'images'])
                    ->visible()
                    ->where('is_active', 1);
                if ($categoryId)        $q->where('main_category_id', $categoryId);
                if ($s->subcategory_id) $q->where('subcategory_id', $s->subcategory_id);
                if ($s->brand_id)       $q->where('brand_id', $s->brand_id);
                if ($s->product_type)   $q->where('types', 'like', '%' . $s->product_type . '%');

                $products = $q->orderByDesc('id')->limit($s->product_limit ?: 10)->get()
                    ->map(fn($p) => $this->formatProductCard($p));

                if ($products->isEmpty()) return null; // hide empty rows
                return [
                    'type'         => 'product_row',
                    'title'        => $s->title,
                    'emoji'        => $s->emoji,
                    'product_type' => $s->product_type,
                    'category_id'  => $categoryId,
                    'subcategory_id' => $s->subcategory_id,
                    'products'     => $products,
                ];
        }
        return null;
    }

    /// Product shape consumed by the user app's ProductCard (mirrors
    /// ProductController::buildProductResponse).
    private function formatProductCard($p): array
    {
        $subId = $p->subcategory_id ?? ($p->sub_category_id ?? null);
        $info  = $p->info()->select('attribute', 'value')->get()->toArray();
        return [
            'id'                 => $p->id,
            'name'               => $p->name,
            'description'        => $p->description,
            'main_category_id'   => $p->main_category_id,
            'main_category_name' => $p->category?->name,
            'category_id'        => $p->main_category_id,
            'category'           => $p->category?->name,
            'subcategory_id'     => $subId,
            'sub_category_id'    => $subId,
            'subcategory_name'   => $p->subcategory?->name,
            'brand_id'           => $p->brand_id,
            'brand_name'         => $p->category?->name,
            'types'              => $p->types,
            'variants'           => $p->variants()->get()->toArray(),
            'info'               => $info,
            'highlights'         => $p->highlights()->select('attribute', 'value')->get()->toArray(),
            'images'             => $p->images()->pluck('image_url')->map(fn($u) => $this->imageUrl($u))->toArray(),
        ];
    }

    // ─────────────────────────────────────────────────────────────
    // ADMIN — CRUD for sections
    // ─────────────────────────────────────────────────────────────

    /// GET /admin/home-sections?tab_id=X — all sections of a tab (incl inactive)
    public function index(Request $request)
    {
        $tabId = (int) $request->query('tab_id', 0);
        $sections = HomeSection::where('home_tab_id', $tabId)
            ->orderBy('position')->orderBy('id')->get()
            ->map(fn($s) => $this->adminRow($s));
        return response()->json(['success' => true, 'data' => $sections]);
    }

    public function add(Request $request)
    {
        $type = $request->input('section_type', 'product_type');
        if (!in_array($type, ['banner', 'category_grid', 'brand_grid', 'shop_grid', 'product_type', 'products', 'brand_row'], true)) {
            return response()->json(['success' => false, 'message' => 'Invalid section_type']);
        }

        $section = HomeSection::create([
            'home_tab_id'      => $request->input('home_tab_id') ?: null,
            'title'            => trim($request->input('title', '')),
            'emoji'            => $request->input('emoji'),
            'banner_image'     => $this->storeBanner($request),
            'section_type'     => $type,
            'product_type'     => $request->input('product_type') ?: null,
            'main_category_id' => $request->input('main_category_id') ?: null,
            'subcategory_id'   => $request->input('subcategory_id') ?: null,
            'brand_id'         => $request->input('brand_id') ?: null,
            'link_category_id' => $request->input('link_category_id') ?: null,
            'product_limit'    => (int) $request->input('product_limit', 10),
            'position'         => (int) $request->input('position', (HomeSection::where('home_tab_id', $request->input('home_tab_id'))->max('position') ?? 0) + 1),
            'is_active'        => 1,
        ]);

        return response()->json(['success' => true, 'message' => 'Section added', 'data' => $this->adminRow($section)]);
    }

    public function edit(Request $request)
    {
        $section = HomeSection::find($request->input('id'));
        if (!$section) return response()->json(['success' => false, 'message' => 'Section not found']);

        $updates = [
            'title'            => trim($request->input('title', $section->title)),
            'emoji'            => $request->input('emoji', $section->emoji),
            'section_type'     => $request->input('section_type', $section->section_type),
            'product_type'     => $request->input('product_type', $section->product_type) ?: null,
            'main_category_id' => $request->input('main_category_id', $section->main_category_id) ?: null,
            'subcategory_id'   => $request->input('subcategory_id', $section->subcategory_id) ?: null,
            'brand_id'         => $request->input('brand_id', $section->brand_id) ?: null,
            'link_category_id' => $request->input('link_category_id', $section->link_category_id) ?: null,
            'product_limit'    => (int) $request->input('product_limit', $section->product_limit),
        ];
        $newBanner = $this->storeBanner($request);
        if ($newBanner) $updates['banner_image'] = $newBanner;

        $section->update($updates);
        return response()->json(['success' => true, 'message' => 'Section updated']);
    }

    public function delete(Request $request)
    {
        $section = HomeSection::find($request->input('id'));
        if (!$section) return response()->json(['success' => false, 'message' => 'Section not found']);
        if ($section->banner_image) Storage::disk('public')->delete($section->banner_image);
        $section->delete();
        return response()->json(['success' => true, 'message' => 'Section deleted']);
    }

    public function toggle(Request $request)
    {
        $section = HomeSection::find($request->input('id'));
        if (!$section) return response()->json(['success' => false, 'message' => 'Section not found']);
        $section->update(['is_active' => $section->is_active ? 0 : 1]);
        return response()->json(['success' => true, 'is_active' => $section->is_active]);
    }

    public function reorder(Request $request)
    {
        foreach ($request->input('sections', []) as $item) {
            HomeSection::where('id', $item['id'])->update(['position' => (int) $item['position']]);
        }
        return response()->json(['success' => true, 'message' => 'Reordered']);
    }

    private function storeBanner(Request $request): ?string
    {
        if ($request->filled('banner_data') && $request->filled('banner_name')) {
            $path = 'sections/' . $request->input('banner_name');
            Storage::disk('public')->put($path, base64_decode($request->input('banner_data')));
            return $path;
        }
        return null;
    }

    private function adminRow(HomeSection $s): array
    {
        return [
            'id'               => $s->id,
            'home_tab_id'      => $s->home_tab_id,
            'title'            => $s->title,
            'emoji'            => $s->emoji,
            'banner_image'     => $this->imageUrl($s->banner_image),
            'section_type'     => $s->section_type,
            'product_type'     => $s->product_type,
            'main_category_id' => $s->main_category_id,
            'subcategory_id'   => $s->subcategory_id,
            'brand_id'         => $s->brand_id,
            'link_category_id' => $s->link_category_id,
            'product_limit'    => $s->product_limit,
            'position'         => $s->position,
            'is_active'        => $s->is_active,
        ];
    }
}
