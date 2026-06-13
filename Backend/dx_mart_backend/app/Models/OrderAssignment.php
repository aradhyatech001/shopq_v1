<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class OrderAssignment extends Model
{
    public $timestamps = false;
    protected $table = 'order_assignment';
    protected $fillable = ['order_id', 'delivery_boy_id', 'date_time'];
}
