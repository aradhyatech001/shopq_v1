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

  // ── Convenience methods ───────────────────────────────────
  static Future<http.Response> get(String url, {bool auth = false}) async {
    final headers = auth ? await getAuthHeaders() : <String, String>{};
    return http.get(Uri.parse(url), headers: headers);
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
  static Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedId = prefs.getString('user_id') ?? '';
    final cachedName = prefs.getString('user_name') ?? '';
    final email = prefs.getString('user_email') ?? '';

    if (cachedId.isNotEmpty) {
      return {'id': cachedId, 'name': cachedName, 'email': email};
    }

    if (email.isNotEmpty) {
      try {
        final res = await http.get(Uri.parse('${ApiConstants.GET_USER}?email=$email'));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['status'] == 'success' && data['user'] != null) {
            final id = data['user']['id']?.toString() ?? '';
            final name = data['user']['name']?.toString() ?? '';
            await prefs.setString('user_id', id);
            await prefs.setString('user_name', name);
            return {'id': id, 'name': name, 'email': email};
          }
        }
      } catch (_) {}
    }
    return {'id': '', 'name': '', 'email': email};
  }
}
