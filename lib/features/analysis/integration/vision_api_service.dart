import 'package:flutter/foundation.dart';

import 'package:screenfix_ai/core/errors/result.dart';
import 'package:screenfix_ai/features/analysis/domain/analysis_result.dart';
import 'package:screenfix_ai/features/analysis/domain/screenshot_data.dart';
import 'package:screenfix_ai/features/analysis/domain/vision_error.dart';
import 'package:screenfix_ai/features/analysis/domain/vision_prompt.dart';
import 'package:screenfix_ai/features/analysis/integration/vision_api_client.dart';

class OpenRouterModels {
  static const String paid = 'openai/gpt-4o';
  static const String autoFree = 'openrouter/free';

  static List<String>? _discoveredFreeModels;

  static Future<List<String>> getFreeModels(VisionApiClient client) async {
    if (_discoveredFreeModels != null) return _discoveredFreeModels!;

    final models = await client.fetchFreeVisionModels();
    _discoveredFreeModels = models;

    if (models.isEmpty) {
      debugPrint('MODEL_DISCOVERY_EMPTY: no free vision models found, analysis will fail');
    }

    return models;
  }

  static void resetDiscovery() {
    _discoveredFreeModels = null;
  }

  const OpenRouterModels._();
}

abstract class VisionAnalyzer {
  Future<Result<AnalysisResult>> analyze({
    required ScreenshotData data,
    required VisionPrompt prompt,
  });
}

class OpenRouterPaidService implements VisionAnalyzer {
  final VisionApiClient _client;

  OpenRouterPaidService(this._client);

  @override
  Future<Result<AnalysisResult>> analyze({
    required ScreenshotData data,
    required VisionPrompt prompt,
  }) async {
    return _tryModel(_client, data, prompt, OpenRouterModels.paid);
  }
}

class OpenRouterFreeService implements VisionAnalyzer {
  final VisionApiClient _client;

  OpenRouterFreeService(this._client);

  @override
  Future<Result<AnalysisResult>> analyze({
    required ScreenshotData data,
    required VisionPrompt prompt,
  }) async {
    debugPrint('FREE_SERVICE: trying openrouter/free first');
    final autoResult = await _tryModel(_client, data, prompt, OpenRouterModels.autoFree);
    if (autoResult is Success<AnalysisResult>) {
      debugPrint('FREE_SERVICE: openrouter/free succeeded');
      return autoResult;
    }

    debugPrint('FREE_SERVICE: openrouter/free failed, trying discovered models');
    final models = await OpenRouterModels.getFreeModels(_client);
    if (models.isEmpty) {
      return Error(
        VisionUnknownError(
          technicalDetails: 'openrouter/free failed and no free vision models discovered from OpenRouter',
        ),
      );
    }

    for (final model in models) {
      final result = await _tryModel(_client, data, prompt, model);
      if (result is Success<AnalysisResult>) {
        return result;
      }
    }

    return Error(
      VisionUnknownError(
        technicalDetails: 'openrouter/free and all discovered free models failed',
      ),
    );
  }
}

Future<Result<AnalysisResult>> _tryModel(
  VisionApiClient client,
  ScreenshotData data,
  VisionPrompt prompt,
  String model,
) async {
  final sw = Stopwatch()..start();
  final response = await client.analyzeImage(
    imageBytes: data.bytes,
    systemPrompt: prompt.systemPrompt,
    userPrompt: prompt.userPrompt,
    model: model,
  );
  final latency = sw.elapsed;

  return switch (response) {
    Success<Map<String, dynamic>>(data: final json) =>
        Success(AnalysisResult.fromJson(json, latency: latency)),
    Error<Map<String, dynamic>>(failure: final failure) => Error(failure),
  };
}
