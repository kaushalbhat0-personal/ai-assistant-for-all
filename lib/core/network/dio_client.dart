import 'package:dio/dio.dart';

import 'package:screenfix_ai/core/config/app_config.dart';
import 'package:screenfix_ai/infrastructure/logging/logger_service.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio create(LoggerService logger) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: AppConfig.requestTimeout,
        receiveTimeout: AppConfig.requestTimeout,
        contentType: 'application/json',
      ),
    );

    dio.interceptors.addAll([
      LoggingInterceptor(logger),
      RetryInterceptor(dio),
    ]);

    return dio;
  }
}
