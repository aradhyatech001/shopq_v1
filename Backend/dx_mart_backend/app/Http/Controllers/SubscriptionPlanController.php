<?php

namespace App\Http\Controllers;

use App\Models\SubscriptionPlan;
use App\Models\VendorSubscription;
use Illuminate\Http\Request;
use Carbon\Carbon;

class SubscriptionPlanController extends Controller
{
    // ── GET /subscription-plans (public — vendors can view) ──
    public function view()
    {
        $plans = SubscriptionPlan::where('is_active', true)
            ->orderBy('position')
            ->orderBy('price')
            ->get()
            ->map(fn($p) => $this->formatPlan($p));

        return response()->json(['success' => true, 'data' => $plans]);
    }

    // ── GET /admin/subscription-plans (all including inactive) ──
    public function viewAll()
    {
        $plans = SubscriptionPlan::orderBy('position')->orderBy('price')->get()
            ->map(fn($p) => $this->formatPlan($p));

        return response()->json(['success' => true, 'data' => $plans]);
    }

    // ── POST /admin/subscription-plans/add ───────────
    public function add(Request $request)
    {
        $name          = trim($request->input('name', ''));
        $durationType  = $request->input('duration_type', 'monthly');
        $price         = (float) $request->input('price', 0);

        if (!$name) return response()->json(['success' => false, 'message' => 'Name required']);
        if ($price <= 0) return response()->json(['success' => false, 'message' => 'Price must be > 0']);

        $durationDays = $durationType === 'yearly' ? 365 : 30;

        // features: comma-separated string → JSON array
        $featuresRaw = $request->input('features', '');
        $features    = $this->encodeFeatures($featuresRaw);

        $plan = SubscriptionPlan::create([
            'name'          => $name,
            'duration_type' => $durationType,
            'duration_days' => $durationDays,
            'price'         => $price,
            'features'      => $features,
            'max_products'  => (int) $request->input('max_products', 0),
            'is_active'     => true,
            'position'      => (int) $request->input('position', SubscriptionPlan::max('position') + 1),
        ]);

        return response()->json(['success' => true, 'message' => 'Plan created', 'data' => $this->formatPlan($plan)]);
    }

    // ── POST /admin/subscription-plans/edit ──────────
    public function edit(Request $request)
    {
        $plan = SubscriptionPlan::find($request->input('id'));
        if (!$plan) return response()->json(['success' => false, 'message' => 'Plan not found']);

        $durationType = $request->input('duration_type', $plan->duration_type);

        $updates = [
            'name'          => trim($request->input('name', $plan->name)),
            'duration_type' => $durationType,
            'duration_days' => $durationType === 'yearly' ? 365 : 30,
            'price'         => (float) $request->input('price', $plan->price),
            'max_products'  => (int) $request->input('max_products', $plan->max_products),
            'position'      => (int) $request->input('position', $plan->position),
        ];

        if ($request->has('features')) {
            $updates['features'] = $this->encodeFeatures($request->input('features'));
        }
        if ($request->has('is_active')) {
            $updates['is_active'] = (bool) $request->input('is_active');
        }

        $plan->update($updates);

        return response()->json(['success' => true, 'message' => 'Plan updated', 'data' => $this->formatPlan($plan->fresh())]);
    }

    // ── POST /admin/subscription-plans/delete ────────
    public function delete(Request $request)
    {
        $plan = SubscriptionPlan::find($request->input('id'));
        if (!$plan) return response()->json(['success' => false, 'message' => 'Plan not found']);

        $plan->delete();
        return response()->json(['success' => true, 'message' => 'Plan deleted']);
    }

    // ── POST /admin/subscription-plans/toggle ────────
    public function toggle(Request $request)
    {
        $plan = SubscriptionPlan::find($request->input('id'));
        if (!$plan) return response()->json(['success' => false, 'message' => 'Plan not found']);

        $plan->update(['is_active' => !$plan->is_active]);
        return response()->json(['success' => true, 'is_active' => $plan->is_active]);
    }

