import 'package:flutter/services.dart';

import 'package:screenfix_ai/core/di/get_it.dart';
import 'package:screenfix_ai/infrastructure/logging/logger_service.dart';

class ScreenCapturePlatformChannel {
  static const _permissionChannel =
      MethodChannel('screenfix_ai/screen_capture_permission');
  static const _captureChannel =
      MethodChannel('screenfix_ai/screen_capture');

  final LoggerService _logger;

  ScreenCapturePlatformChannel() : _logger = getIt<LoggerService>();

  Future<bool> requestPermission() async {
    try {
      final result =
          await _permissionChannel.invokeMethod<bool>('requestPermission');
      return result ?? false;
    } on MissingPluginException catch (e) {
      _logger.error(
        'requestPermission: plugin not available',
        tag: 'ScreenCaptureChannel',
        error: e,
      );
      return false;
    } on PlatformException catch (e) {
      _logger.error(
        'requestPermission: platform error',
        tag: 'ScreenCaptureChannel',
        error: e,
      );
      return false;
    }
  }

  Future<bool> checkPermission() async {
    try {
      final result =
          await _permissionChannel.invokeMethod<bool>('checkPermission');
      return result ?? false;
    } on MissingPluginException catch (e) {
      _logger.error(
        'checkPermission: plugin not available',
        tag: 'ScreenCaptureChannel',
        error: e,
      );
      return false;
    } on PlatformException catch (e) {
      _logger.error(
        'checkPermission: platform error',
        tag: 'ScreenCaptureChannel',
        error: e,
      );
      return false;
    }
  }

  Future<Map<String, dynamic>?> captureScreen() async {
    try {
      final result =
          await _captureChannel.invokeMethod<Map<dynamic, dynamic>>(
        'captureScreen',
      );
      if (result == null) return null;
      return result.cast<String, dynamic>();
    } on MissingPluginException catch (e) {
      _logger.error(
        'captureScreen: plugin not available',
        tag: 'ScreenCaptureChannel',
        error: e,
      );
      return null;
    } on PlatformException catch (e) {
      _logger.error(
        'captureScreen: platform error',
        tag: 'ScreenCaptureChannel',
        error: e,
      );
      return null;
    }
  }
}
