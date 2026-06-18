<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Refund;
use App\Models\VendorOrder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RefundController extends Controller
{
    // ── POST /refunds/request (auth:sanctum) ──────────
    // Customer requests a refund for a cancelled or delivered order.
    public function request(Request $request)
    {
        $userId  = $request->user()->id;
        $orderId = (int) $request->input('order_id');
        $reason  = trim($request->input('reason', ''));

        if (!$orderId) {
            return response()->json(['success' => false, 'message' => 'order_id required'], 422);
        }

        $order = Order::find($orderId);
        if (!$order || $order->user_id !== $userId) {
            return response()->json(['success' => false, 'message' => 'Order not found'], 404);
        }

        $status = strtolower($order->status);
        if (!in_array($status, ['cancelled', 'delivered'], true)) {
            return response()->json(['success' => false, 'message' => 'Refunds can only be requested on cancelled or delivered orders']);
        }

        if (Refund::where('parent_order_id', $orderId)->whereIn('status', ['pending', 'approved'])->exists()) {
            return response()->json(['success' => false, 'message' => 'A refund request already exists for this order']);
        }

        $refund = Refund::create([
            'parent_order_id' => $orderId,
            'vendor_order_id' => null,
            'amount'          => $order->final_amount,
            'reason'          => $reason ?: 'Customer requested refund',
            'status'          => 'pending',
        ]);

        return response()->json(['success' => true, 'message' => 'Refund request submitted', 'refund_id' => $refund->id]);
    }

    // ── GET /refunds/my (auth:sanctum) ────────────────
    // Customer views their own refund requests.
    public function my(Request $request)
    {
        $userId = $request->user()->id;

        $refunds = Refund::whereHas('order', fn($q) => $q->where('user_id', $userId))
            ->with('order:id,status,final_amount,order_datetime')
            ->orderByDesc('id')
            ->get()
            ->map(fn($r) => [
                'id'         => $r->id,
                'order_id'   => $r->parent_order_id,
                'amount'     => (float) $r->amount,
                'reason'     => $r->reason,
                'status'     => $r->status,
                'created_at' => $r->created_at?->toDateTimeString(),
                'processed_at' => $r->processed_at,
            ]);

        return response()->json(['success' => true, 'refunds' => $refunds]);
    }

    // ── GET /admin/refunds (auth:admin) ───────────────
    public function adminIndex(Request $request)
    {
        $status  = $request->query('status', 'pending');
        $query   = Refund::with('order:id,user_id,status,final_amount,order_datetime')
            ->orderByDesc('id');
        if ($status !== 'all') $query->where('status', $status);

        $refunds = $query->get()->map(fn($r) => [
            'id'           => $r->id,
            'order_id'     => $r->parent_order_id,
            'amount'       => (float) $r->amount,
            'reason'       => $r->reason,
            'status'       => $r->status,
            'created_at'   => $r->created_at?->toDateTimeString(),
            'processed_at' => $r->processed_at,
        ]);

        return response()->json(['success' => true, 'refunds' => $refunds]);
    }

    // ── POST /admin/refunds/approve (auth:admin) ──────
    public function approve(Request $request)
    {
        return $this->processRefund($request, 'approved');
    }

    // ── POST /admin/refunds/reject (auth:admin) ───────
    public function reject(Request $request)
    {
        return $this->processRefund($request, 'rejected');
    }

    private function processRefund(Request $request, string $newStatus): \Illuminate\Http\JsonResponse
    {
        $refund = Refund::find($request->input('refund_id'));
        if (!$refund) return response()->json(['success' => false, 'message' => 'Refund not found'], 404);
        if ($refund->status !== 'pending') {
            return response()->json(['success' => false, 'message' => "Refund is already '{$refund->status}'"]);
        }

        $refund->update([
            'status'       => $newStatus,
            'processed_at' => now()->toDateTimeString(),
        ]);

        if ($newStatus === 'approved') {
            // Mark order payment_status as refunded.
            Order::where('id', $refund->parent_order_id)->update(['payment_status' => 'refunded']);
        }

        return response()->json(['success' => true, 'message' => "Refund $newStatus"]);
    }
}
