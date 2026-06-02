import 'environment.dart';

class AppConfig {
  AppConfig._();

  static AppConfig? _instance;
  static AppConfig get instance => _instance ??= AppConfig._();

  static final Environment environment = Environment.current;

  static const String openRouterApiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );

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

  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  static void validate() {
    assert(
      environment == Environment.development || openRouterApiKey.isNotEmpty,
      'OPENROUTER_API_KEY is required in $environment mode. '
      'Pass it via --dart-define=OPENROUTER_API_KEY=sk-...',
    );
  }
}
