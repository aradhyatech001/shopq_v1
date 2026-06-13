<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class DeliveryAddress extends Model
{
    public $timestamps = false;
    protected $table = 'delivery_address';
    protected $fillable = ['user_id', 'name', 'phone', 'full_address', 'pin_code', 'landmark'];
}
