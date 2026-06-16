import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

/// HTTP client for the delivery app — auto-injects the Bearer token.
class ApiHelper {
  static Future<Map<String, String>> _headers({bool json = false}) async {
    final token = await SessionManager.getToken();
    final h = <String, String>{};
    if (token != null && token.isNotEmpty) h['Authorization'] = 'Bearer $token';
    if (json) h['Content-Type'] = 'application/json';
    return h;
  }

  static Future<http.Response> get(String url) async {
    return http.get(Uri.parse(url), headers: await _headers());
  }

  static Future<http.Response> postJson(String url, {dynamic body}) async {
    return http.post(
      Uri.parse(url),
      body: body != null ? jsonEncode(body) : null,
      headers: await _headers(json: true),
    );
  }

  static Future<http.Response> post(String url, {Map<String, String>? body}) async {
    return http.post(Uri.parse(url), body: body, headers: await _headers());
  }
}
