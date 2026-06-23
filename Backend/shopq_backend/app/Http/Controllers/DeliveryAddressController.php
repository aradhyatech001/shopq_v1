<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\DeliveryAddress;

class DeliveryAddressController extends Controller
{
    public function add(Request $request)
    {
        $fields = ['user_id', 'name', 'phone', 'full_address', 'pin_code', 'landmark'];
        foreach ($fields as $f) {
            if (!$request->input($f)) {
                return response()->json(['success' => 'false', 'message' => 'All fields are required']);
            }
        }
        DeliveryAddress::create($request->only($fields));
        return response()->json(['success' => 'true', 'message' => 'Address added successfully']);
    }

    public function view(Request $request)
    {
        $userId = $request->input('user_id');
        if (!$userId) {
            return response()->json(['status' => 'error', 'message' => 'User ID not provided']);
        }
        $addresses = DeliveryAddress::where('user_id', $userId)->get();
        return response()->json(['status' => 'success', 'data' => $addresses]);
    }

    public function edit(Request $request)
    {
        $addressId = $request->input('address_id');
        $userId    = $request->input('user_id');
        if (!$addressId || !$userId) {
            return response()->json(['success' => 'false', 'message' => 'Required fields are missing']);
        }
        $rows = DeliveryAddress::where('id', $addressId)->where('user_id', $userId)->update([
            'name'         => $request->input('name'),
            'phone'        => $request->input('phone'),
            'full_address' => $request->input('full_address'),
            'pin_code'     => $request->input('pin_code'),
            'landmark'     => $request->input('landmark'),
        ]);
        if ($rows) {
            return response()->json(['success' => 'true', 'message' => 'Address updated successfully']);
        }
        return response()->json(['success' => 'false', 'message' => 'Failed to update address']);
    }

    public function delete(Request $request)
    {
        $id = $request->input('id');
        if (!$id) {
            return response()->json(['success' => 'false', 'message' => 'ID not provided']);
        }
        DeliveryAddress::destroy($id);
        return response()->json(['success' => 'true']);
    }
}
