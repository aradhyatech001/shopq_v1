<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class ProductVariant extends Model
{
    public $timestamps = false;
    protected $table = 'product_variants';
    protected $fillable = ['product_id', 'name', 'price', 'selling_price', 'wholesale_price', 'stock'];
}
