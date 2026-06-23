<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class ProductInfo extends Model
{
    public $timestamps = false;
    protected $table = 'product_info';
    protected $fillable = ['product_id', 'attribute', 'value'];
}
