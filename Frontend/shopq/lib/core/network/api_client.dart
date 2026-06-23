import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../storage/storage_service.dart';
import 'api_endpoints.dart';

/// Merged DioClient + ApiHelper.
///
/// `ApiResponse.body` re-encodes the parsed data as a JSON string so
/// callers that still use `jsonDecode(response.body)` continue to work.
class ApiResponse {
  final dynamic data;
  final int statusCode;
  ApiResponse(this.data, this.statusCode);
  // backward-compat getter
  String get body => jsonEncode(data);
}

class ApiClient {
  ApiClient._();
  static Dio? _dio;

  static Dio get instance {
    _dio ??= _build();
    return _dio!;
  }

  static Dio _build() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.BASE_URL,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      // Don't throw on non-2xx so callers can check statusCode as before.
      validateStatus: (status) => true,
    ));

    // Auto-inject Bearer token when available.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final t = StorageService.token;
          if (t.isNotEmpty) options.headers['Authorization'] = 'Bearer $t';
          handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ));
    }

    return dio;
  }

  // ── Token helpers ────────────────────────────────────────────
  static String getToken() => StorageService.token;

  static void saveToken(String token) => StorageService.token = token;

  static void clearToken() => StorageService.clearAuth();

  // kept async so existing callers (`await ApiHelper.getAuthHeaders()`) compile
  static Future<Map<String, String>> getAuthHeaders() async {
    final t = StorageService.token;
    return t.isNotEmpty ? {'Authorization': 'Bearer $t'} : {};
  }

  // ── Location (delivery pincode) ──────────────────────────────
  static int getPincodeId() => StorageService.pincodeId;

  static String withPincode(String url) {
    final pid = StorageService.pincodeId;
    if (pid <= 0) return url;
    final sep = url.contains('?') ? '&' : '?';
    return '$url${sep}pincode_id=$pid';
  }

  // ── User info ─────────────────────────────────────────────────
  static Map<String, String> getUserInfo() => {
        'id': StorageService.userId,
        'name': StorageService.userName,
        'email': StorageService.userEmail,
      };

  // ── HTTP convenience ──────────────────────────────────────────

  static Future<ApiResponse> get(
    String url, {
    bool auth = false,
    bool pincode = false,
  }) async {
    final finalUrl = pincode ? withPincode(url) : url;
    final response = await instance.get(finalUrl);
    return ApiResponse(response.data, response.statusCode ?? 0);
  }

  static Future<ApiResponse> post(
    String url, {
    Map<String, dynamic>? body,
    bool auth = false,
    bool json = false,
  }) async {
    final opts = json
        ? Options(contentType: Headers.jsonContentType)
        : Options(contentType: 'application/x-www-form-urlencoded');
    final response = await instance.post(url, data: body, options: opts);
    return ApiResponse(response.data, response.statusCode ?? 0);
  }

  static Future<ApiResponse> postJson(
    String url, {
    dynamic body,
    bool auth = false,
  }) async {
    final response = await instance.post(
      url,
      data: body,
      options: Options(contentType: Headers.jsonContentType),
    );
    return ApiResponse(response.data, response.statusCode ?? 0);
  }
}

// Backward-compatibility typedefs
typedef ApiHelper = ApiClient;
typedef DioClient = ApiClient;
