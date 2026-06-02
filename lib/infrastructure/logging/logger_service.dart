import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  wtf;

  bool get isVisible {
    if (kDebugMode) return true;
    return index >= LogLevel.warning.index;
  }
}

class LoggerService {
  const LoggerService();

  void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  void warning(String message, {String? tag, Object? error}) {
    _log(LogLevel.warning, message, tag: tag, error: error);
  }

  void error(String message, {String? tag, Object? error, StackTrace? stack}) {
    _log(LogLevel.error, message, tag: tag, error: error, stack: stack);
  }

  void wtf(String message, {String? tag, Object? error, StackTrace? stack}) {
    _log(LogLevel.wtf, message, tag: tag, error: error, stack: stack);
  }

  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stack,
  }) {
    if (!level.isVisible) return;

    final timestamp = DateTime.now().toIso8601String();
    final tagStr = tag != null ? '[$tag]' : '';

    debugPrint('[$timestamp] [${level.name.toUpperCase()}] $tagStr $message');

    if (error != null) {
      debugPrint('  └─ Error: $error');
    }
    if (stack != null && level == LogLevel.wtf) {
      debugPrint('  └─ StackTrace: $stack');
    }
  }
}
