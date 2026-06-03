import 'package:screenfix_ai/core/config/app_config.dart';
import 'package:screenfix_ai/core/di/get_it.dart';
import 'package:screenfix_ai/features/analysis/integration/context_memory.dart';
import 'package:screenfix_ai/features/analysis/integration/vision_api_client.dart';
import 'package:screenfix_ai/features/analysis/integration/vision_api_service.dart';
import 'package:screenfix_ai/features/analysis/integration/vision_health_check.dart';

class AnalysisModule {
  AnalysisModule._();

  static Future<void> register() async {
    final client = VisionApiClient();
    getIt.registerSingleton<VisionApiClient>(client);

    VisionHealthCheck.run();

    final provider = VisionProvider.defaultProvider;
    final analyzer = switch (provider) {
      VisionProvider.openRouterPaid => OpenRouterPaidService(client) as VisionAnalyzer,
      VisionProvider.openRouterFree => OpenRouterFreeService(client) as VisionAnalyzer,
    };
    getIt.registerSingleton<VisionAnalyzer>(analyzer);

    getIt.registerLazySingleton<ContextMemory>(
      () => ContextMemory(),
    );
  }
}
