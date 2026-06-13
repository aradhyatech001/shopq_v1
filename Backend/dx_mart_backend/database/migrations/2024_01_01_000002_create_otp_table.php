<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('otp_table', function (Blueprint $table) {
            $table->id();
            $table->string('email')->unique();
            $table->string('otp');
            $table->bigInteger('expiry');
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('otp_table'); }
};
