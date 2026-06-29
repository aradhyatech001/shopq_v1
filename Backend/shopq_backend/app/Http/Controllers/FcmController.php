<?php

namespace App\Http\Controllers;

use App\Models\DeviceToken;
use Illuminate\Http\Request;

class FcmController extends Controller
{
    // POST  /fcm/token          (auth:sanctum  — user)
    // POST  /vendor/fcm/token   (auth:vendor)
    // POST  /delivery/fcm/token (auth:delivery)
    public function updateToken(Request $request)
    {
        $request->validate([
            'fcm_token'   => 'required|string|max:512',
            'platform'    => 'nullable|string|max:20',
            'app_version' => 'nullable|string|max:20',
            'language'    => 'nullable|string|max:10',
        ]);

        $account = $request->user();
        $token   = $request->fcm_token;

        // Legacy single-token column kept in sync during the transition.
        $account->forceFill(['fcm_token' => $token])->save();

        // Multi-device store. Keyed by the token itself, so the same token is
        // re-pointed to the current account if a device is handed over / re-used.
        DeviceToken::updateOrCreate(
            ['token' => $token],
            [
                'tokenable_type' => $account->getMorphClass(),
                'tokenable_id'   => $account->getKey(),
                'platform'       => $request->input('platform'),
                'app_version'    => $request->input('app_version'),
                'language'       => $request->input('language'),
                'is_valid'       => true,
                'last_seen_at'   => now(),
            ]
        );

        return response()->json(['success' => true, 'message' => 'FCM token saved']);
    }
}
