// lib/core/constants/app_constants.dart

class AppConstants {
  // TODO: Change this to your actual API base URL
  static String baseUrl = 'https://lake-oaf-reappear.ngrok-free.dev';

  // App Information
  static const String appName = 'Patient Weight Tracker';
  static const String appVersion = '1.0.0';

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableSubscriptionPolling = true;
  static const int subscriptionPollingIntervalSeconds = 300;

  // Cache Configuration
  static const int cacheMaxAgeDays = 7;
  static const int mediaCacheMaxSizeMB = 500;

  String notificationsBox = 'notifications_box';
}
