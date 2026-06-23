<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\HelpCall;
use App\Models\HelpEmail;
use App\Models\HelpWhatsapp;

class HelpController extends Controller
{
    private function getFirst($model) {
        $row = $model::first();
        if ($row) return response()->json(['success' => true, 'data' => $row]);
        return response()->json(['success' => false, 'message' => 'No data found']);
    }
    private function updateFirst($model, Request $request, string $field) {
        $value = $request->input($field);
        if (!$value) {
            return response()->json(['success' => false, 'message' => 'Missing parameters']);
        }
        // Always update the single settings row; no id required from caller
        $model::query()->update([$field => $value]);
        return response()->json(['success' => true, 'message' => 'Updated successfully']);
    }

    public function getCall()                              { return $this->getFirst(HelpCall::class); }
    public function updateCall(Request $request)           { return $this->updateFirst(HelpCall::class, $request, 'call_help'); }
    public function getEmail()                             { return $this->getFirst(HelpEmail::class); }
    public function updateEmail(Request $request)          { return $this->updateFirst(HelpEmail::class, $request, 'email'); }
    public function getWhatsapp()                          { return $this->getFirst(HelpWhatsapp::class); }
    public function updateWhatsapp(Request $request)       { return $this->updateFirst(HelpWhatsapp::class, $request, 'whatsapp_no'); }
}
