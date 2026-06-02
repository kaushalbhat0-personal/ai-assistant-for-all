class AppConstants {
  const AppConstants._();

  static const String appName = 'ScreenFix AI';
  static const String packageName = 'com.screenfix.ai';
  static const String version = '0.1.0-alpha';
  static const String appVersion = '0.1.0-alpha';
  static const int buildNumber = 1;

  static const Duration captureTimeout = Duration(seconds: 5);
  static const Duration ocrTimeout = Duration(seconds: 10);
  static const Duration aiTimeout = Duration(seconds: 30);
  static const Duration pipelineTimeout = Duration(seconds: 45);

  static const int maxRecommendations = 5;
  static const int maxCachedAnalyses = 50;
  static const int maxRecentScreenshots = 3;
}
