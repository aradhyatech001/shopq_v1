<?php

namespace App\Services;

use App\Models\DeviceToken;
use Google\Client as GoogleClient;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Firebase Cloud Messaging sender using the HTTP v1 API (OAuth2 service
 * account). The legacy server-key API was shut down by Google in 2024, so v1
 * is the only supported path.
 *
 * Production notes:
 *  - The OAuth access token is cached and reused (valid ~1h) so bulk sends
 *    don't re-authenticate on every message.
 *  - Tokens FCM reports as UNREGISTERED are flagged so callers can purge them.
 *
 * Setup:
 *  - Put the service-account JSON at storage/app/json/firebase-credentials.json
 *  - Set FCM_PROJECT_ID in .env (Firebase console → Project settings).
 */
class FcmService
{
    private string $projectId;
    private string $credentialsPath;

    /** Cached OAuth access token, shared across sends within a process. */
    private static ?string $accessToken = null;
    private static int $accessTokenExpiry = 0;

    public function __construct()
    {
        $this->projectId       = config('services.fcm.project_id', '');
        $this->credentialsPath = storage_path('app/json/firebase-credentials.json');
    }

    /** Whether credentials + project id are present (used by the test command). */
    public function isConfigured(): bool
    {
        return $this->projectId !== '' && file_exists($this->credentialsPath);
    }

    /**
     * Send a push to a single FCM device token. Returns true on success.
     * Errors are logged, never thrown.
     *
     * @param  array<string,string>  $data  Extra key-value pairs (data payload)
     */
    public function send(string $fcmToken, string $title, string $body, array $data = []): bool
    {
        return $this->sendRaw($fcmToken, $title, $body, $data)['ok'];
    }

    /**
     * Send to all of a notifiable account's (User / Vendor / DeliveryBoy)
     * devices. Uses the multi-device `device_tokens` table, falling back to the
     * legacy `fcm_token` column for accounts not yet migrated. Dead tokens are
     * flagged invalid (device_tokens) / cleared (legacy column) automatically.
     *
     * Returns true if at least one device accepted the push.
     */
    public function sendToModel(?Model $notifiable, string $title, string $body, array $data = []): bool
    {
        if (!$notifiable) {
            return false;
        }

        // Prefer the multi-device store; fall back to the legacy column.
        $tokens = method_exists($notifiable, 'validDeviceTokens')
            ? $notifiable->validDeviceTokens()->pluck('token')->all()
            : [];

        $legacy = $notifiable->getAttribute('fcm_token');
        if ($legacy && !in_array($legacy, $tokens, true)) {
            $tokens[] = $legacy;
        }

        $tokens = array_values(array_unique(array_filter($tokens)));
        if (empty($tokens)) {
            return false;
        }

        $anyOk = false;
        foreach ($tokens as $token) {
            $result = $this->sendRaw($token, $title, $body, $data);
            $anyOk  = $anyOk || $result['ok'];

            if ($result['invalidToken']) {
                DeviceToken::where('token', $token)->update(['is_valid' => false]);
                if ($legacy === $token) {
                    $notifiable->forceFill(['fcm_token' => null])->save();
                }
            }
        }

        return $anyOk;
    }

    /**
     * Broadcast to an FCM topic in a single API call — efficient for huge
     * audiences (all users / a whole pincode). Devices must be subscribed to
     * the topic client-side. No per-recipient inbox/analytics (broadcast).
     */
    public function sendToTopic(string $topic, string $title, string $body, array $data = []): bool
    {
        if (!$this->isConfigured()) {
            Log::warning('FCM: credentials missing for topic send');
            return false;
        }

        try {
            $accessToken = $this->accessToken();
            if (!$accessToken) {
                return false;
            }

            $response = Http::withToken($accessToken)->post(
                "https://fcm.googleapis.com/v1/projects/{$this->projectId}/messages:send",
                [
                    'message' => [
                        'topic'        => self::sanitizeTopic($topic),
                        'notification' => ['title' => $title, 'body' => $body],
                        'data'         => array_map('strval', $data),
                    ],
                ]
            );

            if ($response->successful()) {
                return true;
            }
            Log::error('FCM: topic send failed', [
                'topic' => $topic,
                'http'  => $response->status(),
                'body'  => $response->body(),
            ]);
            return false;
        } catch (\Throwable $e) {
            Log::error('FCM: topic exception', ['error' => $e->getMessage()]);
            return false;
        }
    }

