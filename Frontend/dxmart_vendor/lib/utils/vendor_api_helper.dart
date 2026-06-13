import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

/// Central HTTP client for the vendor app.
/// Auto-injects `Authorization: Bearer <token>` on every request.
/// Token is stored in SharedPreferences via [SessionManager].
class VendorApiHelper {
  // ── Token helpers ────────────────────────────────────────
  static Future<String?> getToken() => SessionManager.getToken();

  static Future<bool> isLoggedIn() => SessionManager.isLoggedIn();

  static Future<Map<String, String>> _authHeaders({bool json = false}) async {
    final token = await SessionManager.getToken();
    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (json) headers['Content-Type'] = 'application/json';
    return headers;
  }

  // ── GET ──────────────────────────────────────────────────
  static Future<http.Response> get(String url) async {
    return http.get(Uri.parse(url), headers: await _authHeaders());
  }

  // ── POST (form-encoded) ───────────────────────────────────
  static Future<http.Response> post(String url, {Map<String, String>? body}) async {
    return http.post(Uri.parse(url), body: body, headers: await _authHeaders());
  }

  // ── POST (JSON) ───────────────────────────────────────────
  static Future<http.Response> postJson(String url, {dynamic body}) async {
    return http.post(
      Uri.parse(url),
      body: body != null ? jsonEncode(body) : null,
      headers: await _authHeaders(json: true),
    );
  }

  // ── Logout helper ────────────────────────────────────────
  static Future<void> clearSession() => SessionManager.clear();
}
