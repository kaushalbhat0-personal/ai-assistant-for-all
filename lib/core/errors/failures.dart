sealed class Failure {
  final String message;
  final String? technicalDetails;
  final StackTrace? stackTrace;

  const Failure({
    required this.message,
    this.technicalDetails,
    this.stackTrace,
  });

  @override
  String toString() => 'Failure: $message';
}

final class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection.',
    super.technicalDetails,
    super.stackTrace,
  });
}

final class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({
    super.message = 'Server error occurred.',
    this.statusCode,
    super.technicalDetails,
    super.stackTrace,
  });
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timed out.',
    super.technicalDetails,
    super.stackTrace,
  });
}

final class OcrFailure extends Failure {
  const OcrFailure({
    super.message = 'Could not read text from this screen.',
    super.technicalDetails,
    super.stackTrace,
  });
}

final class AiFailure extends Failure {
  const AiFailure({
    super.message = 'AI service is unavailable right now.',
    super.technicalDetails,
    super.stackTrace,
  });
}

final class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Required permission was denied.',
    super.technicalDetails,
    super.stackTrace,
  });
}

final class QuotaExceededFailure extends Failure {
  const QuotaExceededFailure({
    super.message = 'Monthly analysis limit reached.',
    super.technicalDetails,
    super.stackTrace,
  });
}

final class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Could not load cached data.',
    super.technicalDetails,
    super.stackTrace,
  });
}

final class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Something went wrong.',
    super.technicalDetails,
    super.stackTrace,
  });
}
