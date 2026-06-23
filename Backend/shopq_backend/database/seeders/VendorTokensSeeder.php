<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class VendorTokensSeeder extends Seeder
{
    public function run(): void
    {
        // vendor_tokens is a legacy table; Sanctum uses personal_access_tokens now.
        // Guard against environments that no longer have this table.
        if (!\Illuminate\Support\Facades\Schema::hasTable('vendor_tokens')) {
            return;
        }
        DB::table('vendor_tokens')->truncate();
        // Vendor tokens seeder - currently empty, add data as needed
        // Tokens should be generated dynamically in application flow
        // Example structure:
        // DB::table('vendor_tokens')->insert([
        //     [
        //         'vendor_id' => 1,
        //         'token' => 'generated_token_string',
        //         'created_at' => now(),
        //         'expires_at' => now()->addDay(),
        //     ],
        // ]);
    }
}
