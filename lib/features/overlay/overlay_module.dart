import 'package:screenfix_ai/core/di/get_it.dart';
import 'package:screenfix_ai/core/telemetry/telemetry_service.dart';
import 'package:screenfix_ai/features/overlay/integration/overlay_permission_handler.dart';
import 'package:screenfix_ai/features/overlay/integration/overlay_platform_channel.dart';
import 'package:screenfix_ai/features/overlay/integration/overlay_service.dart';

class OverlayModule {
  OverlayModule._();

  static Future<void> register() async {
    final channel = OverlayPlatformChannel();
    getIt.registerSingleton<OverlayPlatformChannel>(channel);

    final telemetry = getIt<TelemetryService>();
    final handler = OverlayPermissionHandler(
      channel: channel,
      telemetry: telemetry,
    );
    getIt.registerSingleton<OverlayPermissionHandler>(handler);

    getIt.registerSingleton<OverlayService>(
      AndroidOverlayService(handler),
    );
  }
}
