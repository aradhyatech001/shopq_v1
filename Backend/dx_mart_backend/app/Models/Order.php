<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    public $timestamps = false;
    protected $table = 'orders';
    protected $fillable = [
        'user_id', 'total_amount', 'coupon_code', 'discount_amount',
        'delivery_charge', 'handling_charge', 'final_amount', 'status',
        'derived_status', 'payment_method', 'payment_status', 'order_datetime',
        'delivery_date', 'delivery_time', 'location_id', 'gift',
    ];

    public function items() {
        return $this->hasMany(OrderItem::class, 'order_id');
    }
    public function vendorOrders() {
        return $this->hasMany(VendorOrder::class, 'parent_order_id');
    }
    public function address() {
        return $this->belongsTo(DeliveryAddress::class, 'location_id');
    }
    public function user() {
        return $this->belongsTo(\App\Models\User::class, 'user_id');
    }
}
