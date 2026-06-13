<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('sub_category', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('main_category_id');
            $table->string('name');
            $table->string('image_url')->nullable();
            $table->string('icon_url')->nullable();
            $table->integer('position')->default(0);
            $table->boolean('is_active')->default(1);
            $table->timestamp('created_at')->useCurrent();
            $table->foreign('main_category_id')->references('id')->on('main_category')->onDelete('cascade');
        });

        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('vendor_id')->nullable();
            $table->string('name', 100);
            $table->text('description');
            $table->unsignedBigInteger('main_category_id')->nullable();
            $table->unsignedBigInteger('subcategory_id')->nullable();
            $table->unsignedBigInteger('brand_id')->nullable();
            $table->unsignedBigInteger('sub_category_id')->nullable();
            $table->string('types', 100)->default('normal');
            $table->string('image_url')->nullable();
            $table->string('icon_url')->nullable();
            $table->timestamps();
            $table->foreign('main_category_id')->references('id')->on('main_category')->onDelete('set null');
            $table->foreign('subcategory_id')->references('id')->on('sub_category')->onDelete('set null');
            $table->foreign('brand_id')->references('id')->on('main_category')->onDelete('set null');
        });
        Schema::create('product_variants', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('product_id');
            $table->string('name');
            $table->decimal('price', 10, 2)->default(0);
            $table->decimal('selling_price', 10, 2)->default(0);
            $table->decimal('wholesale_price', 10, 2)->default(0);
            $table->integer('stock')->default(0);
            $table->timestamps();
            $table->foreign('product_id')->references('id')->on('products')->onDelete('cascade');
        });
        Schema::create('product_info', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('product_id');
            $table->string('attribute');
            $table->text('value');
            $table->timestamps();
            $table->foreign('product_id')->references('id')->on('products')->onDelete('cascade');
        });
        Schema::create('product_highlights', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('product_id');
            $table->string('attribute');
            $table->text('value');
            $table->timestamps();
            $table->foreign('product_id')->references('id')->on('products')->onDelete('cascade');
        });
        Schema::create('product_images', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('product_id');
            $table->text('image_url');
            $table->timestamps();
            $table->foreign('product_id')->references('id')->on('products')->onDelete('cascade');
        });
    }
    public function down(): void {
        Schema::dropIfExists('product_images');
        Schema::dropIfExists('product_highlights');
        Schema::dropIfExists('product_info');
        Schema::dropIfExists('product_variants');
        Schema::dropIfExists('products');
        Schema::dropIfExists('sub_category');
    }
};
