<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class CartItem extends Model
{
    public $timestamps = false;
    protected $table = 'cart_items';
    protected $fillable = ['user_id', 'product_id', 'variant_id', 'quantity', 'image_url'];
}
