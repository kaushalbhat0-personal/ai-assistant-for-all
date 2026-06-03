import 'package:screenfix_ai/features/analysis/domain/vision_error.dart';

import 'failures.dart';

class FailureMapper {
  FailureMapper._();

  static String toUserMessage(Failure failure) {
    return switch (failure) {
      VisionError(:final message) => message,
      NetworkFailure() => 'No internet connection. Please check your network and try again.',
      TimeoutFailure() => 'The request timed out. Please try again.',
      ServerFailure(:final statusCode?) => 'Server error ($statusCode). Please try again later.',
      ServerFailure() => 'Server error. Please try again later.',
      OcrFailure() => 'Could not read text from this screen. Try a clearer screenshot.',
      AiFailure() => 'AI service is temporarily unavailable. Please try again.',
      PermissionFailure() => 'A required permission was denied. Check app settings.',
      QuotaExceededFailure() => 'You\'ve reached your monthly analysis limit.',
      CacheFailure() => 'Could not load cached data. Pull to refresh.',
      UnknownFailure() => 'Something unexpected happened. Please try again.',
      _ => 'An unexpected error occurred. Please try again.',
    };
  }

  static String toTitle(Failure failure) {
    return switch (failure) {
      VisionError(:final type) => type.displayName,
      NetworkFailure() => 'Network Error',
      TimeoutFailure() => 'Timeout',
      ServerFailure() => 'Server Error',
      OcrFailure() => 'OCR Failed',
      AiFailure() => 'AI Unavailable',
      PermissionFailure() => 'Permission Required',
      QuotaExceededFailure() => 'Quota Exceeded',
      CacheFailure() => 'Cache Error',
      UnknownFailure() => 'Error',
      _ => 'Error',
    };
  }
}
