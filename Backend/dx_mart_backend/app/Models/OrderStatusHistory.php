<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OrderStatusHistory extends Model
{
    protected $table = 'order_status_history';
    public $timestamps = false;

    protected $fillable = [
        'parent_order_id', 'vendor_order_id', 'actor_type', 'actor_id',
        'from_status', 'to_status', 'note', 'created_at',
    ];
}
