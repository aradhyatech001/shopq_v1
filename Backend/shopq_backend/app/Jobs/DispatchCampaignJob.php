<?php

namespace App\Jobs;

use App\Models\NotificationCampaign;
use App\Services\AudienceResolver;
use App\Services\FcmService;
use App\Services\RecurrenceService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

/**
 * Resolves a campaign's audience and fans it out into many small
 * SendNotificationBatchJob jobs (chunked), so no single job loads millions of
 * recipients and the work parallelises across workers.
 */
class DispatchCampaignJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;
    public int $chunkSize = 200;

    /**
     * @param bool $sync  Run the per-chunk send jobs inline (no queue worker
     *                    needed) — used by the admin "Send now" path.
     */
    public function __construct(public int $campaignId, public bool $sync = false) {}

    public function handle(AudienceResolver $resolver, FcmService $fcm): void
    {
        $campaign = NotificationCampaign::find($this->campaignId);
        if (!$campaign || in_array($campaign->status, [
            NotificationCampaign::STATUS_CANCELLED,
            NotificationCampaign::STATUS_SENT,
        ], true)) {
            return;
        }

        $campaign->update(['status' => NotificationCampaign::STATUS_SENDING]);

        $criteria = $campaign->criteria ?? [];

        if ($campaign->delivery_mode === 'topic') {
            // Broadcast to FCM topic(s) — one API call each, no per-recipient
            // fan-out / inbox. Best for very large all-users / pincode blasts.
            $topics = $resolver->topicsFor($campaign->audience, $criteria);
            $sent = 0;
            foreach ($topics as $topic) {
                if ($fcm->sendToTopic($topic, $campaign->title, (string) $campaign->body,
                    array_merge($campaign->data ?? [], ['type' => $campaign->type]))) {
                    $sent++;
                }
            }
            $campaign->update([
                'audience_count' => count($topics),
                'sent_count'     => $campaign->sent_count + $sent,
            ]);
        } else {
            // Token mode — per-recipient inbox + push, full analytics.
            $query = $resolver->recipientQuery($campaign->audience, $criteria);
            $campaign->update(['audience_count' => (clone $query)->count()]);

            $query->orderBy('rid')->chunk($this->chunkSize, function ($rows) use ($campaign) {
                $ids = array_map(fn($r) => $r->rid, $rows->all());
                if ($this->sync) {
                    // Run inline so a campaign sends even without a queue worker.
                    SendNotificationBatchJob::dispatchSync($campaign->id, $ids);
                } else {
                    SendNotificationBatchJob::dispatch($campaign->id, $ids);
                }
            });
        }

        // All batches queued. A recurring campaign re-arms itself for the next
        // occurrence (and stays "scheduled"); a one-off is marked "sent".
        $next = RecurrenceService::next($campaign->recurrence, $campaign->next_run_at ?? now());
        $expired = $campaign->expiry_at && $next && $next->greaterThan($campaign->expiry_at);

        if ($next && !$expired) {
            $campaign->update([
                'status'      => NotificationCampaign::STATUS_SCHEDULED,
                'next_run_at' => $next,
            ]);
        } else {
            $campaign->update(['status' => NotificationCampaign::STATUS_SENT]);
        }
    }
}
