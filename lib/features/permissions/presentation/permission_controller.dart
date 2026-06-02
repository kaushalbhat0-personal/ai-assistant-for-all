import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:screenfix_ai/core/di/get_it.dart';
import 'package:screenfix_ai/features/permissions/data/permission_repository.dart';
import 'package:screenfix_ai/features/permissions/domain/permission_status.dart';
import 'package:screenfix_ai/features/permissions/domain/permission_type.dart';
import 'package:screenfix_ai/features/permissions/presentation/permission_state.dart';

final permissionControllerProvider =
    StateNotifierProvider<PermissionController, PermissionState>(
  (ref) {
    final repository = getIt<PermissionRepository>();
    return PermissionController(repository);
  },
);

class PermissionController extends StateNotifier<PermissionState> {
  final PermissionRepository _repository;

  PermissionController(this._repository) : super(const PermissionState());

  Future<PermissionStatus> checkPermission(PermissionType type) async {
    state = state.copyWith(isLoading: true);
    final status = await _repository.checkStatus(type);
    state = state.copyWith(
      isLoading: false,
      permissions: {...state.permissions, type: status},
    );
    return status;
  }

  Future<PermissionStatus> requestPermission(PermissionType type) async {
    state = state.copyWith(isLoading: true, activeRequest: type);
    final status = await _repository.request(type);
    state = state.copyWith(
      isLoading: false,
      activeRequest: null,
      permissions: {...state.permissions, type: status},
    );
    return status;
  }

  Future<void> checkAll() async {
    state = state.copyWith(isLoading: true);
    final results = <PermissionType, PermissionStatus>{};
    for (final type in PermissionType.values) {
      results[type] = await _repository.checkStatus(type);
    }
    state = state.copyWith(isLoading: false, permissions: results);
  }
}
