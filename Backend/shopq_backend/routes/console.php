<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// ── Notification system schedule ───────────────────────────────────────────
// Fire due / recurring campaigns every minute.
Schedule::command('notifications:process-scheduled')
    ->everyMinute()
    ->withoutOverlapping();

// Refresh the segmentation table nightly.
Schedule::command('notifications:rebuild-stats')
    ->dailyAt('03:00')
    ->withoutOverlapping();
