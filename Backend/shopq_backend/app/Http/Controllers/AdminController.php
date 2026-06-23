<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\Admin;

class AdminController extends Controller
{
    public function login(Request $request)
    {
        $email    = strtolower(trim($request->input('email', '')));
        $password = $request->input('password', '');

        if (!$email || !$password) {
            return response()->json(['status' => 'error', 'message' => 'Email and password are required'], 422);
        }

        $admin = Admin::whereRaw('LOWER(email) = ?', [$email])->first();

        if (!$admin || !Hash::check($password, $admin->password)) {
            return response()->json(['status' => 'error', 'message' => 'Invalid Email or Password'], 401);
        }

        $admin->tokens()->delete();
        $token = $admin->createToken('admin-token')->plainTextToken;

        return response()->json([
            'status'  => 'success',
            'message' => 'Login Successful',
            'token'   => $token,
            'user'    => [
                'id'    => $admin->id,
                'email' => $admin->email,
                'name'  => $admin->name,
            ],
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()?->currentAccessToken()?->delete();
        return response()->json(['status' => 'success', 'message' => 'Logged out']);
    }

    public function me(Request $request)
    {
        $admin = $request->user();
        return response()->json([
            'success' => true,
            'user'    => [
                'id'    => $admin->id,
                'email' => $admin->email,
                'name'  => $admin->name,
            ],
        ]);
    }
}
