<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SubscriptionPlan extends Model
{
    protected $table    = 'subscription_plans';
    protected $fillable = [
        'name', 'duration_type', 'duration_days',
        'price', 'features', 'max_products', 'is_active', 'position',
    ];

    public function subscriptions()
    {
        return $this->hasMany(VendorSubscription::class, 'plan_id');
    }

    // Decode JSON features
    public function getFeaturesArrayAttribute(): array
    {
        if (!$this->features) return [];
        $decoded = json_decode($this->features, true);
        return is_array($decoded) ? $decoded : [];
    }
}
