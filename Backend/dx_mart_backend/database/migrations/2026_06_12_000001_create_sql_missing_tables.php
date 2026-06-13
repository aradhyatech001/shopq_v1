<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('delivery_boy', function (Blueprint $table) {
            $table->id();
            $table->string('name', 80);
            $table->string('email', 80);
            $table->string('mobile', 12);
            $table->string('pin_code', 10);
            $table->string('address', 200);
            $table->string('password', 100);
            $table->string('date_time', 50);
            $table->string('status', 30);
        });

        // Note: delivery_charge table already exists from settings migration.
        // The typo "delivey_charge" has been intentionally removed.

        Schema::create('flash_deals', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('product_id');
            $table->unsignedBigInteger('variant_id')->nullable();
            $table->string('title')->nullable();
            $table->decimal('deal_price', 10, 2);
            $table->dateTime('start_time');
            $table->dateTime('end_time');
            $table->boolean('is_active')->default(true);
            $table->timestamp('created_at')->useCurrent();

            $table->foreign('product_id')->references('id')->on('products')->onDelete('cascade');
            $table->foreign('variant_id')->references('id')->on('product_variants')->onDelete('cascade');
        });

        Schema::create('home_sections', function (Blueprint $table) {
            $table->id();
            $table->string('title', 255);
            $table->string('emoji', 10)->nullable();
            $table->enum('section_type', ['product_type', 'sub_category_grid', 'banner', 'brand_grid'])->default('product_type');
            $table->string('product_type', 100)->nullable();
            $table->unsignedBigInteger('main_category_id')->nullable();
            $table->integer('product_limit')->default(10);
            $table->integer('position')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamp('created_at')->useCurrent();

            $table->foreign('main_category_id')->references('id')->on('main_category')->onDelete('set null');
        });

        Schema::create('product_tags', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('product_id');
            $table->string('tag', 100);

            $table->foreign('product_id')->references('id')->on('products')->onDelete('cascade');
        });

        Schema::create('vendor_tokens', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('vendor_id');
            $table->string('token', 255);
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('expires_at')->nullable();

            $table->foreign('vendor_id')->references('id')->on('vendors')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vendor_tokens');
        Schema::dropIfExists('product_tags');
        Schema::dropIfExists('home_sections');
        Schema::dropIfExists('flash_deals');
        // delivey_charge table was a typo — already removed from up()
        Schema::dropIfExists('delivery_boy');
    }
};
