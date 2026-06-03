import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:screenfix_ai/core/config/app_config.dart';
import 'package:screenfix_ai/core/di/get_it.dart';
import 'package:screenfix_ai/core/errors/result.dart';
import 'package:screenfix_ai/core/network/dio_client.dart';
import 'package:screenfix_ai/infrastructure/logging/logger_service.dart';
import 'package:screenfix_ai/features/analysis/domain/vision_error.dart';

class VisionApiClient {
  final Dio _dio;
  final LoggerService _logger;

  VisionApiClient()
      : _dio = DioClient.create(getIt<LoggerService>()),
        _logger = getIt<LoggerService>();

  Future<Result<Map<String, dynamic>>> analyzeImage({
    required Uint8List imageBytes,
    required String systemPrompt,
    required String userPrompt,
    String? model,
  }) async {
    debugPrint('API KEY PRESENT: ${AppConfig.openRouterApiKey.isNotEmpty}');
    debugPrint('Provider: ${VisionProvider.defaultProvider}');
    debugPrint('Authorization Present: ${AppConfig.hasValidApiKey}');

    if (!AppConfig.hasValidApiKey) {
      return Error(VisionUnauthorized());
    }

    try {
      final base64Image = base64Encode(imageBytes);
      final dataUri = 'data:image/jpeg;base64,$base64Image';

      final body = {
        'model': model ?? 'openai/gpt-4o',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': userPrompt},
              {
                'type': 'image_url',
                'image_url': {'url': dataUri, 'detail': 'auto'},
              },
            ],
          },
        ],
        'max_tokens': 1024,
      };

      final response = await _dio.post(
        AppConfig.visionApiEndpoint,
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.openRouterApiKey}',
            'HTTP-Referer': 'ScreenFixAI',
            'X-Title': 'ScreenFix AI',
          },
        ),
      );

      debugPrint('OpenRouter status: ${response.statusCode}');
      debugPrint('OpenRouter body: ${response.data}');

      if (response.statusCode == 200 && response.data is Map) {
        return Success(Map<String, dynamic>.from(response.data));
      }

      return Error(
        _mapStatusCode(response.statusCode, response.statusMessage),
      );
    } on DioException catch (e) {
      debugPrint('OpenRouter DioException type: ${e.type}');
      debugPrint('OpenRouter DioException status: ${e.response?.statusCode}');
      debugPrint('OpenRouter DioException body: ${e.response?.data}');
      _logger.error('VisionApiClient: ${e.message}', tag: 'VisionApi');
      return Error(_mapDioException(e));
    } catch (e, stack) {
      _logger.error('VisionApiClient: unexpected $e', tag: 'VisionApi', error: e);
      return Error(
        VisionUnknownError(
          technicalDetails: e.toString(),
          stackTrace: stack,
        ),
      );
    }
  }

  Future<List<String>> fetchFreeVisionModels() async {
    debugPrint('MODEL_DISCOVERY_STARTED');

    try {
      final response = await _dio.get(
        AppConfig.visionModelsEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.openRouterApiKey}',
          },
        ),
      );

      if (response.statusCode != 200 || response.data is! Map) {
        debugPrint('MODEL_DISCOVERY_FAILED: status ${response.statusCode}');
        return [];
      }

      final data = response.data as Map<String, dynamic>;
      final models = data['data'] as List<dynamic>? ?? [];

      debugPrint('TOTAL_MODELS_RECEIVED=${models.length}');

      final limit = models.length < 20 ? models.length : 20;
      for (var i = 0; i < limit; i++) {
        final item = models[i] as Map? ?? {};
        final arch = item['architecture'] as Map? ?? {};
        debugPrint('MODEL_ID=${item['id']}');
        debugPrint('  MODALITY=${arch['modality']}');
        debugPrint('  INPUT_MODALITIES=${arch['input_modalities']}');
        debugPrint('  PRICING=${item['pricing']}');
      }

      final visionModels = <String>[];
      final freeModels = <String>[];
      final freeVisionModels = <String>[];

      for (final item in models) {
        if (item is! Map) continue;
        final id = item['id'] as String?;
        if (id == null) continue;

        final arch = item['architecture'] as Map? ?? {};
        final inputModalities = arch['input_modalities'] as List<dynamic>? ?? [];
        final modality = (arch['modality'] as String?) ?? '';
        final supportsImage = inputModalities.contains('image') ||
            modality.contains('image');

        if (supportsImage) {
          visionModels.add(id);
        }

        final pricing = item['pricing'] as Map?;
        if (pricing == null) continue;
        final promptPrice = pricing['prompt'];
        final completionPrice = pricing['completion'];
        final promptNum = (promptPrice is num) ? promptPrice : double.tryParse('$promptPrice') ?? -1;
        final completionNum = (completionPrice is num) ? completionPrice : double.tryParse('$completionPrice') ?? -1;
        final isFree = promptNum == 0 && completionNum == 0;

        if (isFree) {
          freeModels.add(id);
        }

        if (isFree && supportsImage) {
          freeVisionModels.add(id);
        }
      }

      debugPrint('VISION_MODELS_FOUND=$visionModels');
      debugPrint('FREE_MODELS_FOUND=$freeModels');
      debugPrint('FREE_VISION_MODELS=$freeVisionModels');

      if (freeVisionModels.isNotEmpty) {
        debugPrint('MODEL_DISCOVERY_RESULTS: $freeVisionModels');
        return freeVisionModels;
      }

      if (visionModels.isEmpty) {
        debugPrint('MODEL_DISCOVERY_RESULTS: [] — no vision-capable models found');
        return [];
      }

      debugPrint('MODEL_DISCOVERY_RESULTS: [] — no free vision models, selecting cheapest vision model');

      String? cheapestModel;
      double cheapestPrice = double.infinity;

      for (final item in models) {
        if (item is! Map) continue;
        final id = item['id'] as String?;
        if (id == null) continue;

        final arch = item['architecture'] as Map? ?? {};
        final inputModalities = arch['input_modalities'] as List<dynamic>? ?? [];
        final modality = (arch['modality'] as String?) ?? '';
        final supportsImage = inputModalities.contains('image') ||
            modality.contains('image');
        if (!supportsImage) continue;

        final pricing = item['pricing'] as Map?;
        if (pricing == null) continue;
        final promptPrice = pricing['prompt'];
        final completionPrice = pricing['completion'];
        final promptNum = (promptPrice is num) ? promptPrice : double.tryParse('$promptPrice') ?? double.infinity;
        final completionNum = (completionPrice is num) ? completionPrice : double.tryParse('$completionPrice') ?? double.infinity;
        final promptVal = promptNum.toDouble();
        final completionVal = completionNum.toDouble();
        final totalPrice = promptVal + completionVal;

        if (totalPrice < cheapestPrice) {
          cheapestPrice = totalPrice;
          cheapestModel = id;
        }
      }

      if (cheapestModel != null) {
        debugPrint('MODEL_DISCOVERY_RESULTS: [$cheapestModel] (cheapest vision model at price $cheapestPrice)');
        return [cheapestModel];
      }

      debugPrint('MODEL_DISCOVERY_RESULTS: [] — no vision models at all');
      return [];
    } on DioException catch (e) {
      debugPrint('MODEL_DISCOVERY_ERROR: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('MODEL_DISCOVERY_ERROR: $e');
      return [];
    }
  }

  VisionError _mapStatusCode(int? statusCode, String? statusMessage) {
    return switch (statusCode) {
      401 => VisionUnauthorized(technicalDetails: statusMessage),
      429 => VisionRateLimited(technicalDetails: statusMessage),
      500 || 502 || 503 => VisionUnknownError(
        technicalDetails: 'OpenRouter returned HTTP $statusCode: $statusMessage',
      ),
      _ => VisionInvalidResponse(
        technicalDetails: 'Unexpected status $statusCode: $statusMessage',
      ),
    };
  }

  VisionError _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return _mapStatusCode(statusCode, e.response?.statusMessage);
    }

    return switch (e.type) {
      DioExceptionType.connectionTimeout || DioExceptionType.sendTimeout => VisionTimeout(),
      DioExceptionType.receiveTimeout => VisionTimeout(),
      DioExceptionType.connectionError => VisionNetworkError(),
      DioExceptionType.badResponse => _mapStatusCode(
        e.response?.statusCode,
        e.response?.statusMessage,
      ),
      DioExceptionType.cancel => VisionUnknownError(
        technicalDetails: 'Request was cancelled',
      ),
      DioExceptionType.badCertificate => VisionNetworkError(
        technicalDetails: 'Invalid SSL certificate',
      ),
      _ => VisionUnknownError(technicalDetails: e.message),
    };
  }
}
