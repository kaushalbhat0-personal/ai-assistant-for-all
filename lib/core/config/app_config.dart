import 'environment.dart';

enum VisionProvider {
  openRouterPaid,
  openRouterFree;

  static VisionProvider get defaultProvider {
    const fromEnv = String.fromEnvironment(
      'VISION_PROVIDER',
      defaultValue: 'openRouterPaid',
    );
    return switch (fromEnv) {
      'openRouterFree' => VisionProvider.openRouterFree,
      _ => VisionProvider.openRouterPaid,
    };
  }

  bool get requiresApiKey => true;

  String get displayName {
    return switch (this) {
      VisionProvider.openRouterPaid => 'OpenRouter Paid',
      VisionProvider.openRouterFree => 'OpenRouter Free',
    };
  }
}

class AppConfig {
  AppConfig._();

  static AppConfig? _instance;
  static AppConfig get instance => _instance ??= AppConfig._();

  static final Environment environment = Environment.current;

  static const String openRouterApiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );

  static bool get hasValidApiKey =>
      openRouterApiKey.isNotEmpty && openRouterApiKey.startsWith('sk-or-');

  static String get telemetryEndpoint {
    const fromEnv = String.fromEnvironment(
      'TELEMETRY_ENDPOINT',
      defaultValue: '',
    );
    if (fromEnv.isNotEmpty) return fromEnv;
    return switch (environment) {
      Environment.development => 'http://localhost:8080/telemetry',
      Environment.staging => 'https://staging-api.screenfix.ai/telemetry',
      Environment.production => 'https://api.screenfix.ai/telemetry',
    };
  }

  static String get featureFlagEndpoint {
    const fromEnv = String.fromEnvironment(
      'FEATURE_FLAG_ENDPOINT',
      defaultValue: '',
    );
    if (fromEnv.isNotEmpty) return fromEnv;
    return switch (environment) {
      Environment.development => 'http://localhost:8080/flags',
      Environment.staging => 'https://staging-api.screenfix.ai/flags',
      Environment.production => 'https://api.screenfix.ai/flags',
    };
  }

  static String get visionApiEndpoint {
    const fromEnv = String.fromEnvironment(
      'VISION_API_ENDPOINT',
      defaultValue: '',
    );
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'https://openrouter.ai/api/v1/chat/completions';
  }

  static String get visionModelsEndpoint {
    const fromEnv = String.fromEnvironment(
      'VISION_MODELS_ENDPOINT',
      defaultValue: '',
    );
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'https://openrouter.ai/api/v1/models';
  }

  static const Duration requestTimeout = Duration(seconds: 60);
  static const int maxRetries = 2;

  static void validate() {
    assert(
      environment == Environment.development || openRouterApiKey.isNotEmpty,
      'OPENROUTER_API_KEY is required in $environment mode. '
      'Pass it via --dart-define=OPENROUTER_API_KEY=sk-or-...',
    );
  }
}
