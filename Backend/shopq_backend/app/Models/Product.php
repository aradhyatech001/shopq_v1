<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
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

    public function brand() {
        return $this->belongsTo(Brand::class, 'brand_id');
    }

    // Vendor
    public function vendor() {
        return $this->belongsTo(Vendor::class, 'vendor_id');
    }

    /// Only products that should be shown to customers: admin products
    /// (no vendor) or products from an APPROVED vendor. Hides products from
    /// pending / rejected / suspended vendors.
    public function scopeVisible($query) {
        return $query->where(function ($q) {
            $q->whereNull('vendor_id')
              ->orWhereHas('vendor', fn($v) => $v->where('status', 'approved'));
        });
    }

    /// Narrows to products deliverable to a given pincode: platform products
    /// (no vendor — available everywhere) plus products from approved vendors
    /// that serve the pincode. A pincode id of 0/null applies no filter.
    public function scopeServingPincode($query, $pincodeId) {
        $pid = (int) $pincodeId;
        if ($pid <= 0) return $query;
        return $query->where(function ($q) use ($pid) {
            $q->whereNull('vendor_id')
              ->orWhereHas('vendor', function ($v) use ($pid) {
                  $v->where('status', 'approved')
                    ->whereHas('pincodes', fn($p) => $p->where('pincodes.id', $pid));
              });
        });
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
