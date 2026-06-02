import 'package:screenfix_ai/core/di/get_it.dart';
import 'package:screenfix_ai/features/permissions/data/permission_repository.dart';
import 'package:screenfix_ai/features/permissions/integration/permission_service.dart';

class PermissionsModule {
  PermissionsModule._();

  static Future<void> register() async {
    getIt.registerSingleton<PermissionRepository>(AndroidPermissionService());
  }
}
