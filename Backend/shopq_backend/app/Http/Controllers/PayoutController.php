<?php

namespace App\Http\Controllers;

use App\Models\VendorOrder;
use App\Models\VendorPayout;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PayoutController extends Controller
{
    // ── GET /admin/payouts (auth:admin) ──────────────
    // Lists all payouts with optional status filter.
    public function index(Request $request)
    {
        $status = $request->query('status', 'all');
        $query  = VendorPayout::with('vendor:id,name,shop_name')->orderByDesc('id');
        if ($status !== 'all') $query->where('status', $status);

        $payouts = $query->get()->map(fn($p) => [
            'id'           => $p->id,
            'vendor_id'    => $p->vendor_id,
            'vendor_name'  => $p->vendor?->shop_name ?: $p->vendor?->name,
            'amount'       => (float) $p->amount,
            'status'       => $p->status,
            'period_start' => $p->period_start,
            'period_end'   => $p->period_end,
            'reference'    => $p->reference,
            'paid_at'      => $p->paid_at,
            'created_at'   => $p->created_at?->toDateString(),
        ]);

        return response()->json(['success' => true, 'payouts' => $payouts]);
    }

    // ── GET /admin/payouts/pending-earnings (auth:admin) ─
    // Returns per-vendor unpaid delivered earnings (no payout_id yet).
    public function pendingEarnings()
    {
        $rows = DB::select("
            SELECT vo.vendor_id,
                   v.name AS vendor_name, v.shop_name,
                   COUNT(vo.id) AS order_count,
                   SUM(vo.vendor_earning) AS total_earning
            FROM vendor_orders vo
            JOIN vendors v ON vo.vendor_id = v.id
            WHERE vo.status = 'delivered' AND vo.payout_id IS NULL
            GROUP BY vo.vendor_id, v.name, v.shop_name
            ORDER BY total_earning DESC
        ");

        return response()->json([
            'success'  => true,
            'earnings' => array_map(fn($r) => [
                'vendor_id'    => $r->vendor_id,
                'vendor_name'  => $r->shop_name ?: $r->vendor_name,
                'order_count'  => (int) $r->order_count,
                'total_earning'=> (float) $r->total_earning,
            ], $rows),
        ]);
    }

    // ── POST /admin/payouts/create (auth:admin) ───────
    // Creates a payout record and links the vendor's unpaid sub-orders to it.
    public function create(Request $request)
    {
        $vendorId  = (int) $request->input('vendor_id');
        $reference = trim($request->input('reference', ''));
        if (!$vendorId) {
            return response()->json(['success' => false, 'message' => 'vendor_id required'], 422);
        }

        $unpaidOrders = VendorOrder::where('vendor_id', $vendorId)
            ->where('status', 'delivered')
            ->whereNull('payout_id')
            ->get();

        if ($unpaidOrders->isEmpty()) {
            return response()->json(['success' => false, 'message' => 'No unpaid earnings for this vendor']);
        }

        $total = $unpaidOrders->sum('vendor_earning');
        $dates = $unpaidOrders->pluck('created_at')->filter()->sort();

        $payout = DB::transaction(function () use ($vendorId, $total, $reference, $dates, $unpaidOrders) {
            $p = VendorPayout::create([
                'vendor_id'    => $vendorId,
                'amount'       => $total,
                'status'       => 'pending',
                'period_start' => $dates->first()?->toDateString(),
                'period_end'   => $dates->last()?->toDateString(),
                'reference'    => $reference,
            ]);

            VendorOrder::whereIn('id', $unpaidOrders->pluck('id'))->update(['payout_id' => $p->id]);

            return $p;
        });

        return response()->json([
            'success'    => true,
            'message'    => 'Payout created',
            'payout_id'  => $payout->id,
            'amount'     => (float) $total,
            'order_count'=> $unpaidOrders->count(),
        ]);
    }

    // ── POST /admin/payouts/mark-paid (auth:admin) ────
    // Marks a payout as paid (bank transfer / UPI done outside the system).
    public function markPaid(Request $request)
    {
        $payout = VendorPayout::find($request->input('payout_id'));
        if (!$payout) return response()->json(['success' => false, 'message' => 'Payout not found'], 404);
        if ($payout->status === 'paid') {
            return response()->json(['success' => false, 'message' => 'Already marked as paid']);
        }

        $payout->update([
            'status'    => 'paid',
            'reference' => $request->filled('reference') ? $request->input('reference') : $payout->reference,
            'paid_at'   => now()->toDateTimeString(),
        ]);

        // Notify the vendor their settlement was paid (push + inbox).
        $vendor = \App\Models\Vendor::find($payout->vendor_id);
        if ($vendor) {
            app(\App\Services\NotificationService::class)->notify(
                $vendor,
                'settlement_update',
                'Settlement paid',
                '₹' . number_format((float) $payout->amount, 2) . ' has been paid to you.',
                ['payout_id' => (string) $payout->id, 'deeplink' => 'shopq://payout'],
            );
        }

        return response()->json(['success' => true, 'message' => 'Payout marked as paid']);
    }

    // ── GET /vendor/payouts (auth:vendor) ─────────────
    // Vendor views their own payout history.
    public function vendorIndex(Request $request)
    {
        $vendor  = $request->user();
        $payouts = VendorPayout::where('vendor_id', $vendor->id)
            ->orderByDesc('id')
            ->get()
            ->map(fn($p) => [
                'id'           => $p->id,
                'amount'       => (float) $p->amount,
                'status'       => $p->status,
                'period_start' => $p->period_start,
                'period_end'   => $p->period_end,
                'reference'    => $p->reference,
                'paid_at'      => $p->paid_at,
                'created_at'   => $p->created_at?->toDateString(),
            ]);

        return response()->json(['success' => true, 'payouts' => $payouts]);
    }
}
