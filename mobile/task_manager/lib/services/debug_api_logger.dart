import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DebugApiLogger extends Interceptor {
  void _write(RequestOptions options, String status) {
    if (kDebugMode) {
      debugPrint('[API] ${options.method} ${options.uri.path} $status');
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _write(options, 'start');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _write(response.requestOptions, '${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _write(error.requestOptions,
        '${err.response?.statusCode ?? err.type.name}');
    handler.next(err);
  }
}
