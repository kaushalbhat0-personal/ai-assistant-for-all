import 'package:screenfix_ai/core/telemetry/telemetry_event.dart';
import 'package:screenfix_ai/core/telemetry/telemetry_service.dart';
import 'package:screenfix_ai/features/overlay/integration/overlay_platform_channel.dart';

class OverlayPermissionHandler {
  final OverlayPlatformChannel _channel;
  final TelemetryService _telemetry;

  OverlayPermissionHandler({
    required OverlayPlatformChannel channel,
    required TelemetryService telemetry,
  })  : _channel = channel,
        _telemetry = telemetry;

  Future<bool> isGranted() async {
    return _channel.checkOverlayPermission();
  }

  Future<bool> request() async {
    _telemetry.track(TelemetryEvent(
      type: TelemetryEventType.overlayPermissionRequested,
      properties: const {'action': 'request'},
    ));

    final result = await _channel.requestOverlayPermission();

    _telemetry.track(TelemetryEvent(
      type: TelemetryEventType.overlayPermissionResult,
      properties: {'granted': result},
    ));

    return result;
  }
}
