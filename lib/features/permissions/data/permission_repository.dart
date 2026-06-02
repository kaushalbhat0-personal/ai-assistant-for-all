import 'package:screenfix_ai/features/permissions/domain/permission_status.dart';
import 'package:screenfix_ai/features/permissions/domain/permission_type.dart';

abstract class PermissionRepository {
  Future<PermissionStatus> checkStatus(PermissionType type);
  Future<PermissionStatus> request(PermissionType type);
}
