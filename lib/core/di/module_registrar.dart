import 'core_module.dart';
import 'package:screenfix_ai/features/overlay/overlay_module.dart';
import 'package:screenfix_ai/features/permissions/permissions_module.dart';
import 'package:screenfix_ai/features/screen_capture/screen_capture_module.dart';

class ModuleRegistrar {
  ModuleRegistrar._();

  static Future<void> registerAll() async {
    await CoreModule.register();
    await PermissionsModule.register();
    await OverlayModule.register();
    await ScreenCaptureModule.register();
  }
}
