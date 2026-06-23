<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class FcmController extends Controller
{
    // POST  /fcm/token          (auth:sanctum  — user)
    // POST  /vendor/fcm/token   (auth:vendor)
    // POST  /delivery/fcm/token (auth:delivery)
    public function updateToken(Request $request)
    {
        $request->validate(['fcm_token' => 'required|string|max:512']);

        $request->user()->update(['fcm_token' => $request->fcm_token]);

        return response()->json(['success' => true, 'message' => 'FCM token saved']);
    }
}
