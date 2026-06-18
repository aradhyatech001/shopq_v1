import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class ApiHelper {
  // ── Token helpers ─────────────────────────────────────────
  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return token.isNotEmpty ? {'Authorization': 'Bearer $token'} : {};
  }

  // ── Location (selected delivery pincode) ──────────────────
  /// The pincode id the user picked on the LocationScreen (0 = none set).
  static Future<int> getPincodeId() async {
    final prefs = await SharedPreferences.getInstance();
    return int.tryParse(prefs.getString('pincode_id') ?? '') ?? 0;
  }

  /// Appends the saved delivery pincode as a query param so the API returns
  /// only products / stores deliverable to the user's location. No-op when
  /// no location has been chosen yet.
  static Future<String> withPincode(String url) async {
    final pid = await getPincodeId();
    if (pid <= 0) return url;
    final sep = url.contains('?') ? '&' : '?';
    return '$url${sep}pincode_id=$pid';
  }

  // ── Convenience methods ───────────────────────────────────
  /// Set [pincode] true on storefront calls (products / shops / tab layout)
  /// so results are scoped to the user's selected delivery pincode.
  static Future<http.Response> get(String url, {bool auth = false, bool pincode = false}) async {
    final headers = auth ? await getAuthHeaders() : <String, String>{};
    final finalUrl = pincode ? await withPincode(url) : url;
    return http.get(Uri.parse(finalUrl), headers: headers);
  }

  static Future<http.Response> post(String url, {
    Map<String, dynamic>? body,
    bool auth = false,
    bool json = false,
  }) async {
    final headers = auth ? await getAuthHeaders() : <String, String>{};
    if (json && body != null) {
      headers['Content-Type'] = 'application/json';
      return http.post(Uri.parse(url), body: jsonEncode(body), headers: headers);
    }
    final formBody = body?.map((k, v) => MapEntry(k, v.toString()));
    return http.post(Uri.parse(url), body: formBody, headers: headers);
  }

  static Future<http.Response> postJson(String url, {dynamic body, bool auth = false}) async {
    final headers = auth ? await getAuthHeaders() : <String, String>{};
    headers['Content-Type'] = 'application/json';
    return http.post(
      Uri.parse(url),
      body: body != null ? jsonEncode(body) : null,
      headers: headers,
    );
  }

  // ── User info (cached) ────────────────────────────────────
  // user_id is always saved at login time; we read from cache only.
  // The old unauthenticated /auth/user?email= endpoint is now auth-protected
  // and returns only id+name, so the fallback call is no longer needed.
  static Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedId   = prefs.getString('user_id')    ?? '';
    final cachedName = prefs.getString('user_name')  ?? '';
    final email      = prefs.getString('user_email') ?? '';
    return {'id': cachedId, 'name': cachedName, 'email': email};
  }
}
