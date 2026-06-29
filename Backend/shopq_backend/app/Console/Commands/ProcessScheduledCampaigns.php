<?php

namespace App\Console\Commands;

use App\Jobs\DispatchCampaignJob;
use App\Models\NotificationCampaign;
use Illuminate\Console\Command;

/**
 * Fires due scheduled campaigns. Run every minute by the Laravel scheduler.
 *
 * A campaign is "due" when status=scheduled and next_run_at <= now (and not
 * past its expiry). Dispatching flips it to "sending" (so it isn't re-picked);
 * the DispatchCampaignJob then re-arms recurring campaigns or marks one-offs sent.
 */
class ProcessScheduledCampaigns extends Command
{
    protected $signature = 'notifications:process-scheduled';
    protected $description = 'Dispatch notification campaigns that are scheduled and due';

    public function handle(): int
    {
        $due = NotificationCampaign::query()
            ->where('status', NotificationCampaign::STATUS_SCHEDULED)
            ->whereNotNull('next_run_at')
            ->where('next_run_at', '<=', now())
            ->where(function ($q) {
                $q->whereNull('expiry_at')->orWhere('expiry_at', '>', now());
            })
            ->orderBy('next_run_at')
            ->limit(200)
            ->get();

        foreach ($due as $campaign) {
            // Claim it immediately so a slow/overlapping run can't double-dispatch.
            $claimed = NotificationCampaign::where('id', $campaign->id)
                ->where('status', NotificationCampaign::STATUS_SCHEDULED)
                ->update(['status' => NotificationCampaign::STATUS_SENDING]);

            if ($claimed) {
                DispatchCampaignJob::dispatch($campaign->id);
                $this->info("Dispatched campaign #{$campaign->id} ({$campaign->title})");
            }
        }

        if ($due->isEmpty()) {
            $this->line('No due campaigns.');
        }

        return self::SUCCESS;
    }
}
