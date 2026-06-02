import 'telemetry_event.dart';

abstract class TelemetryInterface {
  void track(TelemetryEvent event);
}

class TelemetryService implements TelemetryInterface {
  final List<TelemetryInterface> _consumers = [];

  void register(TelemetryInterface consumer) {
    _consumers.add(consumer);
  }

  @override
  void track(TelemetryEvent event) {
    for (final consumer in _consumers) {
      try {
        consumer.track(event);
      } catch (_) {
        // Never let telemetry crash the app.
      }
    }
  }
}
