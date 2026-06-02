import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio _dio;

  static const _retryCountKey = '__retry_count__';
  static const _maxRetries = 3;
  static const _baseDelayMs = 1000;

  RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_isRetryable(err)) {
      return handler.next(err);
    }

    final retryCount = _getRetryCount(err.requestOptions);
    if (retryCount >= _maxRetries) {
      return handler.next(err);
    }

    _incrementRetryCount(err.requestOptions);

    final delay = Duration(
      milliseconds: _baseDelayMs * pow(2, retryCount).toInt(),
    );

    _wait(delay).then((_) async {
      try {
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
      } catch (_) {
        handler.next(err);
      }
    });
  }

  bool _isRetryable(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        true,
      DioExceptionType.badResponse => _isRetryableStatusCode(
          error.response?.statusCode,
        ),
      _ => false,
    };
  }

  bool _isRetryableStatusCode(int? code) {
    return code == 429 || (code != null && code >= 500);
  }

  int _getRetryCount(RequestOptions options) {
    return options.extra[_retryCountKey] as int? ?? 0;
  }

  void _incrementRetryCount(RequestOptions options) {
    final count = _getRetryCount(options) + 1;
    options.extra[_retryCountKey] = count;
  }

  Future<void> _wait(Duration duration) {
    return Future.delayed(duration);
  }
}
