import 'package:screenfix_ai/core/telemetry/telemetry_event.dart';
import 'package:screenfix_ai/core/telemetry/telemetry_service.dart';
import 'package:screenfix_ai/features/screen_capture/domain/screen_capture_permission_status.dart';
import 'package:screenfix_ai/features/screen_capture/integration/screen_capture_platform_channel.dart';

class ScreenCapturePermissionHandler {
  final ScreenCapturePlatformChannel _channel;
  final TelemetryService _telemetry;

  ScreenCapturePermissionHandler({
    required ScreenCapturePlatformChannel channel,
    required TelemetryService telemetry,
  })  : _channel = channel,
        _telemetry = telemetry;

  Future<ScreenCapturePermissionStatus> check() async {
    final result = await _channel.checkPermission();
    if (result) return ScreenCapturePermissionStatus.granted;
    return ScreenCapturePermissionStatus.denied;
  }

  Future<ScreenCapturePermissionStatus> request() async {
    _telemetry.track(TelemetryEvent(
      type: TelemetryEventType.screenCapturePermissionRequested,
      properties: const {'action': 'request'},
    ));

    final result = await _channel.requestPermission();

    final status = result
        ? ScreenCapturePermissionStatus.granted
        : ScreenCapturePermissionStatus.unknown;

    _telemetry.track(TelemetryEvent(
      type: TelemetryEventType.screenCapturePermissionResult,
      properties: {'granted': result},
    ));

    return status;
  }
}
