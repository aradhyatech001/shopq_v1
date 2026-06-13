<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    public $timestamps = false;
    protected $table = 'products';
    protected $fillable = [
        'name', 'description', 'main_category_id', 'subcategory_id',
        'brand_id', 'types', 'is_active', 'vendor_id',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    // Parent/main category
    public function category() {
        return $this->belongsTo(MainCategory::class, 'main_category_id');
    }

    /** Subcategory — lives in the dedicated sub_category table. */
    public function subcategory() {
        return $this->belongsTo(SubCategory::class, 'subcategory_id');
    }

    // Vendor
    public function vendor() {
        return $this->belongsTo(Vendor::class, 'vendor_id');
    }

    public function variants() {
        return $this->hasMany(ProductVariant::class, 'product_id');
    }

    public function info() {
        return $this->hasMany(ProductInfo::class, 'product_id');
    }

    public function highlights() {
        return $this->hasMany(ProductHighlight::class, 'product_id');
    }

    public function images() {
        return $this->hasMany(ProductImage::class, 'product_id');
    }

    public function orderItems() {
        return $this->hasMany(OrderItem::class, 'product_id');
    }
}
