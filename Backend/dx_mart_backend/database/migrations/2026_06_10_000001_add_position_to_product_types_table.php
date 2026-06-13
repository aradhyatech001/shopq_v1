<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        // Add position column if it doesn't exist
        if (!Schema::hasColumn('product_types', 'position')) {
            Schema::table('product_types', function (Blueprint $table) {
                $table->unsignedInteger('position')->default(0)->after('name');
            });

            // Set default positions based on current id order
            $types = DB::table('product_types')->orderBy('id')->get();
            foreach ($types as $index => $type) {
                DB::table('product_types')
                    ->where('id', $type->id)
                    ->update(['position' => $index + 1]);
            }
        }
    }

    public function down(): void
    {
        Schema::table('product_types', function (Blueprint $table) {
            $table->dropColumn('position');
        });
    }
};
