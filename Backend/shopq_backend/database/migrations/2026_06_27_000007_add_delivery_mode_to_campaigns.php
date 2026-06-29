<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * delivery_mode: 'token' = per-recipient fan-out (inbox + analytics),
 *                'topic'  = single FCM topic broadcast (fast, push-only).
 */
return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('notification_campaigns', 'delivery_mode')) {
            return;
        }
        Schema::table('notification_campaigns', function (Blueprint $table) {
            $table->string('delivery_mode', 10)->default('token')->after('audience');
        });
    }

    public function down(): void
    {
        Schema::table('notification_campaigns', function (Blueprint $table) {
            $table->dropColumn('delivery_mode');
        });
    }
};
