<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Refund extends Model
{
    protected $table = 'refunds';

    protected $fillable = [
        'parent_order_id', 'vendor_order_id', 'amount', 'reason',
        'status', 'processed_at',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class, 'parent_order_id');
    }
}
