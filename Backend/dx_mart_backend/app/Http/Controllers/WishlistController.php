<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Wishlist;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\ProductInfo;
use App\Models\ProductHighlight;
use App\Models\ProductImage;
use App\Models\MainCategory;

class WishlistController extends Controller
{
    public function add(Request $request)
    {
        $userId    = (int) $request->input('user_id', 0);
        $productId = (int) $request->input('product_id', 0);
        if (!$userId || !$productId) return response()->json(['success' => false, 'message' => 'Missing parameters']);

        Wishlist::firstOrCreate(['user_id' => $userId, 'product_id' => $productId]);
        return response()->json(['success' => true, 'message' => 'Added to wishlist']);
    }

    public function check(Request $request)
    {
        $userId    = (int) $request->query('user_id', 0);
        $productId = (int) $request->query('product_id', 0);
        if (!$userId || !$productId) return response()->json(['success' => false, 'message' => 'Missing parameters']);

        $exists = Wishlist::where('user_id', $userId)->where('product_id', $productId)->exists();
        return response()->json(['success' => true, 'is_wishlisted' => $exists]);
    }

    public function get(Request $request)
    {
        $userId = (int) $request->query('user_id', 0);
        $page   = max(1, (int) $request->query('page', 1));
        $limit  = max(1, (int) $request->query('limit', 10));
        if (!$userId) return response()->json(['success' => false, 'message' => 'User ID required']);

        $offset = ($page - 1) * $limit;
        $total  = Wishlist::where('user_id', $userId)->count();

        $wishlistItems = Wishlist::where('user_id', $userId)
            ->with(['product.category:id,name', 'product.variants', 'product.info', 'product.highlights', 'product.images'])
            ->orderByDesc('id')->skip($offset)->take($limit)->get();

        $products = $wishlistItems->map(function ($w) {
            $p = $w->product;
            return [
                'wishlist_id'        => $w->id,
                'id'                 => $p->id,
                'name'               => $p->name,
                'description'        => $p->description,
                'type'               => $p->types,
                'main_category_id'   => $p->main_category_id,
                'main_category_name' => $p->category->name ?? null,
                'variants'           => $p->variants->toArray(),
                'info'               => $p->info->map(fn($i) => ['attribute' => $i->attribute, 'value' => $i->value])->toArray(),
                'highlights'         => $p->highlights->map(fn($h) => ['attribute' => $h->attribute, 'value' => $h->value])->toArray(),
                'images'             => $p->images->map(fn($i) => $this->imageUrl($i->image_url))->toArray(),
            ];
        });

        return response()->json(['success' => true, 'total' => $total, 'page' => $page, 'limit' => $limit, 'products' => $products]);
    }

    public function remove(Request $request)
    {
        $userId    = (int) $request->input('user_id', 0);
        $productId = (int) $request->input('product_id', 0);
        if (!$userId || !$productId) return response()->json(['success' => false, 'message' => 'Missing parameters']);

        Wishlist::where('user_id', $userId)->where('product_id', $productId)->delete();
        return response()->json(['success' => true, 'message' => 'Removed from wishlist']);
    }
}
