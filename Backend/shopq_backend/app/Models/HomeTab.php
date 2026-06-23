<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class HomeTab extends Model
{
    protected $table   = 'home_tabs';
    protected $fillable = ['name', 'icon', 'icon_image', 'type', 'category_id', 'bg_color', 'banner_image', 'position', 'is_active'];

    public function category()
    {
        return $this->belongsTo(MainCategory::class, 'category_id');
    }
}
