import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'package:screenfix_ai/core/ai/analysis_confidence.dart';
import 'package:screenfix_ai/core/ai/recommendation.dart';
import 'package:screenfix_ai/core/ai/screen_intent.dart';
import 'guidance.dart';

class ScreenEvent extends Equatable {
  final String id;
  final DateTime timestamp;
  final ScreenIntent intent;
  final String summary;
  final List<Recommendation> recommendations;
  final AnalysisConfidence confidence;

  const ScreenEvent({
    required this.id,
    required this.timestamp,
    required this.intent,
    required this.summary,
    required this.recommendations,
    required this.confidence,
  });

  factory ScreenEvent.fromGuidance(Guidance guidance) {
    return ScreenEvent(
      id: const Uuid().v4(),
      timestamp: guidance.timestamp,
      intent: guidance.screenIntent,
      summary: guidance.summary,
      recommendations: guidance.recommendations,
      confidence: guidance.confidence,
    );
  }

  @override
  List<Object?> get props => [
        id,
        timestamp,
        intent,
        summary,
        recommendations,
        confidence,
      ];
}
