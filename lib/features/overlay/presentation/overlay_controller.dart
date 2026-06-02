import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:screenfix_ai/features/overlay/domain/overlay_position.dart';
import 'package:screenfix_ai/features/overlay/domain/overlay_state.dart';

class OverlayController extends StateNotifier<OverlayState> {
  OverlayController() : super(const OverlayState());

  static const double _bubbleSize = 56;

  void show() => state = state.copyWith(visible: true);

  void hide() => state = state.copyWith(visible: false);

  void toggle() => state = state.copyWith(visible: !state.visible);

  void move(
    OverlayPosition position, {
    double? screenWidth,
    double? screenHeight,
  }) {
    state = state.copyWith(
      position: OverlayPosition(
        x: screenWidth != null
            ? position.x.clamp(0, screenWidth - _bubbleSize)
            : position.x,
        y: screenHeight != null
            ? position.y.clamp(0, screenHeight - _bubbleSize)
            : position.y,
      ),
    );
  }

  void expand() => state = state.copyWith(expanded: true);

  void collapse() => state = state.copyWith(expanded: false);
}
