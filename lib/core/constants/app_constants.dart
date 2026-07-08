class AppConstants {
  static const String siteBaseUrl = 'https://celebray.web.app';

  static const String privacyPolicyUrl = '$siteBaseUrl/privacy';
  static const String termsUrl = '$siteBaseUrl/terms';
  static const String supportUrl = '$siteBaseUrl/support';

  static const String notificationChannelId = 'celebray_reminders';
  static const String notificationChannelName = 'Celebration Reminders';
  static const String notificationChannelDescription =
      'Midnight alerts on celebration days with quick access to messages and sharing';

  static const String firebaseProjectId = 'celebray-fa7ae';
  static const String aiFunctionsRegion = 'us-central1';
  static const int aiAnonymousDailyLimit = 10;
  static const int aiDailyLimit = 20;

  static String guestAiNotice() =>
      'Guest AI: $aiAnonymousDailyLimit messages/day. Sign in for $aiDailyLimit/day.';

  static const String aiFunctionsBaseUrl = String.fromEnvironment(
    'AI_FUNCTIONS_BASE_URL',
    defaultValue:
        'https://us-central1-celebray-fa7ae.cloudfunctions.net',
  );
}
