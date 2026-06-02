import 'overlay_position.dart';

class OverlayState {
  final bool visible;
  final bool expanded;
  final OverlayPosition position;

  const OverlayState({
    this.visible = false,
    this.expanded = false,
    this.position = const OverlayPosition(x: 0, y: 0),
  });

  OverlayState copyWith({
    bool? visible,
    bool? expanded,
    OverlayPosition? position,
  }) {
    return OverlayState(
      visible: visible ?? this.visible,
      expanded: expanded ?? this.expanded,
      position: position ?? this.position,
    );
  }
}
