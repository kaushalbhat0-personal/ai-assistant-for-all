import 'package:dio/dio.dart';

import 'package:screenfix_ai/infrastructure/logging/logger_service.dart';

class LoggingInterceptor extends Interceptor {
  final LoggerService _logger;

  LoggingInterceptor(this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.info(
      '→ ${options.method} ${options.path}',
      tag: 'HTTP',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.info(
      '← ${response.statusCode} ${response.requestOptions.path}',
      tag: 'HTTP',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.warning(
      '✕ ${err.type.name} ${err.message}',
      tag: 'HTTP',
      error: err,
    );
    handler.next(err);
  }
}
