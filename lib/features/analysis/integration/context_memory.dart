import 'package:screenfix_ai/core/ai/recommendation.dart';
import 'package:screenfix_ai/features/analysis/domain/screen_event.dart';
import 'package:screenfix_ai/features/analysis/domain/session_summary.dart';

class ContextMemory {
  final List<ScreenEvent> _events = [];

  static const int maxSize = 20;

  void record(ScreenEvent event) {
    _events.add(event);
    if (_events.length > maxSize) {
      _events.removeAt(0);
    }
  }

  void clear() {
    _events.clear();
  }

  List<ScreenEvent> get events => List.unmodifiable(_events);

  int get size => _events.length;

  SessionSummary get summary => SessionSummary.fromEvents(_events);

  String buildContextString() {
    if (_events.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('Previous screens analyzed in this session:');
    buffer.writeln();

    for (var i = 0; i < _events.length; i++) {
      final event = _events[i];
      final confidencePct = (event.confidence.overallConfidence * 100).round();
      buffer.writeln(
        '  ${i + 1}. ${event.intent.displayName} — '
        '"${event.summary}" '
        '(confidence: $confidencePct%)',
      );
      if (event.recommendations.isNotEmpty) {
        final actions = event.recommendations
            .where((r) => r.type == RecommendationType.action)
            .map((r) => r.title)
            .join(', ');
        if (actions.isNotEmpty) {
          buffer.writeln('     Suggested actions: $actions');
        }
      }
    }

    buffer.writeln();
    buffer.writeln(
      'Use this history to provide guidance that is aware of '
      'what has already been seen and what actions were suggested. '
      'Do not repeat suggestions that have already been made unless '
      'the user has clearly not followed them and they remain relevant.',
    );

    return buffer.toString();
  }
}
