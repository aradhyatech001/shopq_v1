<?php

namespace App\Services;

use Google\Client as GoogleClient;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FcmService
{
    private string $projectId;
    private string $credentialsPath;

    public function __construct()
    {
        $this->projectId       = config('services.fcm.project_id', '');
        $this->credentialsPath = storage_path('app/json/firebase-credentials.json');
    }

    /**
     * Send a push notification to a single FCM device token.
     * Returns true on success, false on any failure (errors are logged, not thrown).
     *
     * @param  array<string,string>  $data  Extra key-value pairs in the data payload
     */
    public function send(string $fcmToken, string $title, string $body, array $data = []): bool
    {
        if (!$this->projectId || !file_exists($this->credentialsPath)) {
            Log::warning('FCM: credentials file missing or FCM_PROJECT_ID not set');
            return false;
        }

        try {
            $client = new GoogleClient();
            $client->setAuthConfig($this->credentialsPath);
            $client->addScope('https://www.googleapis.com/auth/firebase.messaging');
            $client->refreshTokenWithAssertion();
            $tokenData   = $client->getAccessToken();
            $accessToken = $tokenData['access_token'] ?? null;

            if (!$accessToken) {
                Log::error('FCM: failed to obtain access token');
                return false;
            }

            $payload = [
                'message' => [
                    'token'        => $fcmToken,
                    'notification' => ['title' => $title, 'body' => $body],
                    'data'         => array_map('strval', $data),
                ],
            ];

            $response = Http::withToken($accessToken)
                ->post(
                    "https://fcm.googleapis.com/v1/projects/{$this->projectId}/messages:send",
                    $payload
                );

            if ($response->failed()) {
                Log::error('FCM: send failed', [
                    'status' => $response->status(),
                    'body'   => $response->body(),
                ]);
                return false;
            }

            return true;
        } catch (\Throwable $e) {
            Log::error('FCM: exception', ['error' => $e->getMessage()]);
            return false;
        }
    }
}
