<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('district', function (Blueprint $table) {
            $table->id();
            $table->string('district_name');
            $table->timestamps();
        });
        Schema::create('city', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('district_id');
            $table->string('city_name');
            $table->timestamps();
            $table->foreign('district_id')->references('id')->on('district')->onDelete('cascade');
        });
    }
    public function down(): void {
        Schema::dropIfExists('city');
        Schema::dropIfExists('district');
    }
};
