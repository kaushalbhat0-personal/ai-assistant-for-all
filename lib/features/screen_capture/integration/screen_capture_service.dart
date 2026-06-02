import 'dart:typed_data';

import 'package:screenfix_ai/core/telemetry/telemetry_event.dart';
import 'package:screenfix_ai/core/telemetry/telemetry_service.dart';
import 'package:screenfix_ai/features/screen_capture/domain/screen_capture_permission_status.dart';
import 'package:screenfix_ai/features/screen_capture/domain/screen_capture_result.dart';
import 'package:screenfix_ai/features/screen_capture/integration/screen_capture_permission_handler.dart';
import 'package:screenfix_ai/features/screen_capture/integration/screen_capture_platform_channel.dart';

abstract class ScreenCaptureService {
  Future<ScreenCapturePermissionStatus> hasPermission();
  Future<ScreenCapturePermissionStatus> requestPermission();
  Future<bool> startSession();
  Future<bool> stopSession();
  Future<ScreenCaptureResult?> captureScreen();
}

class AndroidScreenCaptureService implements ScreenCaptureService {
  final ScreenCapturePermissionHandler _permissionHandler;
  final ScreenCapturePlatformChannel _channel;
  final TelemetryService _telemetry;

  AndroidScreenCaptureService(
    this._permissionHandler,
    this._channel,
    this._telemetry,
  );

  @override
  Future<ScreenCapturePermissionStatus> hasPermission() async =>
      _permissionHandler.check();

  @override
  Future<ScreenCapturePermissionStatus> requestPermission() async =>
      _permissionHandler.request();

  @override
  Future<bool> startSession() async {
    final result = await _channel.startProjectionSession();
    if (result) {
      _telemetry.track(TelemetryEvent(
        type: TelemetryEventType.projectionSessionStarted,
        properties: const {},
      ));
    }
    return result;
  }

  @override
  Future<bool> stopSession() async {
    final result = await _channel.stopProjectionSession();
    if (result) {
      _telemetry.track(TelemetryEvent(
        type: TelemetryEventType.projectionSessionStopped,
        properties: const {},
      ));
    }
    return result;
  }

  @override
  Future<ScreenCaptureResult?> captureScreen() async {
    _telemetry.track(TelemetryEvent(
      type: TelemetryEventType.screenCaptureStarted,
      properties: const {},
    ));

    final result = await _channel.captureScreen();

    if (result == null) {
      _telemetry.track(TelemetryEvent(
        type: TelemetryEventType.screenCaptureFailed,
        properties: const {'reason': 'platform_error'},
      ));
      return null;
    }

    final width = result['width'] as int;
    final height = result['height'] as int;
    final bytes = result['bytes'] as Uint8List;

    final captureResult = ScreenCaptureResult(
      width: width,
      height: height,
      bytes: bytes,
      timestamp: DateTime.now(),
    );

    _telemetry.track(TelemetryEvent(
      type: TelemetryEventType.screenCaptureCompleted,
      properties: {
        'width': width,
        'height': height,
        'sizeBytes': bytes.length,
      },
    ));

    return captureResult;
  }
}
