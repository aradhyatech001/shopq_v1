<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class FreeDelivery extends Model
{
    public $timestamps = false;
    protected $table = 'free_delivey';
    protected $fillable = ['amount'];
}
