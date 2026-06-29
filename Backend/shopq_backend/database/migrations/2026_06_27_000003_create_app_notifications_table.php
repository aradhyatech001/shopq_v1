<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * In-app notification inbox (the "Notification Center"). One row per recipient
 * per notification. Named `app_notifications` so it does not collide with
 * Laravel's built-in `notifications` table used by the Notifiable trait.
 */
return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('app_notifications')) {
            return; // Already created by an earlier partial run.
        }
        Schema::create('app_notifications', function (Blueprint $table) {
            $table->id();
            $table->morphs('notifiable');                 // User / Vendor / DeliveryBoy
            $table->unsignedBigInteger('campaign_id')->nullable()->index();
            $table->string('type', 50)->default('custom'); // order_update, promo, …
            $table->string('title');
            $table->text('body')->nullable();
            $table->string('image')->nullable();
            $table->json('data')->nullable();              // deeplink, button, ids…
            $table->timestamp('read_at')->nullable();
            $table->timestamp('archived_at')->nullable();
            $table->timestamps();

            // Fast "my unread, newest first" queries.
            $table->index(['notifiable_type', 'notifiable_id', 'read_at']);
            $table->index(['notifiable_type', 'notifiable_id', 'archived_at', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('app_notifications');
    }
};
