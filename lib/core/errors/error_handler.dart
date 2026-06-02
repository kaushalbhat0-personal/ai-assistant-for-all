import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:screenfix_ai/infrastructure/logging/logger_service.dart';
import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  ErrorHandler._();

  static final LoggerService _logger = const LoggerService();

  static Failure handleException(
    AppException exception, {
    String? source,
  }) {
    _logger.error(
      exception.message,
      tag: source ?? 'ErrorHandler',
      error: exception,
    );

    return switch (exception.code) {
      'NETWORK_TIMEOUT' => TimeoutFailure(
          technicalDetails: exception.message,
        ),
      'NETWORK_NO_CONNECTION' => NetworkFailure(
          technicalDetails: exception.message,
        ),
      'SERVER_ERROR' => ServerFailure(
          statusCode: exception.statusCode,
          technicalDetails: exception.message,
        ),
      'OCR_LOW_CONFIDENCE' => OcrFailure(
          technicalDetails: exception.message,
        ),
      'AI_UNAVAILABLE' => AiFailure(
          technicalDetails: exception.message,
        ),
      'AI_QUOTA_EXCEEDED' => QuotaExceededFailure(
          technicalDetails: exception.message,
        ),
      'PERMISSION_DENIED' => PermissionFailure(
          technicalDetails: exception.message,
        ),
      _ => UnknownFailure(
          technicalDetails: exception.message,
        ),
    };
  }

  static Failure handleDioException(
    DioException exception, {
    String? source,
  }) {
    _logger.error(
      'DioException: ${exception.type}',
      tag: source ?? 'ErrorHandler',
      error: exception,
    );

    return switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        TimeoutFailure(
          technicalDetails: exception.message,
        ),
      DioExceptionType.connectionError => NetworkFailure(
          technicalDetails: exception.message,
        ),
      DioExceptionType.badResponse => _handleStatusCode(
          exception.response?.statusCode,
          exception.message,
        ),
      _ => UnknownFailure(
          technicalDetails: exception.message,
        ),
    };
  }

  static Failure handleUnknown(
    Object error,
    StackTrace stack, {
    String? source,
  }) {
    _logger.error(
      'Unhandled error',
      tag: source ?? 'ErrorHandler',
      error: error,
      stack: stack,
    );

    return switch (error) {
      final TimeoutException _ => TimeoutFailure(
          technicalDetails: error.message,
          stackTrace: stack,
        ),
      final SocketException _ => NetworkFailure(
          technicalDetails: error.message,
          stackTrace: stack,
        ),
      final AppException e => handleException(e, source: source),
      _ => UnknownFailure(
          technicalDetails: error.toString(),
          stackTrace: stack,
        ),
    };
  }

  static Failure _handleStatusCode(int? statusCode, String? message) {
    return switch (statusCode) {
      null => ServerFailure(
          technicalDetails: message,
        ),
      401 || 403 => PermissionFailure(
          technicalDetails: message,
        ),
      429 => QuotaExceededFailure(
          technicalDetails: message,
        ),
      >= 500 => ServerFailure(
          statusCode: statusCode,
          technicalDetails: message,
        ),
      _ => ServerFailure(
          statusCode: statusCode,
          technicalDetails: message,
        ),
    };
  }
}
