import 'feature_flag.dart';

class FeatureFlagService {
  static const Map<FeatureFlag, bool> _safeDefaults = {
    FeatureFlag.enableLocalAnalysisV2: false,
    FeatureFlag.enablePromptEngineV2: false,
    FeatureFlag.enableAgentActions: false,
    FeatureFlag.enableStreamingResponses: false,
    FeatureFlag.enableDeveloperMode: false,
  };

  final Map<FeatureFlag, bool> _overrides = {};

  bool isEnabled(FeatureFlag flag) {
    return _overrides[flag] ?? _safeDefaults[flag] ?? false;
  }

  void setOverride(FeatureFlag flag, bool value) {
    _overrides[flag] = value;
  }

  void removeOverride(FeatureFlag flag) {
    _overrides.remove(flag);
  }

  void resetOverrides() {
    _overrides.clear();
  }
}
