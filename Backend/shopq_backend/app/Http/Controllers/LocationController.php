<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\District;
use App\Models\City;

class LocationController extends Controller
{
    // Districts
    public function addDistrict(Request $request) {
        if (!$request->input('district_name')) {
            return response()->json(['success' => false, 'message' => 'Missing district_name']);
        }
        District::create(['district_name' => $request->input('district_name')]);
        return response()->json(['success' => true, 'message' => 'District added successfully']);
    }
    public function viewDistricts() {
        return response()->json(['success' => true, 'districts' => District::all()]);
    }
    public function updateDistrict(Request $request) {
        $id   = $request->input('district_id');
        $name = $request->input('district_name');
        if (!$id || !$name) {
            return response()->json(['success' => false, 'message' => 'District ID and Name are required']);
        }
        District::where('id', $id)->update(['district_name' => $name]);
        return response()->json(['success' => true, 'message' => 'District updated successfully']);
    }
    public function deleteDistrict(Request $request) {
        $id = $request->input('district_id');
        if (!$id) return response()->json(['success' => false, 'message' => 'District ID not provided']);
        District::destroy($id);
        return response()->json(['success' => true, 'message' => 'District deleted successfully']);
    }

    // Cities
    public function addCity(Request $request) {
        if (!$request->input('district_id') || !$request->input('city_name')) {
            return response()->json(['success' => false, 'message' => 'Missing required parameters']);
        }
        City::create(['district_id' => $request->input('district_id'), 'city_name' => $request->input('city_name')]);
        return response()->json(['success' => true, 'message' => 'City added successfully']);
    }
    public function viewCities(Request $request) {
        $districtId = $request->input('district_id');
        if (!$districtId) return response()->json(['success' => false, 'message' => 'district_id is required']);
        $cities = City::where('district_id', $districtId)->get();
        return response()->json(['success' => true, 'cities' => $cities]);
    }
    public function updateCity(Request $request) {
        $id   = $request->input('city_id');
        $name = $request->input('city_name');
        if (!$id || !$name) return response()->json(['success' => false, 'message' => 'City ID and Name are required']);
        City::where('id', $id)->update(['city_name' => $name]);
        return response()->json(['success' => true, 'message' => 'City updated successfully']);
    }
    public function deleteCity(Request $request) {
        $id = $request->input('city_id');
        if (!$id) return response()->json(['success' => false, 'message' => 'City ID not provided']);
        City::destroy($id);
        return response()->json(['success' => true, 'message' => 'City deleted successfully']);
    }
}
