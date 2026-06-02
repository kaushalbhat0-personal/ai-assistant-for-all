enum ScreenIntent {
  error,
  login,
  signup,
  payment,
  form,
  settings,
  socialMedia,
  unknown;

  String get displayName {
    return switch (this) {
      ScreenIntent.error => 'Error',
      ScreenIntent.login => 'Login',
      ScreenIntent.signup => 'Sign Up',
      ScreenIntent.payment => 'Payment',
      ScreenIntent.form => 'Form',
      ScreenIntent.settings => 'Settings',
      ScreenIntent.socialMedia => 'Social Media',
      ScreenIntent.unknown => 'Unknown',
    };
  }

  String get description {
    return switch (this) {
      ScreenIntent.error => 'Error or crash screen with error details',
      ScreenIntent.login => 'Login screen with credentials fields',
      ScreenIntent.signup => 'Sign-up or registration screen',
      ScreenIntent.payment => 'Payment or checkout screen',
      ScreenIntent.form => 'Data entry form with input fields',
      ScreenIntent.settings => 'Settings or preferences screen',
      ScreenIntent.socialMedia => 'Social media feed or profile screen',
      ScreenIntent.unknown => 'Unrecognized screen type',
    };
  }
}
