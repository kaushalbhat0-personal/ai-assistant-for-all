import 'package:equatable/equatable.dart';

import 'package:screenfix_ai/core/errors/failures.dart';
import 'package:screenfix_ai/features/analysis/domain/analysis_metrics.dart';
import 'package:screenfix_ai/features/analysis/domain/guidance.dart';

class GuidanceState extends Equatable {
  final bool isProcessing;
  final Guidance? current;
  final List<Guidance> history;
  final Failure? error;
  final int contextSize;
  final AnalysisMetrics? metrics;

  const GuidanceState({
    this.isProcessing = false,
    this.current,
    this.history = const [],
    this.error,
    this.contextSize = 0,
    this.metrics,
  });

  const GuidanceState.initial()
      : isProcessing = false,
        current = null,
        history = const [],
        error = null,
        contextSize = 0,
        metrics = null;

  GuidanceState copyWith({
    bool? isProcessing,
    Guidance? current,
    List<Guidance>? history,
    Failure? error,
    int? contextSize,
    AnalysisMetrics? metrics,
    bool clearError = false,
  }) {
    return GuidanceState(
      isProcessing: isProcessing ?? this.isProcessing,
      current: current ?? this.current,
      history: history ?? this.history,
      error: clearError ? null : (error ?? this.error),
      contextSize: contextSize ?? this.contextSize,
      metrics: metrics ?? this.metrics,
    );
  }

  @override
  List<Object?> get props => [
        isProcessing,
        current,
        history,
        error,
        contextSize,
        metrics,
      ];
}
