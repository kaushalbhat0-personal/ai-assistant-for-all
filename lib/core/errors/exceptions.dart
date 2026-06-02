class AppException implements Exception {
  final String message;
  final String code;
  final int? statusCode;
  final dynamic rawResponse;

  const AppException({
    required this.message,
    required this.code,
    this.statusCode,
    this.rawResponse,
  });

  @override
  String toString() => 'AppException($code): $message';
}
