<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Coupon;
use Carbon\Carbon;

class CouponController extends Controller
{
    private function isExpired(Coupon $coupon): bool
    {
        try {
            return Carbon::createFromFormat('d-m-Y', $coupon->expri_date)
                ->endOfDay()
                ->isPast();
        } catch (\Exception $e) {
            return false;
        }
    }

    private function isPublic(Coupon $coupon): bool
    {
        return in_array(strtolower((string) $coupon->status), ['public', 'active'], true);
    }

    public function add(Request $request)
    {
        $title     = trim($request->input('title', ''));
        $code      = strtoupper(trim($request->input('code_name', '')));
        $discount  = $request->input('discount');
        $minAmount = $request->input('min_amount', 0);
        $expiry    = trim($request->input('expri_date', ''));
        $status    = trim($request->input('status', 'Public'));

        if (!$title || !$code || $discount === null || !$expiry) {
            return response()->json(['success' => false, 'message' => 'title, code_name, discount and expri_date are required']);
        }

        if (!is_numeric($discount) || (float) $discount <= 0) {
            return response()->json(['success' => false, 'message' => 'Discount must be greater than 0']);
        }

        if (!is_numeric($minAmount) || (float) $minAmount < 0) {
            return response()->json(['success' => false, 'message' => 'Minimum amount must be 0 or greater']);
        }

        try {
            Carbon::createFromFormat('d-m-Y', $expiry);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Expiry date must be in dd-mm-yyyy format']);
        }

        if (Coupon::whereRaw('LOWER(code_name) = ?', [strtolower($code)])->exists()) {
            return response()->json(['success' => false, 'message' => 'Coupon code already exists']);
        }

        Coupon::create([
            'title'       => strtoupper($title),
            'description' => $request->input('description'),
            'code_name'   => $code,
            'discount'    => (float) $discount,
            'expri_date'  => $expiry,
            'status'      => strtolower($status) === 'private' ? 'Private' : 'Public',
            'min_amount'  => (float) $minAmount,
        ]);

        return response()->json(['success' => true]);
    }

    public function edit(Request $request)
    {
        $id = $request->input('id');
        if (!$id) {
            return response()->json(['success' => false, 'message' => 'Coupon ID is required.']);
        }

        $coupon = Coupon::find($id);
        if (!$coupon) {
            return response()->json(['success' => false, 'message' => 'Coupon not found.']);
        }

        $title     = trim($request->input('title', $coupon->title));
        $code      = strtoupper(trim($request->input('code_name', $coupon->code_name)));
        $discount  = $request->input('discount', $coupon->discount);
        $minAmount = $request->input('min_amount', $coupon->min_amount);
        $expiry    = trim($request->input('expri_date', $coupon->expri_date));
        $status    = trim($request->input('status', $coupon->status));

        if (!$title || !$code || $discount === null || !$expiry) {
            return response()->json(['success' => false, 'message' => 'title, code_name, discount and expri_date are required']);
        }

        if (!is_numeric($discount) || (float) $discount <= 0) {
            return response()->json(['success' => false, 'message' => 'Discount must be greater than 0']);
        }

        if (!is_numeric($minAmount) || (float) $minAmount < 0) {
            return response()->json(['success' => false, 'message' => 'Minimum amount must be 0 or greater']);
        }

        try {
            Carbon::createFromFormat('d-m-Y', $expiry);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Expiry date must be in dd-mm-yyyy format']);
        }

        // Block duplicate codes belonging to a different coupon.
        $dup = Coupon::whereRaw('LOWER(code_name) = ?', [strtolower($code)])
            ->where('id', '!=', $coupon->id)->exists();
        if ($dup) {
            return response()->json(['success' => false, 'message' => 'Coupon code already exists']);
        }

        $coupon->update([
            'title'       => strtoupper($title),
            'description' => $request->input('description', $coupon->description),
            'code_name'   => $code,
            'discount'    => (float) $discount,
            'expri_date'  => $expiry,
            'status'      => strtolower($status) === 'private' ? 'Private' : 'Public',
            'min_amount'  => (float) $minAmount,
        ]);

        return response()->json(['success' => true, 'message' => 'Coupon updated']);
    }

    public function view()
    {
        $coupons = Coupon::orderByDesc('id')
            ->get()
            ->filter(fn($coupon) => $this->isPublic($coupon) && !$this->isExpired($coupon))
            ->values();

        return response()->json(['success' => true, 'data' => $coupons]);
    }

    public function viewAll()
    {
        $coupons = Coupon::orderByDesc('id')->get();
        return response()->json(['success' => true, 'data' => $coupons]);
    }

    public function delete(Request $request)
    {
        $id = $request->input('id');
        if (!$id) {
            return response()->json(['success' => false, 'message' => 'Coupon ID is required.']);
        }

        $coupon = Coupon::find($id);
        if (!$coupon) {
            return response()->json(['success' => false, 'message' => 'Coupon not found.']);
        }

        $coupon->delete();
        return response()->json(['success' => true, 'message' => 'Coupon deleted successfully.']);
    }

    public function validate(Request $request)
    {
        $code = strtoupper(trim($request->query('code', '')));
        if (!$code) {
            return response()->json(['success' => false, 'message' => 'Coupon code is required']);
        }

        $coupon = Coupon::whereRaw('LOWER(code_name) = ?', [strtolower($code)])->first();
        if (!$coupon) {
            return response()->json(['success' => false, 'message' => 'Invalid coupon code']);
        }

        if ($this->isExpired($coupon)) {
            return response()->json(['success' => false, 'message' => 'Coupon has expired']);
        }

        return response()->json([
            'success' => true,
            'data'    => [
                'title'       => $coupon->title,
                'description' => $coupon->description,
                'code_name'   => $coupon->code_name,
                'discount'    => $coupon->discount,
                'min_amount'  => $coupon->min_amount,
                'expri_date'  => $coupon->expri_date,
            ],
        ]);
    }
}
