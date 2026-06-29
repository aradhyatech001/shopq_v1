<?php

namespace App\Console\Commands;

use App\Models\DeliveryBoy;
use App\Models\User;
use App\Models\Vendor;
use App\Services\FcmService;
use Illuminate\Console\Command;

/**
 * Send a test push notification to verify the FCM setup end-to-end.
 *
 * Examples:
 *   php artisan fcm:test --token=DEVICE_FCM_TOKEN
 *   php artisan fcm:test --user=5
 *   php artisan fcm:test --vendor=3 --title="Hi" --body="Test from server"
 *   php artisan fcm:test --delivery=2
 */
class FcmTest extends Command
{
    protected $signature = 'fcm:test
        {--token=   : Raw device FCM token to send to}
        {--user=    : Send to a User id (uses their stored fcm_token)}
        {--vendor=  : Send to a Vendor id}
        {--delivery=: Send to a DeliveryBoy id}
        {--title=ShopQ test : Notification title}
        {--body=This is a test push from the server : Notification body}';

    protected $description = 'Send a test FCM push notification (verifies credentials + delivery)';

    public function handle(FcmService $fcm): int
    {
        if (!$fcm->isConfigured()) {
            $this->error('FCM is NOT configured.');
            $this->line('  • Set FCM_PROJECT_ID in .env');
            $this->line('  • Put the service-account JSON at storage/app/json/firebase-credentials.json');
            return self::FAILURE;
        }
        $this->info('FCM is configured ✔');

        $token = $this->option('token');
        $owner = null;

        if (!$token && $this->option('user')) {
            $owner = User::find($this->option('user'));
        } elseif (!$token && $this->option('vendor')) {
            $owner = Vendor::find($this->option('vendor'));
        } elseif (!$token && $this->option('delivery')) {
            $owner = DeliveryBoy::find($this->option('delivery'));
        }

        if (!$token && $owner) {
            $token = $owner->getAttribute('fcm_token');
            if (!$token) {
                $this->error('That account has no stored fcm_token (app not opened / not logged in?).');
                return self::FAILURE;
            }
        }

        if (!$token) {
            $this->error('Provide a target: --token=, --user=, --vendor= or --delivery=');
            return self::FAILURE;
        }

        $this->line('Sending test notification…');
        $ok = $fcm->send(
            $token,
            (string) $this->option('title'),
            (string) $this->option('body'),
            ['type' => 'test', 'sent_at' => (string) now()->timestamp],
        );

        if ($ok) {
            $this->info('✔ Sent successfully. Check the device.');
            return self::SUCCESS;
        }

        $this->error('Send failed - see storage/logs/laravel.log for the FCM error details.');
        return self::FAILURE;
    }
}
