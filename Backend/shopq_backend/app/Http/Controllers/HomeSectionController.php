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
        // Only show stores/products deliverable to the user's chosen pincode.
        $pincodeId = $this->resolvePincodeId($request);

        $sections = HomeSection::where('is_active', 1)
            ->where('home_tab_id', $tabId)
            ->orderBy('position')->orderBy('id')
            ->get()
            ->map(fn($s) => $this->resolve($s, $tabCategoryId, $pincodeId))
            ->filter()
            ->values();

        return response()->json(['success' => true, 'sections' => $sections]);
    }

    /// Turns a stored section config into a render-ready payload.
    private function resolve(HomeSection $s, $tabCategoryId, int $pincodeId = 0): ?array
    {
        // A section may scope to its own category, else it inherits the tab's.
        $categoryId = $s->main_category_id ?: $tabCategoryId;

        switch ($s->section_type) {
            case 'banner':
                // New model: a banner section references one or many existing
                // banners (created in Banner Management). Fall back to the legacy
                // single uploaded image if no banner_ids were chosen.
                $bannerIds = is_array($s->banner_ids) ? $s->banner_ids : [];
                $banners   = [];
                if (!empty($bannerIds)) {
                    $rows = \App\Models\Banner::whereIn('id', $bannerIds)->where('is_active', 1)->get()
                        ->sortBy(fn($b) => array_search($b->id, $bannerIds))->values();
                    foreach ($rows as $b) {
                        $banners[] = [
                            'id'               => $b->id,
                            'banner_image'     => $this->imageUrl($b->banner_image),
                            'link_category_id' => $b->category_id,
                        ];
                    }
                } elseif ($s->banner_image) {
                    $banners[] = [
                        'id'               => null,
                        'banner_image'     => $this->imageUrl($s->banner_image),
                        'link_category_id' => $s->link_category_id,
                    ];
                }
                if (empty($banners)) return null;
                return [
                    'type'             => 'banner',
                    'title'            => $s->title,
                    // Legacy single-image keys (first banner) for older app builds.
                    'banner_image'     => $banners[0]['banner_image'],
                    'link_category_id' => $banners[0]['link_category_id'],
                    // New: full list so the app can show a carousel.
                    'banners'          => $banners,
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
                // Real brands (Lux, Parle, Amul, Tata, …). Tapping one opens
                // that brand's products in the app.
                $items = \App\Models\Brand::where('is_active', 1)
                    ->orderBy('position')->orderBy('id')
                    ->limit($s->product_limit ?: 12)->get()
                    ->map(fn($b) => [
                        'id'       => $b->id,
                        'name'     => $b->name,
                        'image'    => $this->imageUrl($b->image),
                        'is_brand' => true,
                    ])->toArray();
                return ['type' => 'brand_grid', 'title' => $s->title, 'items' => $items];

            case 'shop_grid':
                // "Shop-wise shopping" — approved vendor shops serving the
                // user's pincode (all approved shops when no pincode is set).
                $shopQuery = \App\Models\Vendor::where('status', 'approved');
                if ($pincodeId > 0) {
                    $shopQuery->whereHas('pincodes', fn($p) => $p->where('pincodes.id', $pincodeId));
                }
                $shops = $shopQuery->orderByDesc('id')->limit($s->product_limit ?: 12)->get()
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
                    ->servingPincode($pincodeId)
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
            'banner_ids'       => $this->parseBannerIds($request),
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

        // Selected banners (multi). Only overwrite when the key was sent.
        if ($request->has('banner_ids')) {
            $updates['banner_ids'] = $this->parseBannerIds($request);
        }

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

    /// Normalises banner_ids coming as a JSON string, comma list, or array
    /// into a clean array of ints (or null when none).
    private function parseBannerIds(Request $request): ?array
    {
        $raw = $request->input('banner_ids');
        if ($raw === null || $raw === '') return null;
        if (is_string($raw)) {
            $decoded = json_decode($raw, true);
            $raw = is_array($decoded) ? $decoded : explode(',', $raw);
        }
        if (!is_array($raw)) return null;
        $ids = array_values(array_filter(array_map('intval', $raw)));
        return empty($ids) ? null : $ids;
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
        $bannerIds = is_array($s->banner_ids) ? $s->banner_ids : [];
        return [
            'id'               => $s->id,
            'home_tab_id'      => $s->home_tab_id,
            'title'            => $s->title,
            'emoji'            => $s->emoji,
            'banner_image'     => $this->imageUrl($s->banner_image),
            'banner_ids'       => $bannerIds,
            'banner_count'     => count($bannerIds),
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
