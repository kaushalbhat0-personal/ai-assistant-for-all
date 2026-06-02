enum PromptProfile {
  basic,
  detailed,
  debug;

  String get displayName {
    return switch (this) {
      PromptProfile.basic => 'Basic',
      PromptProfile.detailed => 'Detailed',
      PromptProfile.debug => 'Debug',
    };
  }

  String get description {
    return switch (this) {
      PromptProfile.basic => 'Concise prompt for quick analysis',
      PromptProfile.detailed => 'Comprehensive prompt with full context',
      PromptProfile.debug => 'Verbose prompt with all internal state for debugging',
    };
  }
}
