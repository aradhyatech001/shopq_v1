<?php

namespace App\Services;

use App\Models\AppNotification;
use Illuminate\Database\Eloquent\Model;

/**
 * Single entry point for sending a notification to one account: it persists an
 * in-app inbox row (Notification Center) AND delivers an FCM push to every one
 * of the account's devices.
 *
 * Transactional callers (orders, payments, settlements, assignments) should use
 * this instead of calling FcmService directly, so every push is also visible in
 * the app's notification list.
 */
class NotificationService
{
    public function __construct(private FcmService $fcm) {}

    /**
     * @param  array<string,mixed>  $data   Deep-link / ids / button payload
     */
    public function notify(
        ?Model $notifiable,
        string $type,
        string $title,
        string $body,
        array $data = [],
        ?string $image = null,
        ?int $campaignId = null,
    ): ?AppNotification {
        if (!$notifiable) {
            return null;
        }

        $record = AppNotification::create([
            'notifiable_type' => $notifiable->getMorphClass(),
            'notifiable_id'   => $notifiable->getKey(),
            'campaign_id'     => $campaignId,
            'type'            => $type,
            'title'           => $title,
            'body'            => $body,
            'image'           => $image,
            'data'            => $data,
        ]);

        // Push to all of the account's devices. The data payload carries the
        // type + inbox id so the app can deep-link and mark-read on tap.
        $this->fcm->sendToModel(
            $notifiable,
            $title,
            $body,
            array_merge(
                array_map(fn($v) => (string) $v, $data),
                ['type' => $type, 'notification_id' => (string) $record->id],
            ),
        );

        return $record;
    }
}
