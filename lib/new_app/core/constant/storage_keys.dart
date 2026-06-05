// lib/core/constants/storage_keys.dart

class StorageKeys {
  // Secure Storage Keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token'; // مستقبلاً لو دعم الـ API
  static const String deviceId = 'device_id';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String lastLoginTime = 'last_login_time';

  // Hive Box Names
  static const String postsBox = 'posts_box';
  static const String weightsBox = 'weights_box';
  static const String notificationsBox = 'notifications_box';
  static const String dailyAnswersBox = 'daily_answers_box';
  static const String syncQueueBox = 'sync_queue_box';

  // Shared Preferences Keys (if needed)
  static const String isFirstLaunch = 'is_first_launch';
  static const String lastSubscriptionCheck = 'last_subscription_check';

  // Cache Keys
  static const String cachedPosts = 'cached_posts';
  static const String cachedUser = 'cached_user';
  static const String lastSyncTime = 'last_sync_time';
  static const String isOfflineMode = 'is_offline_mode';
  static const String pendingSyncCount = 'pending_sync_count';

  // Shared Preferences Keys
}
