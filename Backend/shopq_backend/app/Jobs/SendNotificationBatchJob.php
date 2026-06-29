<?php

namespace App\Jobs;

use App\Models\DeliveryBoy;
use App\Models\NotificationCampaign;
use App\Models\User;
use App\Models\Vendor;
use App\Services\NotificationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\DB;

/**
 * Delivers one campaign to a chunk of recipients: writes each one's in-app
 * inbox row and pushes to all their devices (via NotificationService), then
 * updates the campaign's sent/failed counters atomically.
 */
class SendNotificationBatchJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;
    public int $backoff = 30;

    /** @param int[] $recipientIds */
    public function __construct(public int $campaignId, public array $recipientIds) {}

    public function handle(NotificationService $notifications): void
    {
        $campaign = NotificationCampaign::find($this->campaignId);
        if (!$campaign || empty($this->recipientIds)) {
            return;
        }

        $modelClass = match ($campaign->audience) {
            'vendors'  => Vendor::class,
            'delivery' => DeliveryBoy::class,
            default    => User::class,
        };

        $models = $modelClass::query()
            ->whereIn((new $modelClass)->getKeyName(), $this->recipientIds)
            ->get();

        $sent = 0;
        $failed = 0;
        foreach ($models as $model) {
            $record = $notifications->notify(
                $model,
                $campaign->type,
                $campaign->title,
                (string) $campaign->body,
                $campaign->data ?? [],
                $campaign->image,
                $campaign->id,
            );
            $record ? $sent++ : $failed++;
        }

        NotificationCampaign::where('id', $campaign->id)->update([
            'sent_count'   => DB::raw("sent_count + {$sent}"),
            'failed_count' => DB::raw("failed_count + {$failed}"),
        ]);
    }
}
