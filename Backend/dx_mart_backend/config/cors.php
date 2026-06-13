<?php

return [
    'paths' => ['api/*', 'storage/*', 'sanctum/csrf-cookie', '*'],

    'allowed_methods' => ['*'],

    // NOTE: With `supports_credentials => true` (required by the cookie-based
    // admin panel), the browser rejects a wildcard `Access-Control-Allow-Origin: *`.
    // php-cors also refuses to emit any origin header if `*` is listed here while
    // credentials are enabled. So we leave this empty and reflect the request
    // origin via `allowed_origins_patterns` below instead.
    'allowed_origins' => [],

    // Reflect any requesting origin. This echoes the caller's Origin back in
    // `Access-Control-Allow-Origin`, which is what browsers require for
    // credentialed (cookie) requests. For production, tighten this to your
    // actual panel domains, e.g.:
    //   'allowed_origins' => ['https://admin.dxmart.com', 'https://vendor.dxmart.com'],
    //   'allowed_origins_patterns' => ['#^http://localhost(:\d+)?$#'],
    'allowed_origins_patterns' => ['#^.*$#'],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    // Required so the admin panel's session cookie (laravel_session) is honored
    // on cross-origin requests. Token-based (Sanctum Bearer) clients are
    // unaffected.
    'supports_credentials' => true,
];
