<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class OrderSeeder extends Seeder
{
    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0');
        DB::table('order_items')->truncate();
        DB::table('orders')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1');

        $now   = now();
        $users = DB::table('users')->pluck('id')->toArray();

        if (empty($users)) return;

        // Get some variants to use in orders
        $variants = DB::table('product_variants')
            ->join('products', 'product_variants.product_id', '=', 'products.id')
            ->select('product_variants.id as variant_id', 'product_variants.product_id', 'product_variants.selling_price', 'products.name as product_name')
            ->get();

        if ($variants->isEmpty()) return;

        $statuses  = ['pending', 'confirmed', 'out_for_delivery', 'delivered', 'delivered', 'delivered'];
        $addresses = [
            'Flat 101, Green Park, New Delhi - 110016',
            'B-204, Andheri West, Mumbai - 400058',
            'No. 45, Indiranagar, Bengaluru - 560038',
            '12/3 Ballygunge, Kolkata - 700019',
            'C-7, CG Road, Ahmedabad - 380006',
        ];
        $phonenums = ['9876543210', '9123456780', '9988776655', '9001122334', '9445566778'];

        $orderData = [
            // Order 1
            [
                'user_id'    => $users[0],
                'items'      => [0, 2],        // variant indices
                'quantities' => [2, 1],
                'status'     => 'delivered',
                'date'       => now()->subDays(10),
                'address'    => $addresses[0],
                'phone'      => $phonenums[0],
            ],
            // Order 2
            [
                'user_id'    => $users[1],
                'items'      => [5, 7],
                'quantities' => [1, 2],
                'status'     => 'delivered',
                'date'       => now()->subDays(7),
                'address'    => $addresses[1],
                'phone'      => $phonenums[1],
            ],
            // Order 3
            [
                'user_id'    => $users[2],
                'items'      => [9, 12, 14],
                'quantities' => [1, 1, 2],
                'status'     => 'out_for_delivery',
                'date'       => now()->subDays(1),
                'address'    => $addresses[2],
                'phone'      => $phonenums[2],
            ],
            // Order 4
            [
                'user_id'    => $users[0],
                'items'      => [15, 16],
                'quantities' => [1, 1],
                'status'     => 'confirmed',
                'date'       => now()->subHours(5),
                'address'    => $addresses[0],
                'phone'      => $phonenums[0],
            ],
            // Order 5
            [
                'user_id'    => $users[3 % count($users)],
                'items'      => [1, 3, 8],
                'quantities' => [1, 2, 1],
                'status'     => 'pending',
                'date'       => now()->subHours(1),
                'address'    => $addresses[3],
                'phone'      => $phonenums[3],
            ],
            // Order 6
            [
                'user_id'    => $users[4 % count($users)],
                'items'      => [10, 11],
                'quantities' => [2, 1],
                'status'     => 'delivered',
                'date'       => now()->subDays(3),
                'address'    => $addresses[4],
                'phone'      => $phonenums[4],
            ],
            // Order 7
            [
                'user_id'    => $users[1],
                'items'      => [0, 6],
                'quantities' => [1, 1],
                'status'     => 'cancelled',
                'date'       => now()->subDays(5),
                'address'    => $addresses[1],
                'phone'      => $phonenums[1],
            ],
        ];

        foreach ($orderData as $od) {
            $subtotal = 0;
            $itemsToInsert = [];

            foreach ($od['items'] as $idx => $vi) {
                $vi = $vi % $variants->count();
                $variant  = $variants[$vi];
                $qty      = $od['quantities'][$idx];
                $price    = $variant->selling_price;
                $subtotal += $price * $qty;

                $itemsToInsert[] = [
                    'variant'   => $variant,
                    'quantity'  => $qty,
                    'price'     => $price,
                ];
            }

            $delivery  = $subtotal < 500 ? 25 : 0;
            $handling  = 5;
            $final     = $subtotal + $delivery + $handling;
            $orderDate = $od['date']->format('d-m-Y h:i A');

            // Create a delivery address first
            $locId = DB::table('delivery_address')->insertGetId([
                'user_id'      => $od['user_id'],
                'name'         => DB::table('users')->where('id', $od['user_id'])->value('name'),
                'phone'        => $od['phone'],
                'full_address' => $od['address'],
                'pin_code'     => '110001',
                'landmark'     => 'Near main market',
                'created_at'   => $now,
                'updated_at'   => $now,
            ]);

            $orderId = DB::table('orders')->insertGetId([
                'user_id'         => $od['user_id'],
                'vendor_id'       => null,
                'total_amount'    => $subtotal,
                'coupon_code'     => null,
                'discount_amount' => 0,
                'delivery_charge' => $delivery,
                'handling_charge' => $handling,
                'final_amount'    => $final,
                'status'          => $od['status'],
                'payment_method'  => 'COD',
                'order_datetime'  => $orderDate,
                'delivery_date'   => $od['date']->addDay()->format('d-m-Y'),
                'delivery_time'   => '10:00 AM - 12:00 PM',
                'location_id'     => $locId,
                'gift'            => 'noGift',
                'created_at'      => $od['date'],
                'updated_at'      => $od['date'],
            ]);

            foreach ($itemsToInsert as $item) {
                DB::table('order_items')->insert([
                    'order_id'   => $orderId,
                    'product_id' => $item['variant']->product_id,
                    'variant_id' => $item['variant']->variant_id,
                    'quantity'   => $item['quantity'],
                    'price'      => $item['price'],
                    'image_url'  => null,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
            }
        }
    }
}
