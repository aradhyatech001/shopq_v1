<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class City extends Model
{
    public $timestamps = false;
    protected $table = 'city';
    protected $fillable = ['district_id', 'city_name'];
}
