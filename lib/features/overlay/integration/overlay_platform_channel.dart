import 'package:flutter/services.dart';

import 'package:screenfix_ai/core/di/get_it.dart';
import 'package:screenfix_ai/infrastructure/logging/logger_service.dart';

class OverlayPlatformChannel {
  static const _channel = MethodChannel('screenfix_ai/overlay');

  final LoggerService _logger;

  OverlayPlatformChannel() : _logger = getIt<LoggerService>();

  Future<bool> checkOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkOverlayPermission');
      return result ?? false;
    } on MissingPluginException catch (e) {
      _logger.error(
        'checkOverlayPermission: plugin not available',
        tag: 'OverlayPlatformChannel',
        error: e,
      );
      return false;
    } on PlatformException catch (e) {
      _logger.error(
        'checkOverlayPermission: platform error',
        tag: 'OverlayPlatformChannel',
        error: e,
      );
      return false;
    }
  }

  Future<bool> requestOverlayPermission() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('requestOverlayPermission');
      return result ?? false;
    } on MissingPluginException catch (e) {
      _logger.error(
        'requestOverlayPermission: plugin not available',
        tag: 'OverlayPlatformChannel',
        error: e,
      );
      return false;
    } on PlatformException catch (e) {
      _logger.error(
        'requestOverlayPermission: platform error',
        tag: 'OverlayPlatformChannel',
        error: e,
      );
      return false;
    }
  }
}
