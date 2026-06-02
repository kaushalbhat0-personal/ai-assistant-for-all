import 'package:equatable/equatable.dart';

import 'screen_intent.dart';
import 'prompt_profile.dart';

class StructuredPrompt extends Equatable {
  final String id;
  final String version;
  final ScreenIntent intent;
  final PromptProfile profile;
  final String systemPrompt;
  final String userPrompt;
  final Map<String, dynamic> metadata;

  const StructuredPrompt({
    required this.id,
    required this.version,
    required this.intent,
    required this.profile,
    required this.systemPrompt,
    required this.userPrompt,
    this.metadata = const {},
  });

  StructuredPrompt copyWith({
    String? id,
    String? version,
    ScreenIntent? intent,
    PromptProfile? profile,
    String? systemPrompt,
    String? userPrompt,
    Map<String, dynamic>? metadata,
  }) {
    return StructuredPrompt(
      id: id ?? this.id,
      version: version ?? this.version,
      intent: intent ?? this.intent,
      profile: profile ?? this.profile,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      userPrompt: userPrompt ?? this.userPrompt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        version,
        intent,
        profile,
        systemPrompt,
        userPrompt,
        metadata,
      ];
}
