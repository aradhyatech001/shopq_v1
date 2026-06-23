import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_endpoints.dart';
import 'dio_interceptor.dart';

/// HTTP response wrapper — keeps `body` for backward-compat consumers.
class ApiResponse {
  final dynamic data;
  final int statusCode;
  ApiResponse(this.data, this.statusCode);
  String get body => jsonEncode(data);
}

/// Singleton Dio client for the delivery app.
/// Auth token is auto-injected by [AuthInterceptor].
class ApiClient {
  ApiClient._();
  static Dio? _dio;

  static Dio get _instance {
    _dio ??= _build();
    return _dio!;
  }

  static Dio _build() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.BASE_URL,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      validateStatus: (status) => true,
    ));

    dio.interceptors.add(AuthInterceptor());

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

  static Future<ApiResponse> get(String url, {bool auth = false}) async {
    final r = await _instance.get(url);
    return ApiResponse(r.data, r.statusCode ?? 0);
  }

  static Future<ApiResponse> postJson(String url, {dynamic body}) async {
    final r = await _instance.post(
      url,
      data: body,
      options: Options(contentType: Headers.jsonContentType),
    );
    return ApiResponse(r.data, r.statusCode ?? 0);
  }

  static Future<ApiResponse> post(String url, {Map<String, dynamic>? body, bool auth = false}) async {
    final r = await _instance.post(
      url,
      data: body,
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );
    return ApiResponse(r.data, r.statusCode ?? 0);
  }
}

typedef ApiHelper = ApiClient;
