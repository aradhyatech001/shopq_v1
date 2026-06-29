<?php

namespace App\Models;

use App\Models\Concerns\HasDeviceTokens;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class DeliveryBoy extends Authenticatable
{
    use HasApiTokens, HasDeviceTokens;

    protected $table = 'delivery_boy';
    public $timestamps = false;

    protected $fillable = [
        'vendor_id', 'name', 'email', 'mobile', 'pin_code',
        'address', 'password', 'date_time', 'status', 'fcm_token',
    ];

    protected $hidden = ['password'];

    public function vendor()
    {
        return $this->belongsTo(Vendor::class, 'vendor_id');
    }
}
