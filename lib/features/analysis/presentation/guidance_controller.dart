import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:screenfix_ai/core/errors/failures.dart';
import 'package:screenfix_ai/core/errors/result.dart';
import 'package:screenfix_ai/features/analysis/domain/analysis_metrics.dart';
import 'package:screenfix_ai/features/analysis/domain/analysis_result.dart';
import 'package:screenfix_ai/features/analysis/domain/guidance.dart';
import 'package:screenfix_ai/features/analysis/domain/prompt_profile.dart';
import 'package:screenfix_ai/features/analysis/domain/screen_event.dart';
import 'package:screenfix_ai/features/analysis/integration/context_memory.dart';
import 'package:screenfix_ai/features/analysis/integration/image_processor.dart';
import 'package:screenfix_ai/features/analysis/integration/vision_api_service.dart';
import 'package:screenfix_ai/features/analysis/integration/vision_prompt_builder.dart';
import 'package:screenfix_ai/features/analysis/presentation/guidance_state.dart';
import 'package:screenfix_ai/features/screen_capture/domain/screen_capture_result.dart';

class GuidanceController extends StateNotifier<GuidanceState> {
  final VisionAnalyzer _analyzer;
  final ContextMemory _contextMemory;

  GuidanceController(this._analyzer, this._contextMemory)
      : super(const GuidanceState.initial());

  Future<void> captureNow(
    ScreenCaptureResult raw, {
    Duration captureTime = Duration.zero,
    PromptProfile profile = PromptProfile.genericAssistant,
  }) async {
    state = state.copyWith(isProcessing: true, clearError: true);
    final totalSw = Stopwatch()..start();

    try {
      final procSw = Stopwatch()..start();
      final processed = await ImageProcessor.process(raw);
      procSw.stop();
      final processTime = procSw.elapsed;

      final contextStr = _contextMemory.buildContextString();
      final prompt = VisionPromptBuilder.build(
        profile: profile,
        workflowContext: contextStr.isNotEmpty ? contextStr : null,
      );

      final apiSw = Stopwatch()..start();
      final result = await _analyzer.analyze(data: processed, prompt: prompt);
      apiSw.stop();
      final apiTime = apiSw.elapsed;

      totalSw.stop();
      final totalTime = totalSw.elapsed;

      switch (result) {
        case Success<AnalysisResult>(data: final analysis):
          final guidance = Guidance.fromAnalysisResult(
            analysis,
            workflowContext: contextStr.isNotEmpty ? contextStr : null,
          );
          _contextMemory.record(ScreenEvent.fromGuidance(guidance));
          state = state.copyWith(
            isProcessing: false,
            current: guidance,
            history: [...state.history, guidance],
            contextSize: _contextMemory.size,
            metrics: AnalysisMetrics.fromAnalysis(
              analysis,
              processed: processed,
              captureTime: captureTime,
              processTime: processTime,
              totalTime: totalTime,
            ),
          );
        case Error<AnalysisResult>(failure: final failure):
          totalSw.stop();
          state = state.copyWith(
            isProcessing: false,
            error: failure,
            metrics: AnalysisMetrics(
              captureTime: captureTime,
              processTime: processTime,
              apiTime: apiTime,
              totalTime: totalTime,
              modelUsed: 'error',
              isSuccess: false,
            ),
          );
      }
    } catch (e, stack) {
      totalSw.stop();
      state = state.copyWith(
        isProcessing: false,
        error: UnknownFailure(
          message: 'Analysis pipeline failed',
          technicalDetails: e.toString(),
          stackTrace: stack,
        ),
      );
    }
  }

  void clearGuidance() {
    _contextMemory.clear();
    state = const GuidanceState.initial();
  }
}
