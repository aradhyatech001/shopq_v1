<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subscription_plans', function (Blueprint $table) {
            $table->id();
            $table->string('name');                      // Basic, Standard, Premium
            $table->string('duration_type');             // monthly | yearly
            $table->integer('duration_days');            // 30 | 365
            $table->decimal('price', 10, 2);
            $table->text('features')->nullable();        // JSON array of feature strings
            $table->integer('max_products')->default(0); // 0 = unlimited
            $table->boolean('is_active')->default(true);
            $table->integer('position')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscription_plans');
    }
};
