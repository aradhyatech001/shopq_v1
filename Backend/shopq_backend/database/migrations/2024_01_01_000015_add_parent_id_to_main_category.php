<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('main_category', function (Blueprint $table) {
            if (!Schema::hasColumn('main_category', 'parent_id')) {
                $table->unsignedBigInteger('parent_id')->nullable()->default(null)->after('id');
                $table->foreign('parent_id')
                    ->references('id')
                    ->on('main_category')
                    ->onDelete('cascade');
            }
            if (!Schema::hasColumn('main_category', 'icon_url')) {
                $table->string('icon_url', 500)->nullable()->after('image');
            }
            if (!Schema::hasColumn('main_category', 'color_code')) {
                $table->string('color_code', 10)->default('#FFFFFF')->after('icon_url');
            }
            if (!Schema::hasColumn('main_category', 'tab_banner_url')) {
                $table->string('tab_banner_url', 500)->nullable()->after('color_code');
            }
            if (!Schema::hasColumn('main_category', 'tab_bg_color')) {
                $table->string('tab_bg_color', 10)->default('#F5F5F5')->after('tab_banner_url');
            }
            if (!Schema::hasColumn('main_category', 'is_tab')) {
                $table->boolean('is_tab')->default(true)->after('tab_bg_color');
            }
            if (!Schema::hasColumn('main_category', 'tab_position')) {
                $table->integer('tab_position')->default(0)->after('is_tab');
            }
            if (!Schema::hasColumn('main_category', 'description')) {
                $table->string('description', 500)->nullable()->after('tab_position');
            }
            if (!Schema::hasColumn('main_category', 'is_active')) {
                $table->tinyInteger('is_active')->default(1)->after('description');
            }
            if (!Schema::hasColumn('main_category', 'position')) {
                $table->integer('position')->default(0)->after('is_active');
            }
        });
    }

    public function down(): void
    {
        Schema::table('main_category', function (Blueprint $table) {
            $table->dropForeign(['parent_id']);
            $table->dropColumn([
                'parent_id',
                'icon_url',
                'color_code',
                'tab_banner_url',
                'tab_bg_color',
                'is_tab',
                'tab_position',
                'description',
                'is_active',
                'position',
            ]);
        });
    }
};
