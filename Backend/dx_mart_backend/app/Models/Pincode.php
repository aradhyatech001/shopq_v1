<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pincode extends Model
{
    protected $table    = 'pincodes';
    protected $fillable = ['code', 'area_name', 'city', 'state', 'is_active'];

    public function vendors()
    {
        return $this->belongsToMany(Vendor::class, 'vendor_pincodes');
    }
}
