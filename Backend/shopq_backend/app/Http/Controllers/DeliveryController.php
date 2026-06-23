<?php

namespace App\Http\Controllers;

use App\Models\DeliveryBoy;
use App\Models\VendorOrder;
use App\Services\OrderStatusService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class DeliveryController extends Controller
{
    // ── POST /delivery/login (public) ─────────────────
    // Riders are created by admin/vendor; they just log in here.
    public function login(Request $request)
    {
        $login    = trim($request->input('login', $request->input('email', '')));
        $password = $request->input('password', '');
        if (!$login || !$password) {
            return response()->json(['success' => false, 'message' => 'Email/phone and password required'], 422);
        }

        $boy = DeliveryBoy::where('email', $login)->orWhere('mobile', $login)->first();
        if (!$boy || !Hash::check($password, $boy->password)) {
            return response()->json(['success' => false, 'message' => 'Invalid credentials'], 401);
        }
        if (strtolower((string) $boy->status) === 'inactive' || strtolower((string) $boy->status) === 'blocked') {
            return response()->json(['success' => false, 'message' => 'Account is inactive. Contact admin.'], 403);
        }

        $boy->tokens()->delete();
        $token = $boy->createToken('delivery-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'token'   => $token,
            'rider'   => $this->formatRider($boy),
        ]);
    }

    // ── POST /delivery/logout ─────────────────────────
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()?->delete();
        return response()->json(['success' => true, 'message' => 'Logged out']);
    }

    // ── GET /delivery/profile ─────────────────────────
    public function profile(Request $request)
    {
        return response()->json(['success' => true, 'rider' => $this->formatRider($request->user())]);
    }

    // ── GET /delivery/orders ──────────────────────────
    // Sub-orders assigned to this rider (active first, then completed).
    public function orders(Request $request)
    {
        $rider = $request->user();
        $orders = VendorOrder::with([
                'parent.user:id,name,email', 'parent.address', 'vendor:id,shop_name,name',
                'items.product:id,name', 'items.product.images:id,product_id,image_url',
                'items.variant:id,name,price,selling_price',
            ])
            ->where('delivery_boy_id', $rider->id)
            ->orderByDesc('id')
            ->get()
            ->map(fn($vo) => $this->formatOrder($vo));

        return response()->json(['success' => true, 'orders' => $orders]);
    }

    // ── POST /delivery/orders/confirm-cod ────────────
    // Rider confirms cash collected at door. Flips payment_status to 'collected'
    // and records the exact amount handed over, so the admin can reconcile.
    public function confirmCod(Request $request)
    {
        $rider  = $request->user();
        $id     = (int) ($request->input('vendor_order_id') ?? $request->input('order_id'));
        $amount = (float) $request->input('cod_collected_amount', 0);

        if (!$id) {
            return response()->json(['success' => false, 'message' => 'vendor_order_id required'], 422);
        }

        $vo = VendorOrder::where('id', $id)->where('delivery_boy_id', $rider->id)->first();
        if (!$vo) {
            return response()->json(['success' => false, 'message' => 'Order not assigned to you'], 404);
        }

        if (strtolower((string) ($vo->parent?->payment_method)) !== 'cod') {
            return response()->json(['success' => false, 'message' => 'Not a COD order'], 422);
        }

        if (strtolower((string) $vo->payment_status) === 'collected') {
            return response()->json(['success' => true, 'message' => 'Already confirmed']);
        }

        $vo->update([
            'cod_collected_amount' => $amount,
            'payment_status'       => 'collected',
        ]);

        return response()->json(['success' => true, 'message' => 'COD collection confirmed', 'amount' => $amount]);
    }

    // ── POST /delivery/orders/update-status ───────────
    // Rider can only advance pickup → out for delivery → delivered.
    public function updateStatus(Request $request)
    {
        $rider  = $request->user();
        $id     = (int) ($request->input('vendor_order_id') ?? $request->input('order_id'));
        $status = strtolower((string) $request->input('status'));

        if (!in_array($status, ['picked_up', 'out_for_delivery', 'delivered'], true)) {
            return response()->json(['success' => false, 'message' => 'Riders can only set picked up, out for delivery or delivered'], 422);
        }

        $vo = VendorOrder::where('id', $id)->where('delivery_boy_id', $rider->id)->first();
        if (!$vo) return response()->json(['success' => false, 'message' => 'Order not assigned to you'], 404);

        [$ok, $msg] = app(OrderStatusService::class)
            ->setVendorOrderStatus($vo, $status, 'delivery', $rider->id);

        return response()->json(['success' => $ok, 'message' => $msg, 'status' => $vo->fresh()->status]);
    }

    // ── Helpers ───────────────────────────────────────
    private function formatRider(DeliveryBoy $b): array
    {
        return [
            'id'        => $b->id,
            'name'      => $b->name,
            'email'     => $b->email,
            'mobile'    => $b->mobile,
            'pin_code'  => $b->pin_code,
            'vendor_id' => $b->vendor_id,
            'status'    => $b->status,
        ];
    }

    private function formatOrder(VendorOrder $vo): array
    {
        $addr   = $vo->parent?->address;
        $method = strtoupper((string) ($vo->parent?->payment_method ?? 'COD'));
        $isCod  = $method === 'COD';
        $paid   = strtolower((string) $vo->payment_status) === 'paid'
               || strtolower((string) $vo->parent?->payment_status) === 'paid';
        // Door cash: only COD-and-unpaid collects; prepaid/online collects 0.
        // The frozen settlement figure stays visible for reference; reports use it.
        $codCollect = ($isCod && !$paid) ? (int) $vo->collect_amount : 0;

        return [
            'id'              => $vo->id,
            'parent_order_id' => $vo->parent_order_id,
            'status'          => $vo->status,
            'shop_name'       => $vo->vendor?->shop_name ?: $vo->vendor?->name,
            // Frozen collect (settlement) + the cash to actually collect at door.
            'collect_amount'  => (int) $vo->collect_amount,
            'cod_collect'     => $codCollect,
            'total'           => (int) $vo->collect_amount, // headline = collect, not subtotal
            'payment_method'  => $method,
            'payment_status'  => $vo->payment_status,
            'created_at'      => $vo->parent?->order_datetime,
            'customer'        => $vo->parent?->user?->name,
            'address'         => $addr ? [
                'name' => $addr->name, 'phone' => $addr->phone,
                'full_address' => $addr->full_address, 'pin_code' => $addr->pin_code,
            ] : null,
            // Pickup checklist only — no pricing / discount / settlement detail.
            'items'           => $vo->items->map(function ($i) {
                return [
                    'product_name' => $i->product?->name,
                    'variant_name' => $i->variant?->name,
                    'quantity'     => $i->quantity,
                    'image'        => $this->imageUrl($i->product?->images?->first()?->image_url),
                ];
            })->values()->toArray(),
        ];
    }

    // ─────────────────────────────────────────────────────────────
    // ADMIN management (platform pool + can see all). auth:admin
    // ─────────────────────────────────────────────────────────────
    public function adminIndex(Request $request)
    {
        $rows = DeliveryBoy::orderByDesc('id')->get()->map(fn($b) => $this->formatRider($b));
        return response()->json(['success' => true, 'data' => $rows]);
    }

    public function adminStore(Request $request)
    {
        return $this->createRider($request, null); // platform-owned
    }

    public function adminUpdate(Request $request)
    {
        $boy = DeliveryBoy::find($request->input('id'));
        if (!$boy) return response()->json(['success' => false, 'message' => 'Not found'], 404);
        return $this->updateRider($request, $boy);
    }

    public function adminDestroy(Request $request)
    {
        DeliveryBoy::where('id', $request->input('id'))->delete();
        return response()->json(['success' => true, 'message' => 'Deleted']);
    }

    // ── Shared create/update used by admin (vendor_id=null) and vendor (own id) ──
    public function createRider(Request $request, ?int $vendorId): \Illuminate\Http\JsonResponse
    {
        $name   = trim($request->input('name', ''));
        $mobile = trim($request->input('mobile', ''));
        $pass   = $request->input('password', '');
        if (!$name || !$mobile || !$pass) {
            return response()->json(['success' => false, 'message' => 'Name, mobile and password are required'], 422);
        }
        if (DeliveryBoy::where('mobile', $mobile)->exists()) {
            return response()->json(['success' => false, 'message' => 'A rider with this mobile already exists'], 409);
        }

        $boy = DeliveryBoy::create([
            'vendor_id' => $vendorId,
            'name'      => $name,
            'email'     => trim($request->input('email', '')),
            'mobile'    => $mobile,
            'pin_code'  => trim($request->input('pin_code', '')),
            'address'   => trim($request->input('address', '')),
            'password'  => Hash::make($pass),
            'date_time' => now()->format('d-m-Y h:i A'),
            'status'    => 'active',
        ]);

        return response()->json(['success' => true, 'message' => 'Delivery boy added', 'id' => $boy->id]);
    }

    public function updateRider(Request $request, DeliveryBoy $boy): \Illuminate\Http\JsonResponse
    {
        $updates = [];
        foreach (['name', 'email', 'mobile', 'pin_code', 'address', 'status'] as $f) {
            if ($request->filled($f)) $updates[$f] = trim($request->input($f));
        }
        if ($request->filled('password')) $updates['password'] = Hash::make($request->input('password'));
        $boy->update($updates);
        return response()->json(['success' => true, 'message' => 'Updated']);
    }
}
