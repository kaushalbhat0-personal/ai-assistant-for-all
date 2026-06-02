import 'package:equatable/equatable.dart';

enum RecommendationType {
  information,
  warning,
  action,
  error;

  String get displayName {
    return switch (this) {
      RecommendationType.information => 'Information',
      RecommendationType.warning => 'Warning',
      RecommendationType.action => 'Action',
      RecommendationType.error => 'Error',
    };
  }
}

enum RecommendationAction {
  none,
  retry,
  openSettings,
  checkConnection,
  contactSupport;

  String get displayName {
    return switch (this) {
      RecommendationAction.none => 'None',
      RecommendationAction.retry => 'Retry',
      RecommendationAction.openSettings => 'Open Settings',
      RecommendationAction.checkConnection => 'Check Connection',
      RecommendationAction.contactSupport => 'Contact Support',
    };
  }
}

class Recommendation extends Equatable {
  final RecommendationType type;
  final String title;
  final String description;
  final double confidence;
  final RecommendationAction action;
  final Map<String, dynamic> metadata;

  const Recommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    this.action = RecommendationAction.none,
    this.metadata = const {},
  });

  Recommendation copyWith({
    RecommendationType? type,
    String? title,
    String? description,
    double? confidence,
    RecommendationAction? action,
    Map<String, dynamic>? metadata,
  }) {
    return Recommendation(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      confidence: confidence ?? this.confidence,
      action: action ?? this.action,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        type,
        title,
        description,
        confidence,
        action,
        metadata,
      ];
}
