<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class VendorPayout extends Model
{
    protected $table = 'vendor_payouts';

    protected $fillable = [
        'vendor_id', 'amount', 'status', 'period_start', 'period_end',
        'reference', 'paid_at',
    ];

    public function vendor()
    {
        return $this->belongsTo(Vendor::class, 'vendor_id');
    }
}
