<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MainCategory extends Model
{
    protected $table = 'main_category';

    protected $fillable = [
        'name',
        'image',
        'icon_url',
        'color_code',
        'tab_banner_url',
        'tab_bg_color',
        'description',
        'is_active',
        'position',
    ];

    // ── Relationships ─────────────────────────────────────────
    // Subcategories live in the dedicated `sub_category` table now
    // (main_category.parent_id removed — single source of truth).

    /** Subcategories of this main category (active) */
    public function subcategories()
    {
        return $this->hasMany(SubCategory::class, 'main_category_id')
                    ->where('is_active', 1)
                    ->orderBy('position')
                    ->orderBy('id');
    }

    /** All subcategories including inactive */
    public function allSubcategories()
    {
        return $this->hasMany(SubCategory::class, 'main_category_id')
                    ->orderBy('position')
                    ->orderBy('id');
    }

    /** Products under this category */
    public function products()
    {
        return $this->hasMany(Product::class, 'main_category_id');
    }

    // ── Scopes ────────────────────────────────────────────────

    /** All main_category rows are top-level now (kept for call-site compat). */
    public function scopeTopLevel($query)
    {
        return $query;
    }

    /** Only active categories */
    public function scopeActive($query)
    {
        return $query->where('is_active', 1);
    }
}
