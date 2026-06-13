<?php

namespace App\Http\Controllers;

use App\Models\Pincode;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PincodeController extends Controller
{
    // ── GET /pincodes (public — all active pincodes) ──
    public function view()
    {
        $pincodes = Pincode::where('is_active', true)
            ->orderBy('code')
            ->get()
            ->map(fn($p) => $this->format($p));

        return response()->json(['success' => true, 'data' => $pincodes]);
    }

    // ── GET /admin/pincodes (all including inactive) ──
    public function viewAll()
    {
        $pincodes = Pincode::orderBy('code')->get()->map(fn($p) => $this->format($p, true));
        return response()->json(['success' => true, 'data' => $pincodes]);
    }

    // ── POST /admin/pincodes/add ──────────────────────
    public function add(Request $request)
    {
        $code     = trim($request->input('code', ''));
        $areaName = trim($request->input('area_name', ''));

        if (!$code || !$areaName) {
            return response()->json(['success' => false, 'message' => 'code and area_name are required']);
        }

        if (Pincode::where('code', $code)->exists()) {
            return response()->json(['success' => false, 'message' => 'Pincode already exists']);
        }

        $pincode = Pincode::create([
            'code'      => $code,
            'area_name' => $areaName,
            'city'      => trim($request->input('city', '')),
            'state'     => trim($request->input('state', '')),
            'is_active' => true,
        ]);

        return response()->json(['success' => true, 'message' => 'Pincode added', 'data' => $this->format($pincode)]);
    }

    // ── POST /admin/pincodes/add-bulk ─────────────────
    // Body: { "pincodes": [{"code":"110001","area_name":"CP","city":"Delhi","state":"Delhi"}, ...] }
    public function addBulk(Request $request)
    {
        $items   = $request->input('pincodes', []);
        $added   = 0;
        $skipped = 0;

        foreach ($items as $item) {
            $code = trim($item['code'] ?? '');
            $area = trim($item['area_name'] ?? '');
            if (!$code || !$area) { $skipped++; continue; }
            if (Pincode::where('code', $code)->exists()) { $skipped++; continue; }
            Pincode::create([
                'code'      => $code,
                'area_name' => $area,
                'city'      => trim($item['city'] ?? ''),
                'state'     => trim($item['state'] ?? ''),
                'is_active' => true,
            ]);
            $added++;
        }

        return response()->json(['success' => true, 'added' => $added, 'skipped' => $skipped]);
    }

    // ── POST /admin/pincodes/edit ─────────────────────
    public function edit(Request $request)
    {
        $pincode = Pincode::find($request->input('id'));
        if (!$pincode) return response()->json(['success' => false, 'message' => 'Pincode not found']);

        $updates = [];
        if ($request->has('area_name')) $updates['area_name'] = trim($request->input('area_name'));
        if ($request->has('city'))      $updates['city']      = trim($request->input('city'));
        if ($request->has('state'))     $updates['state']     = trim($request->input('state'));
        if ($request->has('is_active')) $updates['is_active'] = (bool) $request->input('is_active');

        $pincode->update($updates);

        return response()->json(['success' => true, 'message' => 'Pincode updated', 'data' => $this->format($pincode->fresh())]);
    }

    // ── POST /admin/pincodes/toggle ───────────────────
    public function toggle(Request $request)
    {
        $pincode = Pincode::find($request->input('id'));
        if (!$pincode) return response()->json(['success' => false, 'message' => 'Pincode not found']);

        $pincode->update(['is_active' => !$pincode->is_active]);
        return response()->json(['success' => true, 'is_active' => $pincode->is_active]);
    }

    // ── POST /admin/pincodes/delete ───────────────────
    public function delete(Request $request)
    {
        $pincode = Pincode::find($request->input('id'));
        if (!$pincode) return response()->json(['success' => false, 'message' => 'Pincode not found']);

        $pincode->delete();
        return response()->json(['success' => true, 'message' => 'Pincode deleted']);
    }

    // ── POST /vendor/pincodes/update ──────────────────
    // Vendor selects/updates which pincodes they serve
    public function vendorUpdatePincodes(Request $request)
    {
        $vendor     = $request->user();
        $pincodeIds = $request->input('pincode_ids', []);

        // Validate the IDs and fetch the rows so we can fill the pivot's
        // denormalised columns (vendor_pincodes.pincode / area_name are NOT NULL).
        $pincodes = Pincode::whereIn('id', $pincodeIds)->where('is_active', true)->get();

        $syncData = [];
        foreach ($pincodes as $p) {
            $syncData[$p->id] = [
                'pincode'   => $p->code,
                'area_name' => $p->area_name,
                'is_active' => 1,
            ];
        }

        // Sync (replaces existing selection)
        $vendor->pincodes()->sync($syncData);

        return response()->json([
            'success' => true,
            'message' => 'Service pincodes updated',
            'count'   => count($syncData),
        ]);
    }

    // ── GET /vendor/pincodes ──────────────────────────
    // Returns pincodes vendor has selected
    public function vendorPincodes(Request $request)
    {
        $vendor = $request->user();
        $vendor->load('pincodes');

        return response()->json([
            'success'          => true,
            'selected_pincodes'=> $vendor->pincodes->map(fn($p) => $this->format($p))->toArray(),
        ]);
    }

    // ── GET /pincodes/check?code=110001 ───────────────
    // Check if a pincode is serviceable by any vendor
    public function check(Request $request)
    {
        $code = trim($request->query('code', ''));
        if (!$code) return response()->json(['success' => false, 'message' => 'code required']);

        $pincode = Pincode::where('code', $code)->where('is_active', true)->first();
        if (!$pincode) {
            return response()->json(['success' => true, 'serviceable' => false, 'message' => 'Pincode not found']);
        }

        $vendorCount = $pincode->vendors()
            ->where('status', 'approved')
            ->count();

        return response()->json([
            'success'      => true,
            'serviceable'  => $vendorCount > 0,
            'pincode'      => $this->format($pincode),
            'vendor_count' => $vendorCount,
        ]);
    }

    // ── POST /auth/set-pincode (auth:sanctum required) ──
    // User sets their delivery pincode — user_id comes from the Sanctum token
    public function setUserPincode(Request $request)
{
    Log::info('setUserPincode API HIT', [
        'request_data' => $request->all(),
        'headers' => $request->headers->all(),
    ]);

    try {

        $pincodeId = $request->input('pincode_id');

        Log::info('Pincode ID Received', [
            'pincode_id' => $pincodeId
        ]);

        if (!$pincodeId) {

            Log::warning('Pincode ID Missing');

            return response()->json([
                'success' => false,
                'message' => 'pincode_id required'
            ]);
        }

        $pincode = Pincode::find($pincodeId);

        Log::info('Pincode Query Result', [
            'found' => !empty($pincode)
        ]);

        if (!$pincode) {

            Log::warning('Pincode Not Found', [
                'pincode_id' => $pincodeId
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Pincode not found'
            ]);
        }

        $user = $request->user();

        Log::info('Authenticated User', [
            'user_exists' => !empty($user),
            'user_id' => $user?->id
        ]);

        if ($user) {

            $user->update([
                'pincode_id' => $pincodeId
            ]);

            Log::info('User Pincode Updated', [
                'user_id' => $user->id,
                'pincode_id' => $pincodeId
            ]);
        } else {

            Log::warning('No Authenticated User Found');
        }

        Log::info('API Completed Successfully');

        return response()->json([
            'success' => true,
            'message' => 'Pincode set',
            'pincode' => $this->format($pincode)
        ]);

    } catch (\Throwable $e) {

        Log::error('setUserPincode Exception', [
            'message' => $e->getMessage(),
            'file' => $e->getFile(),
            'line' => $e->getLine(),
            'trace' => $e->getTraceAsString()
        ]);

        return response()->json([
            'success' => false,
            'message' => 'Internal Server Error',
            'error' => $e->getMessage()
        ], 500);
    }
}

    // ── Helper ────────────────────────────────────────
    private function format(Pincode $p, bool $withCount = false): array
    {
        $data = [
            'id'        => $p->id,
            'code'      => $p->code,
            'area_name' => $p->area_name,
            'city'      => $p->city,
            'state'     => $p->state,
            'is_active' => (bool) $p->is_active,
        ];
        if ($withCount) {
            $data['vendor_count'] = $p->vendors()->where('status', 'approved')->count();
        }
        return $data;
    }
}
