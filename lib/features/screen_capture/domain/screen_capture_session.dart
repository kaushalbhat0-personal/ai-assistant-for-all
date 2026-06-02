import 'package:equatable/equatable.dart';

class ScreenCaptureSession extends Equatable {
  final String sessionId;
  final DateTime createdAt;

  const ScreenCaptureSession({
    required this.sessionId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [sessionId, createdAt];
}
