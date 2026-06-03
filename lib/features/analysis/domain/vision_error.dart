import 'package:screenfix_ai/core/errors/failures.dart';

enum VisionErrorType {
  unauthorized,
  rateLimited,
  network,
  timeout,
  invalidResponse,
  unknown;

  String get guidance {
    return switch (this) {
      VisionErrorType.unauthorized =>
        'OpenRouter API key is missing or invalid. '
        'Pass it via --dart-define=OPENROUTER_API_KEY=sk-or-...',
      VisionErrorType.rateLimited =>
        'OpenRouter rate limit exceeded. Wait a moment and try again.',
      VisionErrorType.network =>
        'No internet connection. Check your network and try again.',
      VisionErrorType.timeout =>
        'OpenRouter did not respond in time. The free tier can be slow; '
        'try again or switch to a paid model.',
      VisionErrorType.invalidResponse =>
        'OpenRouter returned an unexpected response. The free model may '
        'have been unavailable. The request will retry with the next model.',
      VisionErrorType.unknown =>
        'An unexpected error occurred during vision analysis.',
    };
  }

  String get displayName {
    return switch (this) {
      VisionErrorType.unauthorized => 'Unauthorized',
      VisionErrorType.rateLimited => 'Rate Limited',
      VisionErrorType.network => 'Network Error',
      VisionErrorType.timeout => 'Timeout',
      VisionErrorType.invalidResponse => 'Invalid Response',
      VisionErrorType.unknown => 'Unknown Error',
    };
  }
}

class VisionError extends Failure {
  final VisionErrorType type;
  final int? httpStatusCode;

  const VisionError({
    required this.type,
    required super.message,
    super.technicalDetails,
    super.stackTrace,
    this.httpStatusCode,
  });

  @override
  String toString() => 'VisionError($type): $message';
}

class VisionUnauthorized extends VisionError {
  VisionUnauthorized({
    super.technicalDetails,
    super.stackTrace,
  }) : super(
          type: VisionErrorType.unauthorized,
          message: VisionErrorType.unauthorized.guidance,
        );
}

class VisionRateLimited extends VisionError {
  VisionRateLimited({
    super.technicalDetails,
    super.stackTrace,
  }) : super(
          type: VisionErrorType.rateLimited,
          message: VisionErrorType.rateLimited.guidance,
        );
}

class VisionNetworkError extends VisionError {
  VisionNetworkError({
    super.technicalDetails,
    super.stackTrace,
  }) : super(
          type: VisionErrorType.network,
          message: VisionErrorType.network.guidance,
        );
}

class VisionTimeout extends VisionError {
  VisionTimeout({
    super.technicalDetails,
    super.stackTrace,
  }) : super(
          type: VisionErrorType.timeout,
          message: VisionErrorType.timeout.guidance,
        );
}

class VisionInvalidResponse extends VisionError {
  VisionInvalidResponse({
    super.technicalDetails,
    super.stackTrace,
  }) : super(
          type: VisionErrorType.invalidResponse,
          message: VisionErrorType.invalidResponse.guidance,
        );
}

class VisionUnknownError extends VisionError {
  VisionUnknownError({
    super.technicalDetails,
    super.stackTrace,
  }) : super(
          type: VisionErrorType.unknown,
          message: VisionErrorType.unknown.guidance,
        );
}
