import 'package:screenfix_ai/core/di/get_it.dart';

/// Test utility for managing GetIt registrations during tests.
/// Call reset() in setUp, register mocks before each test case.
class TestInjector {
  static Future<void> reset() async {
    await getIt.reset();
  }

  static void registerCoreMocks() {
    // Session 2+: Register mocks for core dependencies.
  }
}
