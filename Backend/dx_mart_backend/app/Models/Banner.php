<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Banner extends Model
{
    public $timestamps = false;
    protected $table = 'banner';
    protected $fillable = ['category_id', 'banner_image', 'is_active'];

    public function category() {
        return $this->belongsTo(MainCategory::class, 'category_id');
    }
}
