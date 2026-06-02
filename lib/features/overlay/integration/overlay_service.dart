import 'package:screenfix_ai/features/overlay/integration/overlay_permission_handler.dart';

abstract class OverlayService {
  Future<bool> isOverlayAvailable();
  Future<bool> checkOverlayPermission();
  Future<bool> requestOverlayPermission();
  Future<bool> canShowOverlay();
  Future<void> showOverlay();
  Future<void> hideOverlay();
}

class StubOverlayService implements OverlayService {
  @override
  Future<bool> isOverlayAvailable() async => false;

  @override
  Future<bool> checkOverlayPermission() async => false;

  @override
  Future<bool> requestOverlayPermission() async => false;

  @override
  Future<bool> canShowOverlay() async => false;

  @override
  Future<void> showOverlay() async {}

  @override
  Future<void> hideOverlay() async {}
}

class AndroidOverlayService implements OverlayService {
  final OverlayPermissionHandler _permissionHandler;

  AndroidOverlayService(this._permissionHandler);

  @override
  Future<bool> isOverlayAvailable() async => _permissionHandler.isGranted();

  @override
  Future<bool> checkOverlayPermission() async => _permissionHandler.isGranted();

  @override
  Future<bool> requestOverlayPermission() async => _permissionHandler.request();

  @override
  Future<bool> canShowOverlay() async => _permissionHandler.isGranted();

  @override
  Future<void> showOverlay() async {
    // TODO: Implement when overlay display platform channel is available
  }

  @override
  Future<void> hideOverlay() async {
    // TODO: Implement when overlay display platform channel is available
  }
}
