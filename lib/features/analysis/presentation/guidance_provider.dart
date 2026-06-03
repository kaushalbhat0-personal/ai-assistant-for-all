import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:screenfix_ai/core/di/get_it.dart';
import 'package:screenfix_ai/features/analysis/integration/context_memory.dart';
import 'package:screenfix_ai/features/analysis/integration/vision_api_service.dart';
import 'package:screenfix_ai/features/analysis/presentation/guidance_controller.dart';
import 'package:screenfix_ai/features/analysis/presentation/guidance_state.dart';

final guidanceControllerProvider =
    StateNotifierProvider<GuidanceController, GuidanceState>(
  (ref) => GuidanceController(
    getIt<VisionAnalyzer>(),
    getIt<ContextMemory>(),
  ),
);
