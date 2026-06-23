<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    public $timestamps = false;
    protected $table   = 'order_items';
    protected $fillable = ['order_id', 'vendor_order_id', 'vendor_id', 'product_id', 'variant_id', 'quantity', 'price', 'image_url'];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function variant()
    {
        return $this->belongsTo(ProductVariant::class, 'variant_id');
    }
}
