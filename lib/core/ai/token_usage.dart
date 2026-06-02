import 'package:equatable/equatable.dart';

class TokenUsage extends Equatable {
  final String provider;
  final String model;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final double estimatedCost;
  final DateTime timestamp;

  const TokenUsage({
    required this.provider,
    required this.model,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    required this.estimatedCost,
    required this.timestamp,
  });

  TokenUsage copyWith({
    String? provider,
    String? model,
    int? promptTokens,
    int? completionTokens,
    int? totalTokens,
    double? estimatedCost,
    DateTime? timestamp,
  }) {
    return TokenUsage(
      provider: provider ?? this.provider,
      model: model ?? this.model,
      promptTokens: promptTokens ?? this.promptTokens,
      completionTokens: completionTokens ?? this.completionTokens,
      totalTokens: totalTokens ?? this.totalTokens,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
        provider,
        model,
        promptTokens,
        completionTokens,
        totalTokens,
        estimatedCost,
        timestamp,
      ];
}
