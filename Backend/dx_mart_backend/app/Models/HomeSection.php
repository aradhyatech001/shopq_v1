<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HomeSection extends Model
{
    protected $table = 'home_sections';

    protected $fillable = [
        'home_tab_id', 'title', 'emoji', 'banner_image', 'section_type',
        'product_type', 'main_category_id', 'subcategory_id', 'brand_id',
        'link_category_id', 'product_limit', 'position', 'is_active',
    ];

    public function tab()
    {
        return $this->belongsTo(HomeTab::class, 'home_tab_id');
    }
}
