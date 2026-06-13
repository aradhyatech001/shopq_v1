<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // ── 1. Consolidate subcategories into the sub_category table ──
        // main_category.parent_id was a duplicate way of storing subcategories.
        if (Schema::hasColumn('main_category', 'parent_id')) {
            $subs = DB::table('main_category')->whereNotNull('parent_id')->get();
            foreach ($subs as $s) {
                if (!DB::table('sub_category')->where('id', $s->id)->exists()) {
                    DB::table('sub_category')->insert([
                        'id'               => $s->id,
                        'main_category_id' => $s->parent_id,
                        'name'             => $s->name,
                        'image_url'        => $s->image,
                        'icon_url'         => $s->icon_url,
                        'position'         => $s->position,
                        'is_active'        => $s->is_active,
                        'created_at'       => now(),
                    ]);
                }
            }
            // Remove the subcategory rows from main_category so they don't show
            // up as top-level categories once parent_id is gone.
            DB::table('main_category')->whereNotNull('parent_id')->delete();
            // Drop the self-referential FK before the column.
            try { Schema::table('main_category', fn (Blueprint $t) => $t->dropForeign('main_category_parent_id_foreign')); } catch (\Throwable $e) {}
            Schema::table('main_category', fn (Blueprint $t) => $t->dropColumn('parent_id'));
        }

        // ── 2. Drop the duplicate product column (keep subcategory_id) ──
        if (Schema::hasColumn('products', 'sub_category_id')) {
            try { Schema::table('products', fn (Blueprint $t) => $t->dropForeign('products_sub_category_id_foreign')); } catch (\Throwable $e) {}
            Schema::table('products', fn (Blueprint $t) => $t->dropColumn('sub_category_id'));
        }

        // ── 3. Drop dead duplicate tables ──
        Schema::dropIfExists('delivey_charge');   // typo twin of delivery_charge
        Schema::dropIfExists('product_tags');      // unused, superseded by product_types
        Schema::dropIfExists('vendor_tokens');     // superseded by personal_access_tokens
    }

    public function down(): void
    {
        // Partial reversibility (structure only, not data).
        if (!Schema::hasColumn('main_category', 'parent_id')) {
            Schema::table('main_category', fn (Blueprint $t) =>
                $t->unsignedBigInteger('parent_id')->nullable()->after('id'));
        }
        if (!Schema::hasColumn('products', 'sub_category_id')) {
            Schema::table('products', fn (Blueprint $t) =>
                $t->unsignedBigInteger('sub_category_id')->nullable()->after('subcategory_id'));
        }
    }
};
