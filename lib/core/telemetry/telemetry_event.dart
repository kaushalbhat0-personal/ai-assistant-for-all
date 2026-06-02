enum TelemetryEventType {
  appStarted,
  routeOpened,
  networkRequestStarted,
  networkRequestCompleted,
  overlayPermissionRequested,
  overlayPermissionResult,
  screenCapturePermissionRequested,
  screenCapturePermissionResult,
  screenCaptureStarted,
  screenCaptureCompleted,
  screenCaptureFailed,
}

class TelemetryEvent {
  final TelemetryEventType type;
  final Map<String, dynamic> properties;
  final Duration? duration;
  final String? sessionId;
  final DateTime timestamp;

  TelemetryEvent({
    required this.type,
    this.properties = const {},
    this.duration,
    this.sessionId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
