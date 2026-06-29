<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Tracks CTA/deeplink taps per notification so campaign click_count is counted
 * once per recipient (distinct from read_count).
 */
return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('app_notifications', 'clicked_at')) {
            return;
        }
        Schema::table('app_notifications', function (Blueprint $table) {
            $table->timestamp('clicked_at')->nullable()->after('read_at');
        });
    }

    public function down(): void
    {
        Schema::table('app_notifications', function (Blueprint $table) {
            $table->dropColumn('clicked_at');
        });
    }
};
