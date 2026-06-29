<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Denormalized per-customer stats used for fast notification segmentation.
 * Refreshed from users + orders + pincodes by UserStatsService, so a campaign
 * audience resolves with a single indexed query instead of scanning orders.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_stats', function (Blueprint $table) {
            $table->unsignedBigInteger('user_id')->primary();

            // Geo (resolved from the user's pincode).
            $table->unsignedBigInteger('pincode_id')->nullable();
            $table->string('pincode_code', 20)->nullable();
            $table->string('area_name')->nullable();
            $table->string('city', 120)->nullable();
            $table->string('state', 120)->nullable();
            $table->string('language', 10)->nullable();

            // Behavior.
            $table->timestamp('registered_at')->nullable();
            $table->unsignedInteger('total_orders')->default(0);
            $table->timestamp('last_order_at')->nullable();
            $table->boolean('has_pending')->default(false);
            $table->boolean('has_cancelled')->default(false);
            $table->boolean('has_completed')->default(false);
            $table->timestamp('last_active_at')->nullable();

            $table->timestamps();

            $table->index('city');
            $table->index('state');
            $table->index('pincode_code');
            $table->index('total_orders');
            $table->index('last_order_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_stats');
    }
};
