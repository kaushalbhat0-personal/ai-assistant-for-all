import 'package:screenfix_ai/core/config/app_config.dart';

enum VisionHealthStatus { healthy, misconfigured }

class VisionHealthCheck {
  const VisionHealthCheck._();

  static VisionHealthStatus run() {
    if (!AppConfig.hasValidApiKey) {
      return VisionHealthStatus.misconfigured;
    }
    return VisionHealthStatus.healthy;
  }
}
