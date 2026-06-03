import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'package:screenfix_ai/core/ai/analysis_confidence.dart';
import 'package:screenfix_ai/core/ai/recommendation.dart';
import 'package:screenfix_ai/core/ai/screen_intent.dart';
import 'analysis_result.dart';

class Guidance extends Equatable {
  final String id;
  final DateTime timestamp;
  final ScreenIntent screenIntent;
  final String summary;
  final List<Recommendation> recommendations;
  final AnalysisConfidence confidence;
  final String? workflowContext;

  const Guidance({
    required this.id,
    required this.timestamp,
    required this.screenIntent,
    required this.summary,
    required this.recommendations,
    required this.confidence,
    this.workflowContext,
  });

  factory Guidance.fromAnalysisResult(
    AnalysisResult result, {
    String? workflowContext,
  }) {
    return Guidance(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      screenIntent: result.screenIntent,
      summary: result.summary,
      recommendations: result.recommendations,
      confidence: result.confidence,
      workflowContext: workflowContext,
    );
  }

  Guidance copyWith({
    String? id,
    DateTime? timestamp,
    ScreenIntent? screenIntent,
    String? summary,
    List<Recommendation>? recommendations,
    AnalysisConfidence? confidence,
    String? workflowContext,
  }) {
    return Guidance(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      screenIntent: screenIntent ?? this.screenIntent,
      summary: summary ?? this.summary,
      recommendations: recommendations ?? this.recommendations,
      confidence: confidence ?? this.confidence,
      workflowContext: workflowContext ?? this.workflowContext,
    );
  }

  @override
  List<Object?> get props => [
        id,
        timestamp,
        screenIntent,
        summary,
        recommendations,
        confidence,
        workflowContext,
      ];
}
