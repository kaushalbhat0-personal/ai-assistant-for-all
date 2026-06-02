import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:screenfix_ai/features/overlay/domain/overlay_state.dart';
import 'package:screenfix_ai/features/overlay/presentation/overlay_controller.dart';

final overlayControllerProvider =
    StateNotifierProvider<OverlayController, OverlayState>(
  (ref) => OverlayController(),
);
