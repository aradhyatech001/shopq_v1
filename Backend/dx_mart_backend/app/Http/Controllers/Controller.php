<?php

namespace App\Http\Controllers;

abstract class Controller
{
    /**
     * Convert a relative storage path to a full public URL.
     * Returns null if path is empty.
     */
    protected function imageUrl(?string $path): ?string
    {
        if (!$path) return null;

        // Reduce any stored value to a relative storage path. Handles both raw
        // paths ("banner/x.png") and legacy absolute URLs that baked in a host
        // and a /storage/ or /api/files/ prefix.
        if (str_starts_with($path, 'http')) {
            $path = preg_replace('#^https?://[^/]+/(?:storage|api/files)/#', '', $path);
        }
        $path = ltrim($path, '/');

        // Build the URL against the CURRENT request host (localhost, LAN IP,
        // 10.0.2.2 emulator, …) rather than a hardcoded APP_URL, so images load
        // for whichever host the client used to reach the API.
        return url('/api/files/' . $path);
    }
}
