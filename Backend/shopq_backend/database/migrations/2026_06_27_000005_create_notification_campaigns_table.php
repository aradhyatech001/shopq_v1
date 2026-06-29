<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Admin-composed notification campaign (one row). Recipients are resolved at
 * send time from the audience criteria; per-recipient inbox rows live in
 * app_notifications (linked by campaign_id).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notification_campaigns', function (Blueprint $table) {
            $table->id();
            $table->string('type', 50)->default('custom');     // promo, festival, coupon…
            $table->string('audience', 20)->default('customers'); // customers|vendors|delivery
            $table->string('title');
            $table->text('body')->nullable();
            $table->string('image')->nullable();
            $table->json('data')->nullable();        // deeplink, button, ids
            $table->json('criteria')->nullable();    // segment definition

            // queue state machine
            $table->string('status', 20)->default('draft'); // draft|scheduled|sending|sent|cancelled|failed
            $table->timestamp('scheduled_at')->nullable();
            $table->string('recurrence', 50)->nullable();   // daily|weekly|monthly|cron expr
            $table->timestamp('next_run_at')->nullable();
            $table->timestamp('expiry_at')->nullable();

            // analytics counters
            $table->unsignedInteger('audience_count')->default(0);
            $table->unsignedInteger('sent_count')->default(0);
            $table->unsignedInteger('failed_count')->default(0);
            $table->unsignedInteger('read_count')->default(0);
            $table->unsignedInteger('click_count')->default(0);

            $table->unsignedBigInteger('created_by')->nullable();
            $table->timestamps();

            $table->index(['status', 'scheduled_at']);
            $table->index(['status', 'next_run_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notification_campaigns');
    }
};
