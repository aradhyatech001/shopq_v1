<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\MainCategory;
use App\Models\SubCategory;
use Illuminate\Support\Facades\Storage;

class CategoryController extends Controller
{
    // ── Helper ────────────────────────────────────────────────

    private function formatCategory(MainCategory $c, bool $withSubs = false, bool $includeInactiveSubs = false): array
    {
        $data = [
            'id'              => $c->id,
            'name'            => $c->name,
            'image'           => $this->imageUrl($c->image),
            'icon_url'        => $this->imageUrl($c->icon_url),
            'color_code'      => $c->color_code,
            'tab_banner_url'  => $this->imageUrl($c->tab_banner_url ?? null),
            'tab_bg_color'    => $c->tab_bg_color ?? '#F5F5F5',
            'description'     => $c->description,
            'is_active'       => $c->is_active,
            'position'        => $c->position,
            'parent_id'       => null,
        ];

        if ($withSubs) {
            $subs = $includeInactiveSubs ? $c->allSubcategories : $c->subcategories;
            $data['subcategories'] = $subs
                ->map(fn($s) => $this->formatSubcategory($s))
                ->values()
                ->toArray();
        }

        return $data;
    }

    // ── Main Category CRUD ────────────────────────────────────

    /**
     * GET /categories
     * Returns top-level (parent) categories.
     * Pass ?with_subs=1 to include subcategories array.
     */
    public function view(Request $request)
    {
        $withSubs = $request->boolean('with_subs', false);

        $query = MainCategory::topLevel()->active()->orderBy('position')->orderBy('id');

        if ($withSubs) {
            $query->with(['subcategories']);
        }

        $categories = $query->get()->map(fn($c) => $this->formatCategory($c, $withSubs));

        return response()->json($categories);
    }

    public function viewAll(Request $request)
    {
        $withSubs = $request->boolean('with_subs', false);

        $query = MainCategory::topLevel()->orderBy('position')->orderBy('id');

        if ($withSubs) {
            $query->with(['allSubcategories']);
        }

        $categories = $query->get()
            ->map(fn($c) => $this->formatCategory($c, $withSubs, true));

        return response()->json($categories);
    }

    /**
     * POST /categories/add
     */
    public function add(Request $request)
    {
        $categoryName = $request->input('category_name');
        $data         = $request->input('data');   // base64 image
        $name         = $request->input('name');   // filename

        if (!$categoryName) {
            return response()->json(['success' => false, 'message' => 'category_name is required']);
        }

        $path = null;
        if ($data && $name) {
            $path = 'categories/' . $name;
            Storage::disk('public')->put($path, base64_decode($data));
        }

        MainCategory::create([
            'name'       => $categoryName,
            'image'      => $path,
            'is_active'  => 1,
            'icon_url'   => $request->input('icon_url'),
            'color_code' => $request->input('color_code', '#FFFFFF'),
            'position'   => (int) $request->input('position', 0),
        ]);

        return response()->json(['success' => true]);
    }

    /**
     * POST /categories/edit
     */
    public function edit(Request $request)
    {
        $categoryId   = $request->input('category_id');
        $categoryName = $request->input('category_name');

        if (!$categoryId || !$categoryName) {
            return response()->json(['success' => false, 'message' => 'category_id and category_name are required']);
        }

        $category = MainCategory::find($categoryId);
        if (!$category) {
            return response()->json(['success' => false, 'message' => 'Category not found']);
        }

        $updates = ['name' => $categoryName];

        if ($request->has('data') && $request->has('name')) {
            if ($category->image) {
                Storage::disk('public')->delete($category->image);
            }
            $path = 'categories/' . $request->input('name');
            Storage::disk('public')->put($path, base64_decode($request->input('data')));
            $updates['image'] = $path;
        }

        if ($request->has('icon_url'))   $updates['icon_url']   = $request->input('icon_url');
        if ($request->has('color_code')) $updates['color_code'] = $request->input('color_code');
        if ($request->has('position'))   $updates['position']   = (int) $request->input('position');
        if ($request->has('is_active'))  $updates['is_active']  = (int) $request->input('is_active');

        $category->update($updates);
        return response()->json(['success' => true]);
    }

    /**
     * POST /categories/delete
     */
    public function delete(Request $request)
    {
        $id       = $request->input('id');
        $category = MainCategory::find($id);

        if (!$category) {
            return response()->json(['success' => false, 'message' => 'Category not found']);
        }

        if ($category->image) {
            Storage::disk('public')->delete($category->image);
        }

        $category->delete();
        return response()->json(['success' => true]);
    }

