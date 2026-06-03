import 'package:equatable/equatable.dart';

import 'prompt_profile.dart';

class VisionPrompt extends Equatable {
  final String systemPrompt;
  final String userPrompt;
  final PromptProfile profile;

  const VisionPrompt({
    required this.systemPrompt,
    required this.userPrompt,
    this.profile = PromptProfile.genericAssistant,
  });

  VisionPrompt copyWith({
    String? systemPrompt,
    String? userPrompt,
    PromptProfile? profile,
  }) {
    return VisionPrompt(
      systemPrompt: systemPrompt ?? this.systemPrompt,
      userPrompt: userPrompt ?? this.userPrompt,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [systemPrompt, userPrompt, profile];
}
