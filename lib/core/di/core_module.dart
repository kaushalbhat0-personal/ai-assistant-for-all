import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:screenfix_ai/core/config/app_config.dart';
import 'package:screenfix_ai/core/di/get_it.dart';
import 'package:screenfix_ai/core/feature_flags/feature_flag_service.dart';
import 'package:screenfix_ai/core/identity/device_identity_service.dart';
import 'package:screenfix_ai/core/network/dio_client.dart';
import 'package:screenfix_ai/core/network/network_info.dart';
import 'package:screenfix_ai/core/telemetry/telemetry_logger.dart';
import 'package:screenfix_ai/core/telemetry/telemetry_service.dart';
import 'package:screenfix_ai/infrastructure/logging/logger_service.dart';
import 'package:screenfix_ai/routing/app_router.dart';

class CoreModule {
  CoreModule._();

  static Future<void> register() async {
    AppConfig.validate();
    getIt.registerSingleton<AppConfig>(AppConfig.instance);
    getIt.registerSingleton<AppRouter>(AppRouter());

    final logger = const LoggerService();
    getIt.registerSingleton<LoggerService>(logger);

    final prefs = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(prefs);

    final identityService = DeviceIdentityService(prefs);
    getIt.registerSingleton<DeviceIdentityService>(identityService);

    final telemetryService = TelemetryService();
    telemetryService.register(TelemetryLogger(logger));
    getIt.registerSingleton<TelemetryService>(telemetryService);

    final dio = DioClient.create(logger);
    getIt.registerSingleton<Dio>(dio);

    getIt.registerSingleton<NetworkInfo>(NetworkInfo());
    getIt.registerSingleton<FeatureFlagService>(FeatureFlagService());
  }
}
