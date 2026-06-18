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
    // All wishlist routes are behind auth:sanctum. user_id always comes from
    // the verified token — never from request params (IDOR prevention).

    public function add(Request $request)
    {
        $userId    = $request->user()->id;
        $productId = (int) $request->input('product_id', 0);
        if (!$productId) return response()->json(['success' => false, 'message' => 'Missing product_id']);

        Wishlist::firstOrCreate(['user_id' => $userId, 'product_id' => $productId]);
        return response()->json(['success' => true, 'message' => 'Added to wishlist']);
    }

    public function check(Request $request)
    {
        $userId    = $request->user()->id;
        $productId = (int) $request->query('product_id', 0);
        if (!$productId) return response()->json(['success' => false, 'message' => 'Missing product_id']);

        $exists = Wishlist::where('user_id', $userId)->where('product_id', $productId)->exists();
        return response()->json(['success' => true, 'is_wishlisted' => $exists]);
    }

    public function get(Request $request)
    {
        $userId = $request->user()->id;
        $page   = max(1, (int) $request->query('page', 1));
        $limit  = max(1, (int) $request->query('limit', 10));

        $offset = ($page - 1) * $limit;
        $total  = Wishlist::where('user_id', $userId)->count();

        $wishlistItems = Wishlist::where('user_id', $userId)
            ->with(['product.category:id,name', 'product.variants', 'product.info', 'product.highlights', 'product.images'])
            ->orderByDesc('id')->skip($offset)->take($limit)->get();

        $products = $wishlistItems->map(function ($w) {
            $p = $w->product;
            return [
                'wishlist_id'        => $w->id,
                'product_id'         => $p->id,   // kept for Flutter remove() call
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
        $userId    = $request->user()->id;
        $productId = (int) $request->input('product_id', 0);
        if (!$productId) return response()->json(['success' => false, 'message' => 'Missing product_id']);

        Wishlist::where('user_id', $userId)->where('product_id', $productId)->delete();
        return response()->json(['success' => true, 'message' => 'Removed from wishlist']);
    }
}
