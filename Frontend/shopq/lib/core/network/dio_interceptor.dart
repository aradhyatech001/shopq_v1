import 'package:dio/dio.dart';

import '../storage/storage_service.dart';

class DioInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final t = StorageService.token;
    if (t.isNotEmpty) options.headers['Authorization'] = 'Bearer $t';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
