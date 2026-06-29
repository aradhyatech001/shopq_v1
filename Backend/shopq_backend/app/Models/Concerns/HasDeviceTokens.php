<?php

namespace App\Models\Concerns;

use App\Models\DeviceToken;
use Illuminate\Database\Eloquent\Relations\MorphMany;

/**
 * Gives a model (User / Vendor / DeliveryBoy) a set of FCM device tokens.
 */
trait HasDeviceTokens
{
    public function deviceTokens(): MorphMany
    {
        return $this->morphMany(DeviceToken::class, 'tokenable');
    }

    public function validDeviceTokens(): MorphMany
    {
        return $this->deviceTokens()->where('is_valid', true);
    }
}
