<?php

namespace App\Http\Controllers;

use App\Models\Vendor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class VendorAuthController extends Controller
{
    // ── POST /vendor/register ─────────────────────────
    public function register(Request $request)
    {
        $name        = trim($request->input('name', ''));
        $email       = strtolower(trim($request->input('email', '')));
        $phone       = trim($request->input('phone', ''));
        $password    = $request->input('password', '');
        $shopName    = trim($request->input('shop_name', ''));
        $shopDesc    = trim($request->input('shop_description', ''));

        if (!$name || !$email || !$password || !$shopName) {
            return response()->json(['success' => false, 'message' => 'name, email, password and shop_name are required']);
        }

        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return response()->json(['success' => false, 'message' => 'Invalid email']);
        }

        if (Vendor::where('email', $email)->exists()) {
            return response()->json(['success' => false, 'message' => 'Email already registered']);
        }

        // Logo upload
        $logoPath = null;
        if ($request->has('logo_data') && $request->has('logo_name')) {
            $logoPath = 'vendors/' . $request->input('logo_name');
            Storage::disk('public')->put($logoPath, base64_decode($request->input('logo_data')));
        }

        $vendor = Vendor::create([
            'name'             => $name,
            'email'            => $email,
            'phone'            => $phone,
            'password'         => Hash::make($password),
            'shop_name'        => $shopName,
            'shop_description' => $shopDesc,
            'logo'             => $logoPath,
            'status'           => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Registration successful. Please wait for admin approval.',
            'vendor'  => $this->formatVendor($vendor),
        ]);
    }

    // ── POST /vendor/login ────────────────────────────
    public function login(Request $request)
    {
        $email    = strtolower(trim($request->input('email', '')));
        $password = $request->input('password', '');

        if (!$email || !$password) {
            return response()->json(['success' => false, 'message' => 'Email and password required'], 422);
        }

        $vendor = Vendor::whereRaw('LOWER(email) = ?', [$email])->first();

        if (!$vendor || !Hash::check($password, $vendor->password)) {
            return response()->json(['success' => false, 'message' => 'Invalid credentials'], 401);
        }

        if ($vendor->status === 'pending') {
            return response()->json(['success' => false, 'message' => 'Your account is pending admin approval', 'status' => 'pending'], 403);
        }

        if ($vendor->status === 'rejected') {
            return response()->json([
                'success' => false,
                'message' => 'Account rejected: ' . ($vendor->rejection_reason ?? 'Contact admin'),
                'status'  => 'rejected',
            ], 403);
        }

        if ($vendor->status === 'suspended') {
            return response()->json(['success' => false, 'message' => 'Account suspended. Contact admin.', 'status' => 'suspended'], 403);
        }

        // Revoke old tokens
        $vendor->tokens()->delete();
        $token = $vendor->createToken('vendor-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'token'   => $token,
            'vendor'  => $this->formatVendor($vendor),
        ]);
    }

    // ── POST /vendor/logout ───────────────────────────
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['success' => true, 'message' => 'Logged out']);
    }

    // ── GET /vendor/profile ───────────────────────────
    public function profile(Request $request)
    {
        $vendor = $request->user();
        $vendor->load('activeSubscription.plan', 'pincodes');

        return response()->json([
            'success' => true,
            'vendor'  => $this->formatVendor($vendor, true),
        ]);
    }

    // ── POST /vendor/profile/update ───────────────────
    public function updateProfile(Request $request)
    {
        $vendor = $request->user();

        $updates = [];
        if ($request->has('name'))             $updates['name']             = trim($request->input('name'));
        if ($request->has('phone'))            $updates['phone']            = trim($request->input('phone'));
        if ($request->has('shop_name'))        $updates['shop_name']        = trim($request->input('shop_name'));
        if ($request->has('shop_description')) $updates['shop_description'] = trim($request->input('shop_description'));

        if ($request->has('password') && $request->input('password')) {
            $updates['password'] = Hash::make($request->input('password'));
        }

        // Logo update
        if ($request->has('logo_data') && $request->has('logo_name')) {
            if ($vendor->logo) Storage::disk('public')->delete($vendor->logo);
            $logoPath = 'vendors/' . $request->input('logo_name');
            Storage::disk('public')->put($logoPath, base64_decode($request->input('logo_data')));
            $updates['logo'] = $logoPath;
        }

        $vendor->update($updates);

        return response()->json(['success' => true, 'vendor' => $this->formatVendor($vendor->fresh())]);
    }

    public function changePassword(Request $request)
    {
        $vendor = $request->user();

        if (!\Hash::check($request->input('current_password'), $vendor->password)) {
            return response()->json(['success' => false, 'message' => 'Current password is incorrect'], 422);
        }

        $new = $request->input('password');
        if (!$new || strlen($new) < 6) {
            return response()->json(['success' => false, 'message' => 'New password must be at least 6 characters'], 422);
        }
        if ($new !== $request->input('password_confirmation')) {
            return response()->json(['success' => false, 'message' => 'Passwords do not match'], 422);
        }

        $vendor->update(['password' => \Hash::make($new)]);

        return response()->json(['success' => true, 'message' => 'Password updated successfully']);
    }

    // ── Helper ────────────────────────────────────────
    private function formatVendor(Vendor $v, bool $full = false): array
    {
        $data = [
            'id'           => $v->id,
            'name'         => $v->name,
            'email'        => $v->email,
            'phone'        => $v->phone,
            'shop_name'    => $v->shop_name,
            'shop_description' => $v->shop_description,
            'logo'         => $this->imageUrl($v->logo),
            'status'       => $v->status,
        ];

        if ($full) {
            $sub = $v->activeSubscription;
            $subData = $sub ? [
                'id'             => $sub->id,
                'plan_name'      => $sub->plan->name ?? null,
                'duration_type'  => $sub->plan->duration_type ?? null,
                'start_date'     => $sub->start_date,
                'end_date'       => $sub->end_date,
                'days_remaining' => $sub->daysRemaining(),
                'status'         => $sub->status,
            ] : null;
            $data['subscription']        = $subData;  // legacy key
            $data['active_subscription'] = $subData;  // vendor app key

            $data['pincodes'] = $v->pincodes->map(fn($p) => [
                'id'        => $p->id,
                'code'      => $p->code,
                'area_name' => $p->area_name,
                'city'      => $p->city,
            ])->toArray();
        }

        return $data;
    }
}
