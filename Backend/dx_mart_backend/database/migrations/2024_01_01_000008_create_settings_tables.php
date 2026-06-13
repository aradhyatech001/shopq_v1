<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('delivery_charge', function (Blueprint $table) {
            $table->id();
            $table->decimal('amount', 10, 2)->default(0);
            $table->timestamps();
        });
        Schema::create('free_delivey', function (Blueprint $table) {
            $table->id();
            $table->decimal('amount', 10, 2)->default(0);
            $table->timestamps();
        });
        Schema::create('handling_charge', function (Blueprint $table) {
            $table->id();
            $table->decimal('amount', 10, 2)->default(0);
            $table->timestamps();
        });
        Schema::create('deliver_time', function (Blueprint $table) {
            $table->id();
            $table->string('time');
            $table->timestamps();
        });
        Schema::create('minimum_order_amout', function (Blueprint $table) {
            $table->id();
            $table->decimal('amount', 10, 2)->default(0);
            $table->timestamps();
        });
    }
    public function down(): void {
        Schema::dropIfExists('delivery_charge');
        Schema::dropIfExists('free_delivey');
        Schema::dropIfExists('handling_charge');
        Schema::dropIfExists('deliver_time');
        Schema::dropIfExists('minimum_order_amout');
    }
};