    // ── POST /vendor/subscribe ────────────────────────
    // Vendor buys a plan (admin marks as paid manually)
    public function subscribe(Request $request)
    {
        $vendor = $request->user(); // from vendor:sanctum guard

        $plan = SubscriptionPlan::where('id', $request->input('plan_id'))
            ->where('is_active', true)
            ->first();

        if (!$plan) return response()->json(['success' => false, 'message' => 'Plan not found']);

        // Cancel any existing active subscription
        VendorSubscription::where('vendor_id', $vendor->id)
            ->where('status', 'active')
            ->update(['status' => 'cancelled']);

        $startDate = Carbon::today();
        $endDate   = $startDate->copy()->addDays($plan->duration_days);

        $sub = VendorSubscription::create([
            'vendor_id'         => $vendor->id,
            'plan_id'           => $plan->id,
            'start_date'        => $startDate->toDateString(),
            'end_date'          => $endDate->toDateString(),
            'status'            => 'active',
            'payment_reference' => $request->input('payment_reference'),
            'payment_mode'      => $request->input('payment_mode', 'manual'),
            'amount_paid'       => $plan->price,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Subscribed successfully',
            'subscription' => [
                'plan_name'      => $plan->name,
                'start_date'     => $sub->start_date,
                'end_date'       => $sub->end_date,
                'days_remaining' => $sub->daysRemaining(),
            ],
        ]);
    }

    // ── GET /vendor/subscription ──────────────────────
    public function vendorSubscription(Request $request)
    {
        $vendor = $request->user();
        $vendor->load('activeSubscription.plan', 'subscriptions.plan');

        $active = $vendor->activeSubscription;
        return response()->json([
            'success'      => true,
            'active'       => $active ? [
                'plan_name'      => $active->plan->name ?? null,
                'duration_type'  => $active->plan->duration_type ?? null,
                'start_date'     => $active->start_date,
                'end_date'       => $active->end_date,
                'days_remaining' => $active->daysRemaining(),
                'status'         => $active->status,
            ] : null,
            'history'      => $vendor->subscriptions->map(fn($s) => [
                'plan_name'   => $s->plan->name ?? null,
                'start_date'  => $s->start_date,
                'end_date'    => $s->end_date,
                'status'      => $s->status,
                'amount_paid' => $s->amount_paid,
                'payment_mode'=> $s->payment_mode,
            ])->toArray(),
        ]);
    }

    // ── POST /admin/subscriptions/grant ──────────────
    // Admin manually grants subscription to a vendor
    public function adminGrant(Request $request)
    {
        $plan   = SubscriptionPlan::find($request->input('plan_id'));
        if (!$plan) return response()->json(['success' => false, 'message' => 'Plan not found']);

        $vendorId = $request->input('vendor_id');

        VendorSubscription::where('vendor_id', $vendorId)
            ->where('status', 'active')
            ->update(['status' => 'cancelled']);

        $startDate = Carbon::today();
        $endDate   = $startDate->copy()->addDays($plan->duration_days);

        VendorSubscription::create([
            'vendor_id'         => $vendorId,
            'plan_id'           => $plan->id,
            'start_date'        => $startDate->toDateString(),
            'end_date'          => $endDate->toDateString(),
            'status'            => 'active',
            'payment_reference' => $request->input('payment_reference'),
            'payment_mode'      => $request->input('payment_mode', 'admin_grant'),
            'amount_paid'       => $request->input('amount_paid', $plan->price),
        ]);

        return response()->json(['success' => true, 'message' => 'Subscription granted']);
    }

    // ── Helpers ───────────────────────────────────────
    private function formatPlan(SubscriptionPlan $p): array
    {
        return [
            'id'            => $p->id,
            'name'          => $p->name,
            'duration_type' => $p->duration_type,
            'duration_days' => $p->duration_days,
            'price'         => (float) $p->price,
            'features'      => $p->features_array,
            'max_products'  => $p->max_products,
            'is_active'     => (bool) $p->is_active,
            'position'      => $p->position,
        ];
    }

    private function encodeFeatures(mixed $raw): string
    {
        if (is_array($raw)) return json_encode(array_values(array_filter(array_map('trim', $raw))));
        if (is_string($raw) && str_starts_with(trim($raw), '[')) return $raw; // already JSON
        // Comma-separated
        $arr = array_values(array_filter(array_map('trim', explode(',', $raw ?? ''))));
        return json_encode($arr);
    }
}
