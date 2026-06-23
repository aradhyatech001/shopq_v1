<?php

namespace App\Http\Controllers;

use App\Models\AppSetting;
use Illuminate\Http\Request;

class AppConfigController extends Controller
{
    // ── GET /app-config (public) ──────────────────────
    // Returns all settings as a flat key => value map for the user app.
    public function get()
    {
        return response()->json([
            'success' => true,
            'config'  => AppSetting::pluck('value', 'key'),
        ]);
    }

    // ── POST /admin/app-config (admin) ────────────────
    // Body: any subset of setting keys → values. Upserts each.
    public function update(Request $request)
    {
        $data = $request->all();
        if (empty($data)) {
            return response()->json(['success' => false, 'message' => 'No settings provided']);
        }

        foreach ($data as $key => $value) {
            // Only allow scalar values; ignore framework/meta keys.
            if (is_array($value)) continue;
            AppSetting::updateOrCreate(['key' => $key], ['value' => (string) $value]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Settings updated',
            'config'  => AppSetting::pluck('value', 'key'),
        ]);
    }
}
