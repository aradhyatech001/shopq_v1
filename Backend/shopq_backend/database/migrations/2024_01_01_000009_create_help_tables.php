<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('help_call', function (Blueprint $table) {
            $table->id();
            $table->string('call_help');
            $table->timestamps();
        });
        Schema::create('help_email', function (Blueprint $table) {
            $table->id();
            $table->string('email');
            $table->timestamps();
        });
        Schema::create('help_whatsapp', function (Blueprint $table) {
            $table->id();
            $table->string('whatsapp_no');
            $table->timestamps();
        });
    }
    public function down(): void {
        Schema::dropIfExists('help_call');
        Schema::dropIfExists('help_email');
        Schema::dropIfExists('help_whatsapp');
    }
};
