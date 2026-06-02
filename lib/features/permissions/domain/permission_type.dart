enum PermissionType {
  overlay,
  accessibility,
  screenCapture,
  notification;

  String get displayName {
    return switch (this) {
      PermissionType.overlay => 'Overlay',
      PermissionType.accessibility => 'Accessibility',
      PermissionType.screenCapture => 'Screen Capture',
      PermissionType.notification => 'Notification',
    };
  }
}
