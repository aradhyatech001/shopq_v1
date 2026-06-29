<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

abstract class Controller
{
    /**
     * Resolve the delivery pincode for the current request.
     * Prefers an explicit `pincode_id` query param (sent by the user app once a
     * location is chosen); falls back to the authenticated user's saved pincode.
     * Returns 0 when no location is set — callers then skip pincode filtering.
     */
    protected function resolvePincodeId(Request $request): int
    {
        $pid = (int) ($request->query('pincode_id') ?? 0);
        if ($pid > 0) return $pid;

        $user = $request->user();
        if ($user && !empty($user->pincode_id)) return (int) $user->pincode_id;

        return 0;
    }

    /**
     * Safely build a storage path for user-supplied filenames.
     *
     * Strips any directory components from the name (prevents path traversal)
     * and rejects files whose extension is not in the allowed image set.
     * Returns null when the name fails validation so callers can reject the request.
     */
    protected function safeStorePath(string $dir, ?string $rawName): ?string
    {
        if (!$rawName) return null;
        $name = basename($rawName); // strip any ../ path components
        $ext  = strtolower(pathinfo($name, PATHINFO_EXTENSION));
        if (!in_array($ext, ['jpg', 'jpeg', 'png', 'gif', 'webp'], true)) {
            return null;
        }
        // Prefix a random id to avoid name collisions between vendors.
        return $dir . '/' . uniqid() . '_' . $name;
    }

    /**
     * Convert a relative storage path to a full public URL.
     * Returns null if path is empty.
     */
    /**
     * Reduce any image value to a relative storage path (for STORING). Handles
     * raw paths ("products/x.png") and absolute URLs that baked in a host and a
     * /storage/ or /api/files/ prefix. Returns null if empty.
     */
    protected function relativeImagePath(?string $path): ?string
    {
        if (!$path) return null;
        if (str_starts_with($path, 'http')) {
            $path = preg_replace('#^https?://[^/]+/(?:storage|api/files)/#', '', $path);
        }
        $path = ltrim($path, '/');
        return $path !== '' ? $path : null;
    }

    protected function imageUrl(?string $path): ?string
    {
        $path = $this->relativeImagePath($path);
        if (!$path) return null;

        // Build the URL against the CURRENT request host (localhost, LAN IP,
        // 10.0.2.2 emulator, …) rather than a hardcoded APP_URL, so images load
        // for whichever host the client used to reach the API.
        //
        // Serve via the STATIC /storage/ path (symlinked to storage/app/public),
        // NOT the PHP /api/files/ route. The PHP route returns 502 on browsers:
        // Flutter web (CanvasKit) sends an `Origin` header which routes the
        // request through the full middleware + file-streaming stack and crashes
        // php-fpm. Static files are served directly by the web server and never
        // hit PHP, so they are stable and cacheable. CORS headers for these
        // static images are added in storage/app/public/.htaccess so CanvasKit
        // can load them cross-origin. (The /api/files/ route is kept as a
        // fallback for any legacy cached URLs.)
        return url('/storage/' . $path);
    }
}
