import 'package:flutter/widgets.dart';
import 'package:screenfix_ai/app.dart';
import 'package:screenfix_ai/core/di/get_it.dart';
import 'package:screenfix_ai/core/di/module_registrar.dart';
import 'package:screenfix_ai/core/identity/device_identity_service.dart';
import 'package:screenfix_ai/core/telemetry/telemetry_event.dart';
import 'package:screenfix_ai/core/telemetry/telemetry_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ModuleRegistrar.registerAll();

  final identityService = getIt<DeviceIdentityService>();
  await identityService.loadOrCreate();
  await identityService.incrementLaunchCount();

  getIt<TelemetryService>().track(TelemetryEvent(
    type: TelemetryEventType.appStarted,
  ));

  runApp(const ScreenFixApp());
}
