<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // type was an ENUM(all,category,categories,deals); the admin now also
        // offers "none" (themed/section-only tabs). Widen to varchar.
        try {
            DB::statement("ALTER TABLE home_tabs MODIFY type VARCHAR(20) NOT NULL DEFAULT 'category'");
        } catch (\Throwable $e) {
            // non-MySQL or already widened — ignore
        }
    }

    public function down(): void
    {
        // no-op (keep widened)
    }
};
