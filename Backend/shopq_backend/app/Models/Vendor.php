<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class Vendor extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $table    = 'vendors';
    protected $fillable = [
        'name', 'email', 'phone', 'password',
        'shop_name', 'shop_description', 'logo',
        'status', 'rejection_reason', 'fcm_token',
    ];
    protected $hidden = ['password', 'remember_token'];

    // ── Relationships ─────────────────────────────────
    public function subscriptions()
    {
        return $this->hasMany(VendorSubscription::class);
    }

    public function activeSubscription()
    {
        return $this->hasOne(VendorSubscription::class)
            ->where('status', 'active')
            ->where('end_date', '>=', now()->toDateString())
            ->latest();
    }

    public function pincodes()
    {
        return $this->belongsToMany(Pincode::class, 'vendor_pincodes');
    }

    public function products()
    {
        return $this->hasMany(Product::class);
    }

    // ── Helpers ───────────────────────────────────────
    public function isApproved(): bool
    {
        return $this->status === 'approved';
    }

    public function hasActiveSubscription(): bool
    {
        return $this->activeSubscription()->exists();
    }
}
