import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:screenfix_ai/core/ai/analysis_confidence.dart';
import 'package:screenfix_ai/core/ai/recommendation.dart';
import 'package:screenfix_ai/core/ai/screen_intent.dart';
import 'package:screenfix_ai/core/ai/token_usage.dart';

class AnalysisResult extends Equatable {
  final ScreenIntent screenIntent;
  final String summary;
  final List<Recommendation> recommendations;
  final AnalysisConfidence confidence;
  final TokenUsage? tokenUsage;
  final String rawResponse;
  final String modelUsed;
  final Duration latency;

  const AnalysisResult({
    required this.screenIntent,
    required this.summary,
    required this.recommendations,
    required this.confidence,
    this.tokenUsage,
    required this.rawResponse,
    this.modelUsed = 'unknown',
    this.latency = Duration.zero,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json, {Duration latency = Duration.zero}) {
    final choices = json['choices'] as List?;
    final content = choices != null && choices.isNotEmpty
        ? (choices[0]['message']?['content'] as String? ?? '')
        : '';

    Map<String, dynamic> parsed;
    try {
      parsed = Map<String, dynamic>.from(jsonDecode(content) as Map);
    } catch (_) {
      parsed = {};
    }

    final steps = (parsed['steps'] as List?)?.map((s) {
      final step = Map<String, dynamic>.from(s as Map);
      return Recommendation(
        type: RecommendationType.values.firstWhere(
          (e) => e.name == (step['type'] as String? ?? 'information'),
          orElse: () => RecommendationType.information,
        ),
        title: step['title'] as String? ?? '',
        description: step['description'] as String? ?? '',
        confidence: (step['confidence'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    final conf = parsed['confidence'] as Map<String, dynamic>? ?? {};

    TokenUsage? usage;
    final rawUsage = json['usage'] as Map<String, dynamic>?;
    if (rawUsage != null) {
      usage = TokenUsage(
        provider: 'openrouter',
        model: json['model'] as String? ?? 'unknown',
        promptTokens: (rawUsage['prompt_tokens'] as num?)?.toInt() ?? 0,
        completionTokens: (rawUsage['completion_tokens'] as num?)?.toInt() ?? 0,
        totalTokens: (rawUsage['total_tokens'] as num?)?.toInt() ?? 0,
        estimatedCost: 0.0,
        timestamp: DateTime.now(),
      );
    }

    return AnalysisResult(
      screenIntent: ScreenIntent.values.firstWhere(
        (e) => e.name == (parsed['intent'] as String? ?? 'unknown'),
        orElse: () => ScreenIntent.unknown,
      ),
      summary: parsed['summary'] as String? ?? '',
      recommendations: steps ?? [],
      confidence: AnalysisConfidence(
        ocrConfidence: (conf['ocr'] as num?)?.toDouble() ?? 0.0,
        intentConfidence: (conf['intent'] as num?)?.toDouble() ?? 0.0,
        localAnalysisConfidence: (conf['local'] as num?)?.toDouble() ?? 0.0,
        aiConfidence: (conf['ai'] as num?)?.toDouble() ?? 0.0,
      ),
      tokenUsage: usage,
      rawResponse: content,
      modelUsed: json['model'] as String? ?? 'unknown',
      latency: latency,
    );
  }

  @override
  List<Object?> get props => [
        screenIntent,
        summary,
        recommendations,
        confidence,
        tokenUsage,
        rawResponse,
        modelUsed,
        latency,
      ];
}
