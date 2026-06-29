import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

/// Central HTTP client for the admin app.
/// Auto-injects `Authorization: Bearer <token>` on every request, matching the
/// vendor and user apps. The token is the Sanctum token returned by
/// `POST /admin/login` and stored via [SessionManager].
class AdminApi {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await SessionManager.getSessionId();
    if (token != null && token.isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return {};
  }

  static Future<http.Response> get(Uri url) async {
    return http.get(url, headers: await _authHeaders());
  }

  static Future<http.Response> delete(Uri url) async {
    return http.delete(url, headers: await _authHeaders());
  }

  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? body,
    Map<String, String>? extraHeaders,
  }) async {
    final h = await _authHeaders();
    if (extraHeaders != null) h.addAll(extraHeaders);
    return http.post(url, body: body, headers: h);
  }

  static Future<http.Response> postJson(Uri url, {dynamic body}) async {
    final h = await _authHeaders();
    h['Content-Type'] = 'application/json';
    return http.post(
      url,
      body: body != null ? jsonEncode(body) : null,
      headers: h,
    );
  }

  static Future<http.StreamedResponse> multipart(
    Uri url,
    http.MultipartRequest request,
  ) async {
    final h = await _authHeaders();
    request.headers.addAll(h);
    return request.send();
  }
}
