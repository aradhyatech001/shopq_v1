<?php
namespace App\Http\Controllers;

use App\Models\HomeTab;
use App\Models\MainCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class HomeTabController extends Controller
{
    /** GET /home-tabs — public, returns active tabs with category info */
    public function view()
    {
        $tabs = HomeTab::where('is_active', 1)
            ->orderBy('position')
            ->get()
            ->map(function ($tab) {
                return [
                    'id'           => $tab->id,
                    'name'         => $tab->name,
                    'icon'         => $tab->icon,
                    'icon_image'   => $this->imageUrl($tab->icon_image),
                    'type'         => $tab->type,
                    'category_id'  => $tab->category_id,
                    'bg_color'     => $tab->bg_color,
                    'banner_image' => $this->imageUrl($tab->banner_image),
                    'position'     => $tab->position,
                ];
            });

        return response()->json(['success' => true, 'data' => $tabs]);
    }

    /** GET /home-tabs/all — admin, returns all tabs (active + inactive) */
    public function viewAll()
    {
        $tabs = HomeTab::with('category:id,name')
            ->orderBy('position')
            ->get()
            ->map(function ($tab) {
                return [
                    'id'            => $tab->id,
                    'name'          => $tab->name,
                    'icon'          => $tab->icon,
                    'icon_image'    => $this->imageUrl($tab->icon_image),
                    'type'          => $tab->type,
                    'category_id'   => $tab->category_id,
                    'category_name' => $tab->category->name ?? null,
                    'bg_color'      => $tab->bg_color,
                    'banner_image'  => $this->imageUrl($tab->banner_image),
                    'position'      => $tab->position,
                    'is_active'     => $tab->is_active,
                ];
            });

        return response()->json(['success' => true, 'data' => $tabs]);
    }

    /** POST /home-tabs/add */
    public function add(Request $request)
    {
        $name       = trim($request->input('name', ''));
        $icon       = trim($request->input('icon', 'shopping_bag'));
        $type       = $request->input('type', 'category');
        $categoryId = $request->input('category_id');
        $bgColor    = trim($request->input('bg_color', '#6C63FF'));
        $position   = (int) $request->input('position', HomeTab::max('position') + 1);

        if (!$name) {
            return response()->json(['success' => false, 'message' => 'Name is required']);
        }

        $bannerPath = null;
        if ($request->has('banner_data') && $request->has('banner_name')) {
            $bannerPath = 'tabs/' . $request->input('banner_name');
            Storage::disk('public')->put($bannerPath, base64_decode($request->input('banner_data')));
        }

        $tab = HomeTab::create([
            'name'         => $name,
            'icon'         => $icon,
            'icon_image'   => $this->storeIcon($request),
            'type'         => $type,
            'category_id'  => $categoryId ?: null,
            'bg_color'     => $bgColor,
            'banner_image' => $bannerPath,
            'position'     => $position,
            'is_active'    => 1,
        ]);

        return response()->json(['success' => true, 'message' => 'Tab added', 'data' => $tab]);
    }

    /** POST /home-tabs/edit */
    public function edit(Request $request)
    {
        $id  = $request->input('id');
        $tab = HomeTab::find($id);
        if (!$tab) {
            return response()->json(['success' => false, 'message' => 'Tab not found']);
        }

        $updates = [
            'name'        => trim($request->input('name', $tab->name)),
            'icon'        => trim($request->input('icon', $tab->icon)),
            'type'        => $request->input('type', $tab->type),
            'category_id' => $request->input('category_id') ?: null,
            'bg_color'    => trim($request->input('bg_color', $tab->bg_color)),
            'position'    => (int) $request->input('position', $tab->position),
        ];

        if ($request->has('banner_data') && $request->has('banner_name')) {
            // Delete old banner if exists
            if ($tab->banner_image) {
                Storage::disk('public')->delete($tab->banner_image);
            }
            $bannerPath = 'tabs/' . $request->input('banner_name');
            Storage::disk('public')->put($bannerPath, base64_decode($request->input('banner_data')));
            $updates['banner_image'] = $bannerPath;
        } elseif ($request->input('remove_banner') == '1' && $tab->banner_image) {
            Storage::disk('public')->delete($tab->banner_image);
            $updates['banner_image'] = null;
        }

        // Icon image / SVG upload
        $newIcon = $this->storeIcon($request);
        if ($newIcon) {
            if ($tab->icon_image) Storage::disk('public')->delete($tab->icon_image);
            $updates['icon_image'] = $newIcon;
        } elseif ($request->input('remove_icon_image') == '1' && $tab->icon_image) {
            Storage::disk('public')->delete($tab->icon_image);
            $updates['icon_image'] = null;
        }

        $tab->update($updates);
        return response()->json(['success' => true, 'message' => 'Tab updated']);
    }

    /** Stores an uploaded tab icon (image or .svg), preserving its extension. */
    private function storeIcon(Request $request): ?string
    {
        if ($request->filled('icon_data') && $request->filled('icon_name')) {
            $orig = $request->input('icon_name');
            $ext  = pathinfo($orig, PATHINFO_EXTENSION) ?: 'png';
            $path = 'tabs/icons/' . uniqid('icon_') . '.' . strtolower($ext);
            Storage::disk('public')->put($path, base64_decode($request->input('icon_data')));
            return $path;
        }
        return null;
    }

    /** POST /home-tabs/delete */
    public function delete(Request $request)
    {
        $tab = HomeTab::find($request->input('id'));
        if (!$tab) {
            return response()->json(['success' => false, 'message' => 'Tab not found']);
        }
        $tab->delete();
        return response()->json(['success' => true, 'message' => 'Tab deleted']);
    }

    /** POST /home-tabs/toggle — flip is_active */
    public function toggle(Request $request)
    {
        $tab = HomeTab::find($request->input('id'));
        if (!$tab) {
            return response()->json(['success' => false, 'message' => 'Tab not found']);
        }
        $tab->update(['is_active' => $tab->is_active ? 0 : 1]);
        return response()->json(['success' => true, 'is_active' => $tab->is_active]);
    }

    /** POST /home-tabs/reorder — body: [{id, position}, ...] */
    public function reorder(Request $request)
    {
        $items = $request->input('tabs', []);
        foreach ($items as $item) {
            HomeTab::where('id', $item['id'])->update(['position' => (int) $item['position']]);
        }
        return response()->json(['success' => true, 'message' => 'Reordered']);
    }
}
