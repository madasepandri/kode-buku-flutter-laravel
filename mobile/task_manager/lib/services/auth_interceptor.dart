import 'package:dio/dio.dart';

import 'token_store.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens, this.onUnauthorized);

  static const _requestTokenKey = 'authRequestToken';

  final TokenStore _tokens;
  final Future<void> Function(String? requestToken) onUnauthorized;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      if (options.extra['public'] == true) {
        options.headers.remove('Authorization');
        options.extra.remove(_requestTokenKey);
      } else {
        final token = await _tokens.read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          options.extra[_requestTokenKey] = token;
        } else {
          options.headers.remove('Authorization');
          options.extra.remove(_requestTokenKey);
        }
      }
      handler.next(options);
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) async {
    try {
      if (error.response?.statusCode == 401 &&
          error.requestOptions.extra['public'] != true) {
        await onUnauthorized(
          error.requestOptions.extra[_requestTokenKey] as String?,
        );
      }
    } catch (_) {
      // Kesalahan pembersihan sesi tidak boleh menahan alur error Dio.
    }
    handler.next(error);
  }
}
