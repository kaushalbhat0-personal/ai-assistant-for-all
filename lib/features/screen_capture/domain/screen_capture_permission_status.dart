enum ScreenCapturePermissionStatus {
  granted,
  denied,
  unknown;

  bool get isGranted => this == ScreenCapturePermissionStatus.granted;
}
