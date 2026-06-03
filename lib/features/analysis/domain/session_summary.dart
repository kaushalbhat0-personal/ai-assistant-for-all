import 'package:equatable/equatable.dart';

import 'package:screenfix_ai/core/ai/screen_intent.dart';
import 'screen_event.dart';

class SessionSummary extends Equatable {
  final int totalCaptures;
  final List<ScreenIntent> intentsSeen;
  final int totalRecommendations;
  final Map<ScreenIntent, int> intentFrequency;
  final DateTime startedAt;
  final Duration elapsed;

  const SessionSummary({
    required this.totalCaptures,
    required this.intentsSeen,
    required this.totalRecommendations,
    required this.intentFrequency,
    required this.startedAt,
    required this.elapsed,
  });

  factory SessionSummary.fromEvents(List<ScreenEvent> events) {
    final intentsSeen = events.map((e) => e.intent).toList();
    final intentFrequency = <ScreenIntent, int>{};
    var totalRecs = 0;

    for (final event in events) {
      intentFrequency.update(event.intent, (v) => v + 1, ifAbsent: () => 1);
      totalRecs += event.recommendations.length;
    }

    return SessionSummary(
      totalCaptures: events.length,
      intentsSeen: intentsSeen,
      totalRecommendations: totalRecs,
      intentFrequency: intentFrequency,
      startedAt: events.isNotEmpty ? events.first.timestamp : DateTime.now(),
      elapsed: events.isNotEmpty
          ? events.last.timestamp.difference(events.first.timestamp)
          : Duration.zero,
    );
  }

  @override
  List<Object?> get props => [
        totalCaptures,
        intentsSeen,
        totalRecommendations,
        intentFrequency,
        startedAt,
        elapsed,
      ];
}
