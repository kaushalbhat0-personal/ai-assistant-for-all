class DeviceIdentity {
  final String anonymousId;
  final DateTime createdAt;
  final int launchCount;

  const DeviceIdentity({
    required this.anonymousId,
    required this.createdAt,
    required this.launchCount,
  });

  DeviceIdentity copyWith({int? launchCount}) {
    return DeviceIdentity(
      anonymousId: anonymousId,
      createdAt: createdAt,
      launchCount: launchCount ?? this.launchCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'anonymousId': anonymousId,
    'createdAt': createdAt.toIso8601String(),
    'launchCount': launchCount,
  };

  factory DeviceIdentity.fromJson(Map<String, dynamic> json) => DeviceIdentity(
    anonymousId: json['anonymousId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    launchCount: json['launchCount'] as int,
  );
}
