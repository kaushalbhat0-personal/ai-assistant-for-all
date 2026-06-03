import 'package:equatable/equatable.dart';

import 'analysis_result.dart';
import 'screenshot_data.dart';

class AnalysisMetrics extends Equatable {
  final Duration captureTime;
  final Duration processTime;
  final Duration apiTime;
  final Duration totalTime;
  final String modelUsed;
  final bool isSuccess;
  final int promptTokens;
  final int completionTokens;
  final int jpegSizeBytes;
  final int originalPngSizeBytes;

  const AnalysisMetrics({
    required this.captureTime,
    required this.processTime,
    required this.apiTime,
    required this.totalTime,
    required this.modelUsed,
    required this.isSuccess,
    this.promptTokens = 0,
    this.completionTokens = 0,
    this.jpegSizeBytes = 0,
    this.originalPngSizeBytes = 0,
  });

  double get compressionRatio {
    if (jpegSizeBytes == 0) return 0;
    return originalPngSizeBytes / jpegSizeBytes;
  }

  factory AnalysisMetrics.fromAnalysis(
    AnalysisResult result, {
    required ScreenshotData processed,
    required Duration captureTime,
    required Duration processTime,
    required Duration totalTime,
  }) {
    return AnalysisMetrics(
      captureTime: captureTime,
      processTime: processTime,
      apiTime: result.latency,
      totalTime: totalTime,
      modelUsed: result.modelUsed,
      isSuccess: true,
      promptTokens: result.tokenUsage?.promptTokens ?? 0,
      completionTokens: result.tokenUsage?.completionTokens ?? 0,
      jpegSizeBytes: processed.bytes.length,
      originalPngSizeBytes: processed.originalSizeBytes,
    );
  }

  @override
  List<Object?> get props => [
        captureTime,
        processTime,
        apiTime,
        totalTime,
        modelUsed,
        isSuccess,
        promptTokens,
        completionTokens,
        jpegSizeBytes,
        originalPngSizeBytes,
      ];
}
