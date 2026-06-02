enum PermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  unknown;

  bool get isGranted => this == PermissionStatus.granted;

  bool get isDenied =>
      this == PermissionStatus.denied ||
      this == PermissionStatus.permanentlyDenied;
}

extension PermissionStatusX on PermissionStatus {
  bool get canRequestAgain =>
      this == PermissionStatus.denied ||
      this == PermissionStatus.unknown;
}
