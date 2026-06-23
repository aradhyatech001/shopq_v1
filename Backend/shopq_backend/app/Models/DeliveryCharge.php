<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class DeliveryCharge extends Model
{
    public $timestamps = false;
    protected $table = 'delivery_charge';
    protected $fillable = ['amount'];
}