    // ── Sub Category CRUD ─────────────────────────────────────

    /**
     * GET /categories/subcategories?parent_id=X
     * Returns subcategories of a given main category.
     * Omit parent_id to get ALL subcategories.
     */
    public function getSubcategories(Request $request)
    {
        $parentId = (int) $request->query('parent_id', 0);

        $query = SubCategory::where('is_active', 1)
                    ->orderBy('position')
                    ->orderBy('id');

        if ($parentId > 0) {
            $query->where('main_category_id', $parentId);
        }

        $subs = $query->get()->map(fn($s) => $this->formatSubcategory($s));

        return response()->json(['success' => true, 'data' => $subs]);
    }

    public function getAllSubcategories(Request $request)
    {
        $parentId = (int) $request->query('parent_id', 0);

        $query = SubCategory::orderBy('position')->orderBy('id');

        if ($parentId > 0) {
            $query->where('main_category_id', $parentId);
        }

        $subs = $query->get()->map(fn($s) => $this->formatSubcategory($s));

        return response()->json(['success' => true, 'data' => $subs]);
    }

    private function formatSubcategory(SubCategory $s): array
    {
        return [
            'id'               => $s->id,
            'name'             => $s->name,
            'image'            => $this->imageUrl($s->image_url),
            'icon_url'         => $this->imageUrl($s->icon_url),
            'color_code'       => null,
            'is_active'        => $s->is_active,
            'position'         => $s->position,
            'main_category_id' => $s->main_category_id,
            // Back-compat: some clients still read parent_id.
            'parent_id'        => $s->main_category_id,
        ];
    }

    /**
     * POST /categories/subcategories/add
     */
    public function addSubcategory(Request $request)
    {
        $parentId = (int) $request->input('parent_id', 0)
                    ?: (int) $request->input('main_category_id', 0);
        $name     = trim($request->input('name', ''));

        if (!$parentId || !$name) {
            return response()->json(['success' => false, 'message' => 'parent_id and name are required']);
        }

        $parent = MainCategory::find($parentId);
        if (!$parent) {
            return response()->json(['success' => false, 'message' => 'parent_id must be a valid category']);
        }

        $path = null;
        if ($request->has('data') && $request->has('filename')) {
            $path = 'subcategories/' . $request->input('filename');
            Storage::disk('public')->put($path, base64_decode($request->input('data')));
        }

        $sub = SubCategory::create([
            'name'             => $name,
            'main_category_id' => $parentId,
            'image_url'        => $path,
            'is_active'        => 1,
            'position'         => (int) $request->input('position', 0),
        ]);

        return response()->json(['success' => true, 'id' => $sub->id, 'message' => 'Sub category added']);
    }

    /**
     * POST /categories/subcategories/edit
     */
    public function editSubcategory(Request $request)
    {
        $id   = (int) $request->input('id');
        $name = trim($request->input('name', ''));

        if (!$id || !$name) {
            return response()->json(['success' => false, 'message' => 'id and name are required']);
        }

        $sub = SubCategory::find($id);
        if (!$sub) {
            return response()->json(['success' => false, 'message' => 'Sub category not found']);
        }

        $updates = ['name' => $name];

        if ($request->has('parent_id') || $request->has('main_category_id')) {
            $updates['main_category_id'] = (int) ($request->input('main_category_id') ?: $request->input('parent_id'));
        }
        if ($request->has('position')) {
            $updates['position'] = (int) $request->input('position');
        }
        if ($request->has('is_active')) {
            $updates['is_active'] = (int) $request->input('is_active');
        }

        if ($request->has('data') && $request->has('filename')) {
            if ($sub->image_url) {
                Storage::disk('public')->delete($sub->image_url);
            }
            $path = 'subcategories/' . $request->input('filename');
            Storage::disk('public')->put($path, base64_decode($request->input('data')));
            $updates['image_url'] = $path;
        }

        $sub->update($updates);
        return response()->json(['success' => true, 'message' => 'Sub category updated']);
    }

    /**
     * POST /categories/subcategories/delete
     */
    public function deleteSubcategory(Request $request)
    {
        $id  = (int) $request->input('id');
        $sub = SubCategory::find($id);

        if (!$sub) {
            return response()->json(['success' => false, 'message' => 'Sub category not found']);
        }

        if ($sub->image_url) {
            Storage::disk('public')->delete($sub->image_url);
        }

        $sub->delete();
        return response()->json(['success' => true, 'message' => 'Sub category deleted']);
    }
}
