import 'package:screenfix_ai/core/di/get_it.dart';
import 'package:screenfix_ai/core/telemetry/telemetry_service.dart';
import 'package:screenfix_ai/features/screen_capture/integration/screen_capture_permission_handler.dart';
import 'package:screenfix_ai/features/screen_capture/integration/screen_capture_platform_channel.dart';
import 'package:screenfix_ai/features/screen_capture/integration/screen_capture_service.dart';

class ScreenCaptureModule {
  ScreenCaptureModule._();

  static Future<void> register() async {
    final channel = ScreenCapturePlatformChannel();
    getIt.registerSingleton<ScreenCapturePlatformChannel>(channel);

    final telemetry = getIt<TelemetryService>();
    final handler = ScreenCapturePermissionHandler(
      channel: channel,
      telemetry: telemetry,
    );
    getIt.registerSingleton<ScreenCapturePermissionHandler>(handler);

    getIt.registerSingleton<ScreenCaptureService>(
      AndroidScreenCaptureService(handler, channel, telemetry),
    );
  }
}
