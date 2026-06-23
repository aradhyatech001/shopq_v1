<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Illuminate\Http\Request;

class Authenticate extends Middleware
{
    /**
     * Always return null so Laravel sends a 401 JSON response
     * instead of trying to redirect to a named "login" route.
     */
    protected function redirectTo(Request $request): ?string
    {
        return null;
    }
}
