enum Environment {
  development,
  staging,
  production;

  static Environment get current {
    const raw = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'development',
    );
    return Environment.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => Environment.development,
    );
  }

  bool get isDebug => this == Environment.development;
  bool get isRelease => this == Environment.production;
}
