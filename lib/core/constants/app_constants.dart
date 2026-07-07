class AppConstants {
  static const String privacyPolicyUrl =
      'https://github.com/shegz/celebray/blob/main/docs/privacy_policy.md';
  static const String termsUrl =
      'https://github.com/shegz/celebray/blob/main/docs/terms_of_service.md';

  static const String notificationChannelId = 'celebray_reminders';
  static const String notificationChannelName = 'Celebration Reminders';
  static const String notificationChannelDescription =
      'Alerts on celebration days so you can share your message';

  static const String firebaseProjectId = 'celebray-fa7ae';
  static const String aiFunctionsRegion = 'us-central1';
  static const int aiDailyLimit = 20;

  static const String aiFunctionsBaseUrl = String.fromEnvironment(
    'AI_FUNCTIONS_BASE_URL',
    defaultValue:
        'https://us-central1-celebray-fa7ae.cloudfunctions.net',
  );
}
