enum PromptProfile {
  genericAssistant,
  tradingAssistant,
  codingAssistant,
  productivityAssistant;

  String get displayName {
    return switch (this) {
      PromptProfile.genericAssistant => 'Generic Assistant',
      PromptProfile.tradingAssistant => 'Trading Assistant',
      PromptProfile.codingAssistant => 'Coding Assistant',
      PromptProfile.productivityAssistant => 'Productivity Assistant',
    };
  }

  String get description {
    return switch (this) {
      PromptProfile.genericAssistant =>
        'General-purpose screen analysis for any app',
      PromptProfile.tradingAssistant =>
        'Chart analysis, trend identification, trade recommendation',
      PromptProfile.codingAssistant =>
        'IDE screen analysis, error detection, fix suggestions',
      PromptProfile.productivityAssistant =>
        'Task analysis, next-step suggestions, workflow optimization',
    };
  }
}
