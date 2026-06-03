import 'package:screenfix_ai/features/analysis/domain/prompt_profile.dart';
import 'package:screenfix_ai/features/analysis/domain/vision_prompt.dart';

class VisionPromptBuilder {
  VisionPromptBuilder._();

  static VisionPrompt build({
    PromptProfile profile = PromptProfile.genericAssistant,
    String? workflowContext,
  }) {
    return VisionPrompt(
      profile: profile,
      systemPrompt: _systemPrompt(profile),
      userPrompt: _userPrompt(profile, workflowContext),
    );
  }

  static String _systemPrompt(PromptProfile profile) {
    return switch (profile) {
      PromptProfile.genericAssistant => _genericSystemPrompt,
      PromptProfile.tradingAssistant => _tradingSystemPrompt,
      PromptProfile.codingAssistant => _codingSystemPrompt,
      PromptProfile.productivityAssistant => _productivitySystemPrompt,
    };
  }

  static String _userPrompt(PromptProfile profile, String? context) {
    final buffer = StringBuffer();

    switch (profile) {
      case PromptProfile.tradingAssistant:
        buffer.writeln('Analyze this chart or trading screen.');
        buffer.writeln('- Identify the trend (bullish, bearish, sideways)');
        buffer.writeln('- Note key support/resistance levels');
        buffer.writeln('- Suggest the next trading action');
      case PromptProfile.codingAssistant:
        buffer.writeln('Analyze this IDE or code editor screen.');
        buffer.writeln('- Identify any errors, warnings, or lint issues');
        buffer.writeln('- Suggest fixes with code snippets if applicable');
        buffer.writeln('- Note the programming language and framework');
      case PromptProfile.productivityAssistant:
        buffer.writeln('Analyze this productivity or work screen.');
        buffer.writeln('- Identify the current task or workflow step');
        buffer.writeln('- Suggest the most efficient next action');
        buffer.writeln('- Note any blockers or distractions');
      case PromptProfile.genericAssistant:
        buffer.writeln('Analyze this screen and tell me what I should do next.');
    }

    if (context != null && context.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Workflow context: $context');
    }

    buffer.writeln();
    buffer.writeln('Return ONLY valid JSON with this exact structure:');
    buffer.writeln('{');
    buffer.writeln('  "intent": "error|login|signup|payment|form|settings|socialMedia|unknown",');
    buffer.writeln('  "summary": "one-line description of what this screen is",');
    buffer.writeln('  "steps": [');
    buffer.writeln('    { "type": "action|information|warning", "title": "...", "description": "..." }');
    if (profile != PromptProfile.genericAssistant) {
      buffer.writeln('    { "type": "action|information|warning", "title": "...", "description": "..." }');
    }
    buffer.writeln('  ],');
    buffer.writeln('  "confidence": { "ocr": 0.0, "intent": 0.0, "local": 0.0, "ai": 0.0 }');
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('Respond with the JSON only, no markdown, no explanation.');

    return buffer.toString();
  }

  static const String _genericSystemPrompt =
      'You are a screen analysis assistant. Your job is to look at a screenshot '
      'of a mobile app and tell the user what they should do next. '
      'Keep guidance concise and actionable.';

  static const String _tradingSystemPrompt =
      'You are a trading screen analysis assistant. Analyze charts, '
      'identify trends (bullish, bearish, sideways), note support/resistance '
      'levels, and suggest actionable trade decisions. Be specific about '
      'price action indicators visible on screen.';

  static const String _codingSystemPrompt =
      'You are a coding assistant that analyzes IDE screenshots. '
      'Identify programming languages, frameworks, errors, warnings, '
      'and lint issues. Suggest specific fixes with code snippets. '
      'Be precise about file types and error messages visible.';

  static const String _productivitySystemPrompt =
      'You are a productivity assistant analyzing work screens. '
      'Identify the current task, workflow stage, and suggest the '
      'most efficient next action. Note any blockers, distractions, '
      'or opportunities to optimize the workflow.';
}
