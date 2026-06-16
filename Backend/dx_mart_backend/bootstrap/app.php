<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->prepend(\Illuminate\Http\Middleware\HandleCors::class);

        // Pure API — never redirect unauthenticated requests to a web login page.
        // Returning null causes AuthenticationException to be thrown (no redirect),
        // which our withExceptions handler below converts to JSON 401.
        $middleware->redirectGuestsTo(fn () => null);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        // Only the API lives in this app, but guard anyway so nothing tries to
        // render an HTML error page for an API client (which the Flutter apps
        // then choke on as a `FormatException: <!DOCTYPE html>`).
        $isApi = fn ($request) => $request->is('api/*') || $request->expectsJson();

        // 401 — unauthenticated. (redirectGuestsTo => null makes the guard throw
        // this instead of redirecting to a non-existent "login" route.)
        $exceptions->render(function (\Illuminate\Auth\AuthenticationException $e, $request) use ($isApi) {
            if (!$isApi($request)) return null;
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated. Please log in.',
            ], 401);
        });

        // If route('login') is ever resolved and doesn't exist, treat as 401.
        $exceptions->render(function (\Symfony\Component\Routing\Exception\RouteNotFoundException $e, $request) use ($isApi) {
            if (!$isApi($request)) return null;
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated. Please log in.',
            ], 401);
        });

        // 422 — validation failed. Surface the field messages.
        $exceptions->render(function (\Illuminate\Validation\ValidationException $e, $request) use ($isApi) {
            if (!$isApi($request)) return null;
            return response()->json([
                'success' => false,
                'message' => $e->validator->errors()->first() ?: 'Validation failed.',
                'errors'  => $e->errors(),
            ], 422);
        });

        // 404 — model/route not found.
        $exceptions->render(function (\Illuminate\Database\Eloquent\ModelNotFoundException $e, $request) use ($isApi) {
            if (!$isApi($request)) return null;
            return response()->json(['success' => false, 'message' => 'Resource not found.'], 404);
        });
        $exceptions->render(function (\Symfony\Component\HttpKernel\Exception\NotFoundHttpException $e, $request) use ($isApi) {
            if (!$isApi($request)) return null;
            return response()->json(['success' => false, 'message' => 'Endpoint not found.'], 404);
        });

        // 405 — wrong HTTP method for the route.
        $exceptions->render(function (\Symfony\Component\HttpKernel\Exception\MethodNotAllowedHttpException $e, $request) use ($isApi) {
            if (!$isApi($request)) return null;
            return response()->json(['success' => false, 'message' => 'Method not allowed for this endpoint.'], 405);
        });

        // Catch-all — return the ACTUAL error message + status instead of an
        // opaque 500 HTML page. (App is internal, so exposing the message is fine.)
        $exceptions->render(function (\Throwable $e, $request) use ($isApi) {
            if (!$isApi($request)) return null;

            // Respect a status code the exception already carries (e.g. HttpException).
            $status = 500;
            if ($e instanceof \Symfony\Component\HttpKernel\Exception\HttpExceptionInterface) {
                $status = $e->getStatusCode();
            }

            $payload = [
                'success' => false,
                'message' => $e->getMessage() ?: 'Server error.',
                'error'   => class_basename($e),
            ];
            if (config('app.debug')) {
                $payload['file'] = $e->getFile() . ':' . $e->getLine();
            }
            return response()->json($payload, $status);
        });
    })->create();
