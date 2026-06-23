<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Banner;
use App\Models\MainCategory;
use Illuminate\Support\Facades\Storage;

class BannerController extends Controller
{
    public function add(Request $request)
    {
        $data       = $request->input('data');
        $name       = $request->input('name');
        $categoryId = $request->input('category_id');

        if (!$data || !$name || !$categoryId) {
            return response()->json(['success' => false, 'message' => 'Missing data']);
        }

        $ext    = pathinfo($name, PATHINFO_EXTENSION);
        $unique = 'banner_image_' . round(microtime(true) * 1000) . '.' . $ext;
        $path   = 'banners/' . $unique;

        Storage::disk('public')->put($path, base64_decode($data));

        Banner::create(['category_id' => $categoryId, 'banner_image' => $path, 'is_active' => 1]);
        return response()->json(['success' => true, 'filename' => $unique]);
    }

    public function view()
    {
        $banners = Banner::with('category:id,name,image')
            ->where('is_active', 1)
            ->orderByDesc('id')->get()
            ->map(fn($b) => $this->_mapBanner($b));

        return response()->json([
            'success' => true,
            'data'    => ['offer_banners' => $banners],
        ]);
    }

    public function viewAll()
    {
        $banners = Banner::with('category:id,name,image')
            ->orderByDesc('id')->get()
            ->map(fn($b) => $this->_mapBanner($b));

        $categories = MainCategory::select('id', 'name', 'image')->orderBy('name')->get();

        return response()->json([
            'success' => true,
            'data'    => ['offer_banners' => $banners, 'main_categories' => $categories],
        ]);
    }

    /** POST /banners/edit — change category and/or replace image */
    public function edit(Request $request)
    {
        $id     = $request->input('id');
        $banner = Banner::find($id);
        if (!$banner) {
            return response()->json(['success' => false, 'message' => 'Banner not found']);
        }

        $categoryId = $request->input('category_id');
        if ($categoryId) {
            $banner->category_id = $categoryId;
        }

        // Optional: replace image
        $data = $request->input('data');
        $name = $request->input('name');
        if ($data && $name) {
            Storage::disk('public')->delete($banner->banner_image);
            $ext    = pathinfo($name, PATHINFO_EXTENSION);
            $unique = 'banner_image_' . round(microtime(true) * 1000) . '.' . $ext;
            $path   = 'banners/' . $unique;
            Storage::disk('public')->put($path, base64_decode($data));
            $banner->banner_image = $path;
        }

        $banner->save();
        return response()->json(['success' => true, 'message' => 'Banner updated']);
    }

    /** POST /banners/toggle — flip is_active */
    public function toggle(Request $request)
    {
        $id     = $request->input('id');
        $banner = Banner::find($id);
        if (!$banner) {
            return response()->json(['success' => false, 'message' => 'Banner not found']);
        }
        $banner->is_active = $banner->is_active ? 0 : 1;
        $banner->save();
        return response()->json(['success' => true, 'is_active' => $banner->is_active]);
    }

    public function delete(Request $request)
    {
        $id     = $request->input('id');
        $banner = Banner::find($id);
        if (!$banner) {
            return response()->json(['success' => false, 'message' => 'Banner not found']);
        }
        Storage::disk('public')->delete($banner->banner_image);
        $banner->delete();
        return response()->json(['success' => true]);
    }

    private function _mapBanner(Banner $b): array
    {
        return [
            'id'                 => $b->id,
            'banner_image'       => $this->imageUrl($b->banner_image),
            'category_id'        => $b->category_id,
            'main_category_id'   => $b->category_id,
            'category_name'      => $b->category->name ?? null,
            'main_category_name' => $b->category->name ?? null,
            'category_image'     => $this->imageUrl($b->category->image ?? null),
            'is_active'          => (bool) $b->is_active,
        ];
    }
}
