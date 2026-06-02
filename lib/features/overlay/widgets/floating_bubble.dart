import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:screenfix_ai/features/overlay/domain/overlay_position.dart';
import 'package:screenfix_ai/features/overlay/presentation/overlay_provider.dart';

class FloatingBubble extends ConsumerWidget {
  const FloatingBubble({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(overlayControllerProvider);
    final controller = ref.read(overlayControllerProvider.notifier);

    return Positioned(
      left: state.position.x,
      top: state.position.y,
      child: GestureDetector(
        onPanUpdate: (details) {
          final screenSize = MediaQuery.of(context).size;
          controller.move(
            OverlayPosition(
              x: state.position.x + details.delta.dx,
              y: state.position.y + details.delta.dy,
            ),
            screenWidth: screenSize.width,
            screenHeight: screenSize.height,
          );
        },
        onTap: () => controller.expand(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_fix_high,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
