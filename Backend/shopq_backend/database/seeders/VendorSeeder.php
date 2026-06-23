<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class VendorSeeder extends Seeder
{
    private function storageImageFiles(string $folder): array
    {
        return collect(Storage::disk('public')->files($folder))
            ->filter(fn ($file) => preg_match('/\.(png|jpe?g|webp)$/i', $file))
            ->values()
            ->all();
    }

    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0');
        DB::table('vendor_pincodes')->truncate();
        DB::table('vendor_subscriptions')->truncate();
        DB::table('vendors')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1');

        $now = now();
        $vendorLogos = $this->storageImageFiles('vendors');
        $vendorLogoByEmail = [
            'ravi@vendor.com'   => $vendorLogos[0] ?? null,
            'meena@vendor.com'  => $vendorLogos[1] ?? $vendorLogos[0] ?? null,
            'deepak@vendor.com' => $vendorLogos[2] ?? $vendorLogos[0] ?? null,
            'sunita@vendor.com' => $vendorLogos[3] ?? $vendorLogos[0] ?? null,
            'prakash@vendor.com'=> $vendorLogos[4] ?? $vendorLogos[0] ?? null,
        ];

        DB::table('vendors')->insert([
            [
                'name'             => 'Ravi Groceries',
                'email'            => 'ravi@vendor.com',
                'phone'            => '9876543210',
                'password'         => Hash::make('Vendor@123'),
                'shop_name'        => 'Ravi Fresh Store',
                'shop_description' => 'Fresh fruits, vegetables and dairy products delivered daily.',
                'logo'             => $vendorLogoByEmail['ravi@vendor.com'],
                'status'           => 'approved',
                'created_at'       => $now,
                'updated_at'       => $now,
            ],
            [
                'name'             => 'Meena Supermart',
                'email'            => 'meena@vendor.com',
                'phone'            => '9123456780',
                'password'         => Hash::make('Vendor@123'),
                'shop_name'        => 'Meena Super Mart',
                'shop_description' => 'Your one-stop shop for packaged food, snacks and beverages.',
                'logo'             => $vendorLogoByEmail['meena@vendor.com'],
                'status'           => 'approved',
                'created_at'       => $now,
                'updated_at'       => $now,
            ],
            [
                'name'             => 'Deepak Electronics',
                'email'            => 'deepak@vendor.com',
                'phone'            => '9988776655',
                'password'         => Hash::make('Vendor@123'),
                'shop_name'        => 'Deepak Electronics Hub',
                'shop_description' => 'Kitchen appliances, gadgets and electronics at best prices.',
                'logo'             => $vendorLogoByEmail['deepak@vendor.com'],
                'status'           => 'approved',
                'created_at'       => $now,
                'updated_at'       => $now,
            ],
            [
                'name'             => 'Sunita Dairy',
                'email'            => 'sunita@vendor.com',
                'phone'            => '9001122334',
                'password'         => Hash::make('Vendor@123'),
                'shop_name'        => 'Sunita Pure Dairy',
                'shop_description' => 'Organic dairy products — milk, curd, paneer and ghee.',
                'logo'             => null,
                'status'           => 'pending',
                'created_at'       => $now,
                'updated_at'       => $now,
            ],
            [
                'name'             => 'Prakash Spices',
                'email'            => 'prakash@vendor.com',
                'phone'            => '9445566778',
                'password'         => Hash::make('Vendor@123'),
                'shop_name'        => 'Prakash Masala King',
                'shop_description' => 'Authentic Indian spices and masalas sourced directly from farms.',
                'logo'             => null,
                'status'           => 'suspended',
                'created_at'       => $now,
                'updated_at'       => $now,
            ],
        ]);

        // Fetch IDs
        $vendors = DB::table('vendors')->pluck('id', 'email');
        $plans   = DB::table('subscription_plans')->pluck('id', 'name');
        $pins    = DB::table('pincodes')->pluck('id', 'code');

        $approvedVendors = ['ravi@vendor.com', 'meena@vendor.com', 'deepak@vendor.com'];

        $planAssign = [
            'ravi@vendor.com'   => 'Standard Monthly',
            'meena@vendor.com'  => 'Premium Monthly',
            'deepak@vendor.com' => 'Basic Monthly',
        ];

        // Subscriptions for approved vendors
        foreach ($approvedVendors as $email) {
            $planName = $planAssign[$email];
            $plan     = DB::table('subscription_plans')->where('name', $planName)->first();
            DB::table('vendor_subscriptions')->insert([
                'vendor_id'  => $vendors[$email],
                'plan_id'    => $plan->id,
                'start_date' => now()->toDateString(),
                'end_date'   => now()->addDays($plan->duration_days)->toDateString(),
                'status'     => 'active',
                'created_at' => $now,
                'updated_at' => $now,
            ]);
        }

        // Pincode assignments
        $vendorPincodes = [
            'ravi@vendor.com'   => ['110001', '110002', '110011', '110020'],
            'meena@vendor.com'  => ['400001', '400050', '400069'],
            'deepak@vendor.com' => ['560001', '560034', '411001'],
        ];

        foreach ($vendorPincodes as $email => $codes) {
            foreach ($codes as $code) {
                if (!isset($pins[$code])) continue;

                $pincode = DB::table('pincodes')->where('id', $pins[$code])->first();
                DB::table('vendor_pincodes')->insert([
                    'vendor_id'  => $vendors[$email],
                    'pincode_id' => $pins[$code],
                    'pincode'    => $pincode->code ?? $code,
                    'area_name'  => $pincode->area_name ?? null,
                    'is_active'  => 1,
                    'created_at' => $now,
                ]);
            }
        }
    }
}
