import 'package:screenfix_ai/infrastructure/logging/logger_service.dart';
import 'telemetry_event.dart';
import 'telemetry_service.dart';

class TelemetryLogger implements TelemetryInterface {
  final LoggerService _logger;

  const TelemetryLogger(this._logger);

  @override
  void track(TelemetryEvent event) {
    final tag = 'Telemetry';
    final duration = event.duration != null
        ? ' | duration: ${event.duration!.inMilliseconds}ms'
        : '';
    final session = event.sessionId != null
        ? ' | session: ${event.sessionId}'
        : '';

    _logger.info(
      '${event.type.name}$duration$session',
      tag: tag,
    );
  }
}
