<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Multi-device FCM token store. Replaces the single `fcm_token` column with a
 * polymorphic table so a User / Vendor / DeliveryBoy can have several devices,
 * and dead tokens can be flagged individually.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('device_tokens', function (Blueprint $table) {
            $table->id();
            // tokenable_type + tokenable_id  → User / Vendor / DeliveryBoy
            $table->morphs('tokenable');
            $table->string('token', 512)->unique();
            $table->string('platform', 20)->nullable();      // android | ios | web
            $table->string('app_version', 20)->nullable();
            $table->string('language', 10)->nullable();
            $table->boolean('is_valid')->default(true);
            $table->timestamp('last_seen_at')->nullable();
            $table->timestamps();

            $table->index(['is_valid', 'last_seen_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('device_tokens');
    }
};
