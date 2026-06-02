import 'package:screenfix_ai/features/permissions/domain/permission_status.dart';
import 'package:screenfix_ai/features/permissions/domain/permission_type.dart';

class PermissionState {
  final Map<PermissionType, PermissionStatus> permissions;
  final PermissionType? activeRequest;
  final bool isLoading;

  const PermissionState({
    this.permissions = const {},
    this.activeRequest,
    this.isLoading = false,
  });

  PermissionStatus statusOf(PermissionType type) {
    return permissions[type] ?? PermissionStatus.unknown;
  }

  PermissionState copyWith({
    Map<PermissionType, PermissionStatus>? permissions,
    PermissionType? activeRequest,
    bool? isLoading,
  }) {
    return PermissionState(
      permissions: permissions ?? this.permissions,
      activeRequest: activeRequest ?? this.activeRequest,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
