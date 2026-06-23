<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class District extends Model
{
    public $timestamps = false;
    protected $table = 'district';
    protected $fillable = ['district_name'];

    public function cities() {
        return $this->hasMany(City::class, 'district_id');
    }
}
