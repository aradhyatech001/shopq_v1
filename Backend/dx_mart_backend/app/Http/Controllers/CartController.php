<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\CartItem;
use Illuminate\Support\Facades\DB;

class CartController extends Controller
{
    public function add(Request $request)
    {
        // Use input() so this works whether the client sends JSON or form-encoded.
        $userId    = (int) $request->input('user_id', 0);
        $productId = (int) $request->input('product_id', 0);
        $variantId = $request->filled('variant_id') ? (int) $request->input('variant_id') : null;
        $quantity  = max(1, (int) $request->input('quantity', 1));
        $imageUrl  = $request->input('image_url');

        if (!$userId || !$productId) {
            return response()->json(['success' => false, 'message' => 'Missing data']);
        }

        $query = CartItem::where('user_id', $userId)->where('product_id', $productId);
        $query = $variantId ? $query->where('variant_id', $variantId) : $query->whereNull('variant_id');
        $existing = $query->first();

        if ($existing) {
            $existing->update(['quantity' => $existing->quantity + $quantity]);
            $cartItemId = $existing->id;
        } else {
            $cartItem = CartItem::create([
                'user_id'    => $userId,
                'product_id' => $productId,
                'variant_id' => $variantId,
                'quantity'   => $quantity,
                'image_url'  => $imageUrl,
            ]);
            $cartItemId = $cartItem->id;
        }
        return response()->json(['success' => true, 'message' => 'Cart updated', 'cart_id' => $cartItemId]);
    }

    public function get(Request $request)
    {
        $userId = $request->query('user_id');
        $cart   = DB::select("
            SELECT c.id, c.product_id, c.variant_id, c.quantity, c.image_url,
                   p.name, p.description,
                   v.name AS variant_name, v.price, v.selling_price, v.stock
            FROM cart_items c
            JOIN products p ON p.id = c.product_id
            LEFT JOIN product_variants v ON v.id = c.variant_id
            WHERE c.user_id = ?
        ", [$userId]);

        return response()->json(['success' => true, 'cart' => $cart]);
    }

    public function remove(Request $request)
    {
        $id = $request->query('id');
        CartItem::destroy($id);
        return response()->json(['success' => true, 'message' => 'Removed from cart']);
    }

    public function updateQuantity(Request $request)
    {
        $id       = $request->input('id');
        $quantity = $request->input('quantity', 1);
        CartItem::where('id', $id)->update(['quantity' => $quantity]);
        return response()->json(['success' => true, 'message' => 'Quantity updated']);
    }
}
