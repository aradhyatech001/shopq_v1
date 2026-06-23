<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class MinimumOrderAmount extends Model
{
    public $timestamps = false;
    protected $table = 'minimum_order_amout';
    protected $fillable = ['amount'];
}
