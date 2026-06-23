<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Coupon extends Model
{
    protected $table = 'coupon';
    protected $fillable = ['title', 'description', 'code_name', 'discount', 'expri_date', 'status', 'min_amount'];
}
