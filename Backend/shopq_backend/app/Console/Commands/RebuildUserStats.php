<?php

namespace App\Console\Commands;

use App\Services\UserStatsService;
use Illuminate\Console\Command;

/**
 * Refreshes the `user_stats` segmentation table. Schedule nightly.
 */
class RebuildUserStats extends Command
{
    protected $signature = 'notifications:rebuild-stats';
    protected $description = 'Rebuild the user_stats table used for notification segmentation';

    public function handle(UserStatsService $stats): int
    {
        $this->info('Rebuilding user_stats…');
        $count = $stats->rebuild();
        $this->info("Done. {$count} user stat rows.");
        return self::SUCCESS;
    }
}
