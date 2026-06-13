<?php

namespace App\Http\Controllers;

use App\Models\Vendor;
use Illuminate\Http\Request;

class VendorController extends Controller
{
    // ── GET /admin/vendors?status=pending|approved|all ─
    public function index(Request $request)
    {
        $status = $request->query('status', 'all');
        $query  = Vendor::with('activeSubscription.plan')
            ->withCount('products')
            ->orderByDesc('id');

        if ($status !== 'all') {
            $query->where('status', $status);
        }

        $vendors = $query->get()->map(fn($v) => $this->formatVendor($v));

        return response()->json(['success' => true, 'data' => $vendors]);
    }

    // ── GET /admin/vendors/{id} ───────────────────────
    public function show($id)
    {
        $vendor = Vendor::with('activeSubscription.plan', 'pincodes', 'subscriptions.plan')
            ->withCount('products')
            ->find($id);

        if (!$vendor) {
            return response()->json(['success' => false, 'message' => 'Vendor not found']);
        }

        return response()->json(['success' => true, 'data' => $this->formatVendorFull($vendor)]);
    }

    // ── POST /admin/vendors/approve ───────────────────
    public function approve(Request $request)
    {
        $vendor = Vendor::find($request->input('id'));
        if (!$vendor) return response()->json(['success' => false, 'message' => 'Vendor not found']);

        $vendor->update(['status' => 'approved', 'rejection_reason' => null]);

        return response()->json(['success' => true, 'message' => 'Vendor approved']);
    }

    // ── POST /admin/vendors/reject ────────────────────
    public function reject(Request $request)
    {
        $vendor = Vendor::find($request->input('id'));
        if (!$vendor) return response()->json(['success' => false, 'message' => 'Vendor not found']);

        $vendor->update([
            'status'           => 'rejected',
            'rejection_reason' => $request->input('reason', 'Not specified'),
        ]);

        return response()->json(['success' => true, 'message' => 'Vendor rejected']);
    }

    // ── POST /admin/vendors/suspend ───────────────────
    public function suspend(Request $request)
    {
        $vendor = Vendor::find($request->input('id'));
        if (!$vendor) return response()->json(['success' => false, 'message' => 'Vendor not found']);

        $vendor->update(['status' => 'suspended']);

        return response()->json(['success' => true, 'message' => 'Vendor suspended']);
    }

    // ── POST /admin/vendors/delete ────────────────────
    public function delete(Request $request)
    {
        $vendor = Vendor::find($request->input('id'));
        if (!$vendor) return response()->json(['success' => false, 'message' => 'Vendor not found']);

        $vendor->delete();

        return response()->json(['success' => true, 'message' => 'Vendor deleted']);
    }

    // ── GET /admin/vendors/stats ──────────────────────
    public function stats()
    {
        return response()->json([
            'success' => true,
            'data'    => [
                'total'    => Vendor::count(),
                'pending'  => Vendor::where('status', 'pending')->count(),
                'approved' => Vendor::where('status', 'approved')->count(),
                'rejected' => Vendor::where('status', 'rejected')->count(),
                'suspended'=> Vendor::where('status', 'suspended')->count(),
            ],
        ]);
    }

    // ── Helpers ───────────────────────────────────────
    private function formatVendor(Vendor $v): array
    {
        $sub = $v->activeSubscription;
        return [
            'id'             => $v->id,
            'name'           => $v->name,
            'email'          => $v->email,
            'phone'          => $v->phone,
            'shop_name'      => $v->shop_name,
            'logo'           => $this->imageUrl($v->logo),
            'status'         => $v->status,
            'products_count' => $v->products_count ?? 0,
            'subscription'   => $sub ? [
                'plan_name'      => $sub->plan->name ?? null,
                'end_date'       => $sub->end_date,
                'days_remaining' => $sub->daysRemaining(),
            ] : null,
            'created_at'     => $v->created_at?->toDateString(),
        ];
    }

    private function formatVendorFull(Vendor $v): array
    {
        $base = $this->formatVendor($v);
        $base['shop_description'] = $v->shop_description;
        $base['rejection_reason'] = $v->rejection_reason;
        $base['pincodes'] = $v->pincodes->map(fn($p) => [
            'id' => $p->id, 'code' => $p->code, 'area_name' => $p->area_name, 'city' => $p->city,
        ])->toArray();
        $base['subscription_history'] = $v->subscriptions->map(fn($s) => [
            'plan_name'   => $s->plan->name ?? null,
            'start_date'  => $s->start_date,
            'end_date'    => $s->end_date,
            'status'      => $s->status,
            'amount_paid' => $s->amount_paid,
        ])->toArray();
        return $base;
    }
}
