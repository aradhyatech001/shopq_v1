<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\DeliveryCharge;
use App\Models\FreeDelivery;
use App\Models\HandlingCharge;
use App\Models\DeliverTime;
use App\Models\MinimumOrderAmount;

class SettingsController extends Controller
{
    private function getFirst($model) {
        $row = $model::first();
        if ($row) return response()->json(['success' => true, 'data' => $row]);
        // Return a default row so the app always gets a valid response
        return response()->json(['success' => true, 'data' => ['id' => null, 'time' => '10 MIN', 'amount' => 0]]);
    }

    private function updateFirst($model, Request $request, string $field) {
        $value = $request->input($field);
        // Use is_null check so value of 0 is accepted (free delivery, zero handling charge, etc.)
        if (is_null($value)) {
            return response()->json(['success' => false, 'message' => 'Missing parameters']);
        }
        // Always update the single settings row; no id required from caller
        $model::query()->update([$field => $value]);
        return response()->json(['success' => true, 'message' => 'Updated successfully']);
    }

    public function getDeliveryCharge()  { return $this->getFirst(DeliveryCharge::class); }
    public function updateDeliveryCharge(Request $request) { return $this->updateFirst(DeliveryCharge::class, $request, 'amount'); }

    public function getFreeDelivery()    { return $this->getFirst(FreeDelivery::class); }
    public function updateFreeDelivery(Request $request) { return $this->updateFirst(FreeDelivery::class, $request, 'amount'); }

    public function getHandlingCharge()  { return $this->getFirst(HandlingCharge::class); }
    public function updateHandlingCharge(Request $request) { return $this->updateFirst(HandlingCharge::class, $request, 'amount'); }

    public function getDeliveryTime()    { return $this->getFirst(DeliverTime::class); }
    public function updateDeliveryTime(Request $request) { return $this->updateFirst(DeliverTime::class, $request, 'time'); }

    public function getMinOrderAmount()  { return $this->getFirst(MinimumOrderAmount::class); }
    public function updateMinOrderAmount(Request $request) { return $this->updateFirst(MinimumOrderAmount::class, $request, 'amount'); }
}
