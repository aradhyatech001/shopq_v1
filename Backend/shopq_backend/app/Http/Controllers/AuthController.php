<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\OtpTable;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;

class AuthController extends Controller
{
    public function signup(Request $request)
    {
        // Normalise so the same address can't register twice with different
        // case/whitespace, and so it always matches at login time.
        $email    = strtolower(trim($request->input('email', '')));
        $name     = trim($request->input('name', ''));
        $password = $request->input('password', '');

        if (!$name || !$email || !$password) {
            return response()->json(['status' => 'error', 'message' => 'Name, email and password are required'], 422);
        }
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return response()->json(['status' => 'error', 'message' => 'Please enter a valid email'], 422);
        }
        if (strlen($password) < 8) {
            return response()->json(['status' => 'error', 'message' => 'Password must be at least 8 characters'], 422);
        }
        if (User::whereRaw('LOWER(email) = ?', [$email])->exists()) {
            return response()->json(['status' => 'error', 'message' => 'Email already registered'], 409);
        }

        User::create([
            'name'      => $name,
            'email'     => $email,
            'password'  => Hash::make($password),
            'status'    => 'active',
            'date_time' => $request->input('date_time'),
        ]);
        return response()->json(['status' => 'success', 'message' => 'Signup Successful']);
    }

    public function login(Request $request)
    {
        $email    = strtolower(trim($request->input('email', '')));
        $password = $request->input('password', '');

        if (!$email || !$password) {
            return response()->json(['status' => 'error', 'message' => 'Email and password are required'], 422);
        }

        // Case-insensitive lookup so historic mixed-case rows still match.
        $user = User::whereRaw('LOWER(email) = ?', [$email])->first();
        if (!$user || !Hash::check($password, $user->password)) {
            return response()->json(['status' => 'error', 'message' => 'Invalid Email or Password'], 401);
        }
        if (strtolower((string) $user->status) === 'inactive' || strtolower((string) $user->status) === 'blocked') {
            return response()->json(['status' => 'error', 'message' => 'Your account is blocked. Contact support.'], 403);
        }

        $token = $user->createToken('auth_token')->plainTextToken;
        return response()->json([
            'status'  => 'success',
            'message' => 'Login Successful',
            'token'   => $token,
            'user'    => $user,
        ]);
    }

    public function getUser(Request $request)
    {
        // Now behind auth:sanctum — return the token's own user (id + name only).
        // The old email-based lookup is removed to prevent data enumeration.
        $user = $request->user();
        return response()->json([
            'status' => 'success',
            'user'   => ['id' => $user->id, 'name' => $user->name, 'email' => $user->email],
        ]);
    }

    public function getAllUsers(Request $request)
    {
        $limit  = (int) $request->query('limit', 10);
        $offset = (int) $request->query('offset', 0);
        $search = $request->query('search', '');

        $query = User::select('id', 'name', 'email', 'status', 'date_time');
        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%$search%")
                  ->orWhere('email', 'like', "%$search%");
            });
        }
        $total = $query->count();
        $users = $query->orderBy('id')->skip($offset)->take($limit)->get();
        return response()->json(['success' => true, 'users' => $users, 'total' => $total]);
    }

    public function editProfile(Request $request)
    {
        $user    = $request->user();
        $newName = trim($request->input('name', ''));
        if (!$newName) {
            return response()->json(['status' => 'error', 'message' => 'Name is required']);
        }
        $user->update(['name' => $newName]);
        return response()->json(['status' => 'success', 'message' => 'Name updated successfully', 'user' => $user->fresh()]);
    }

    public function userStatus(Request $request)
    {
        $userId    = $request->input('user_id');
        $newStatus = $request->input('new_status');
        if (!$userId || !$newStatus) {
            return response()->json(['success' => false, 'message' => 'Missing parameters']);
        }
        User::where('id', $userId)->update(['status' => $newStatus]);
        return response()->json(['success' => true, 'message' => 'Status updated']);
    }

    public function forgotPassword(Request $request)
    {
        $email = strtolower(trim($request->input('email', '')));
        if (!User::whereRaw('LOWER(email) = ?', [$email])->exists()) {
            return response()->json(['status' => 'error', 'message' => 'Email not registered'], 404);
        }
        $otp    = rand(100000, 999999);
        $expiry = time() + 300;
        OtpTable::updateOrCreate(['email' => $email], ['otp' => $otp, 'expiry' => $expiry]);

        try {
            Mail::raw("Your OTP is: $otp. Valid for 5 minutes.", function ($msg) use ($email) {
                $msg->to($email)->subject('Password Reset OTP');
            });
        } catch (\Exception $e) {}

        return response()->json(['status' => 'success', 'message' => 'OTP sent to email']);
    }

    public function verifyOtp(Request $request)
    {
        $email = strtolower(trim($request->input('email', '')));
        $otp   = $request->input('otp');

        $row = OtpTable::where('email', $email)
            ->where('otp', $otp)
            ->where('expiry', '>', time())
            ->first();

        if (!$row) {
            return response()->json(['status' => 'error', 'message' => 'Invalid or Expired OTP'], 422);
        }

        // Invalidate the numeric OTP immediately so it cannot be replayed, and
        // replace it with a one-time reset token valid for 15 minutes.
        $resetToken = \Illuminate\Support\Str::random(64);
        $row->update(['otp' => null, 'expiry' => time() + 900, 'reset_token' => $resetToken]);

        return response()->json(['status' => 'success', 'message' => 'OTP Verified', 'reset_token' => $resetToken]);
    }

    public function resetPassword(Request $request)
    {
        $email      = strtolower(trim($request->input('email', '')));
        $newPass    = $request->input('new_password', '');
        $resetToken = trim($request->input('reset_token', ''));

        if (!$email || strlen($newPass) < 8) {
            return response()->json(['status' => 'error', 'message' => 'A valid email and a password of at least 8 characters are required'], 422);
        }

        // Require a valid reset_token issued by verifyOtp; prevents resetting a
        // password without ever verifying the OTP (broken access control fix).
        if (!$resetToken) {
            return response()->json(['status' => 'error', 'message' => 'Reset token required'], 422);
        }
        $validToken = OtpTable::where('email', $email)
            ->where('reset_token', $resetToken)
            ->where('expiry', '>', time())
            ->exists();
        if (!$validToken) {
            return response()->json(['status' => 'error', 'message' => 'Invalid or expired reset token'], 422);
        }

        $affected = User::whereRaw('LOWER(email) = ?', [$email])->update(['password' => Hash::make($newPass)]);
        if (!$affected) {
            return response()->json(['status' => 'error', 'message' => 'Email not registered'], 404);
        }

        // Consume the reset token so it cannot be reused.
        OtpTable::where('email', $email)->delete();

        return response()->json(['status' => 'success', 'message' => 'Password Updated']);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['status' => 'success', 'message' => 'Logged out']);
    }
}
