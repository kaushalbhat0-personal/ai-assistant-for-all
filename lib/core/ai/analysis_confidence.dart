import 'package:equatable/equatable.dart';

enum ConfidenceLevel {
  high,
  medium,
  low;

  String get displayName {
    return switch (this) {
      ConfidenceLevel.high => 'High',
      ConfidenceLevel.medium => 'Medium',
      ConfidenceLevel.low => 'Low',
    };
  }
}

class AnalysisConfidence extends Equatable {
  final double ocrConfidence;
  final double intentConfidence;
  final double localAnalysisConfidence;
  final double aiConfidence;

  const AnalysisConfidence({
    required this.ocrConfidence,
    required this.intentConfidence,
    required this.localAnalysisConfidence,
    required this.aiConfidence,
  });

  double get overallConfidence {
    return (ocrConfidence +
            intentConfidence +
            localAnalysisConfidence +
            aiConfidence) /
        4;
  }

  ConfidenceLevel get classification {
    final overall = overallConfidence;
    if (overall >= 0.8) return ConfidenceLevel.high;
    if (overall >= 0.5) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }

  AnalysisConfidence copyWith({
    double? ocrConfidence,
    double? intentConfidence,
    double? localAnalysisConfidence,
    double? aiConfidence,
  }) {
    return AnalysisConfidence(
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
      intentConfidence: intentConfidence ?? this.intentConfidence,
      localAnalysisConfidence:
          localAnalysisConfidence ?? this.localAnalysisConfidence,
      aiConfidence: aiConfidence ?? this.aiConfidence,
    );
  }

  @override
  List<Object?> get props => [
        ocrConfidence,
        intentConfidence,
        localAnalysisConfidence,
        aiConfidence,
      ];
}