    /** FCM topic names allow only [a-zA-Z0-9-_.~%]. */
    public static function sanitizeTopic(string $topic): string
    {
        return preg_replace('/[^a-zA-Z0-9_.\-~%]/', '_', $topic);
    }

    /**
     * Send the same notification to many tokens. Returns the tokens FCM
     * rejected as unregistered, so the caller can remove them from storage.
     *
     * @param  string[]  $tokens
     * @return string[]  invalid (unregistered) tokens
     */
    public function sendToMany(array $tokens, string $title, string $body, array $data = []): array
    {
        $invalid = [];
        foreach (array_unique(array_filter($tokens)) as $token) {
            $result = $this->sendRaw($token, $title, $body, $data);
            if ($result['invalidToken']) {
                $invalid[] = $token;
            }
        }
        return $invalid;
    }

    /**
     * @return array{ok: bool, invalidToken: bool}
     */
    private function sendRaw(string $fcmToken, string $title, string $body, array $data): array
    {
        if (!$this->isConfigured()) {
            Log::warning('FCM: credentials file missing or FCM_PROJECT_ID not set');
            return ['ok' => false, 'invalidToken' => false];
        }

        try {
            $accessToken = $this->accessToken();
            if (!$accessToken) {
                return ['ok' => false, 'invalidToken' => false];
            }

            $response = Http::withToken($accessToken)->post(
                "https://fcm.googleapis.com/v1/projects/{$this->projectId}/messages:send",
                [
                    'message' => [
                        'token'        => $fcmToken,
                        'notification' => ['title' => $title, 'body' => $body],
                        'data'         => array_map('strval', $data),
                    ],
                ]
            );

            if ($response->successful()) {
                return ['ok' => true, 'invalidToken' => false];
            }

            // A dead token (app uninstalled / expired / never existed) should be
            // purged. FCM v1 reports this as error.status NOT_FOUND/UNREGISTERED
            // AND error.details[].errorCode == UNREGISTERED (the authoritative
            // field). INVALID_ARGUMENT can also mean a bad payload, so we don't
            // purge on it.
            $errStatus = $response->json('error.status');
            $errCode   = $response->json('error.details.0.errorCode');
            $invalid   = $errCode === 'UNREGISTERED'
                || in_array($errStatus, ['UNREGISTERED', 'NOT_FOUND'], true);

            Log::error('FCM: send failed', [
                'http'   => $response->status(),
                'status' => $errStatus,
                'code'   => $errCode,
                'body'   => $response->body(),
            ]);

            return ['ok' => false, 'invalidToken' => $invalid];
        } catch (\Throwable $e) {
            Log::error('FCM: exception', ['error' => $e->getMessage()]);
            return ['ok' => false, 'invalidToken' => false];
        }
    }

    /**
     * Cached service-account OAuth access token. Refreshed ~5 minutes before it
     * actually expires so a request never uses a token that lapses mid-flight.
     */
    private function accessToken(): ?string
    {
        if (self::$accessToken !== null && time() < self::$accessTokenExpiry) {
            return self::$accessToken;
        }

        $client = new GoogleClient();
        $client->setAuthConfig($this->credentialsPath);
        $client->addScope('https://www.googleapis.com/auth/firebase.messaging');
        $client->refreshTokenWithAssertion();
        $tokenData = $client->getAccessToken();

        $token = $tokenData['access_token'] ?? null;
        if (!$token) {
            Log::error('FCM: failed to obtain access token');
            return null;
        }

        $expiresIn = (int) ($tokenData['expires_in'] ?? 3600);
        self::$accessToken       = $token;
        self::$accessTokenExpiry = time() + max(60, $expiresIn - 300);

        return $token;
    }
}
