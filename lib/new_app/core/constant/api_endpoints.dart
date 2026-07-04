// lib/core/constants/api_endpoints.dart

import 'app_constants.dart';

class ApiEndpoints {
  // Base URL from constants
  static String get baseUrl => AppConstants.baseUrl;

  // Auth Endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String user = '/api/auth/user';
  static const String profile = '/api/auth/profile';
  static const String changePassword = '/api/auth/change-password';
  static const String subscriptionStatus = '/api/auth/subscription-status';
  static const String authState = '/api/auth/state';
  // Full URL getters
  static String get fullRegister => '$baseUrl$register';
  static String get fullLogin => '$baseUrl$login';
  static String get fullLogout => '$baseUrl$logout';
  static String get fullUser => '$baseUrl$user';
  static String get fullProfile => '$baseUrl$profile';
  static String get fullChangePassword => '$baseUrl$changePassword';
  static String get fullSubscriptionStatus => '$baseUrl$subscriptionStatus';

  static const String posts = '/api/posts';
  static const String featuredPosts = '/api/posts/featured';
  static const String categories = '/api/categories';
  static const String media = '/api/posts';

// Weight Tracking Endpoints
  static const String weights = '/api/weights';
  static const String weightStats = '/api/weights/stats';
  static const String weightChart = '/api/weights/chart-data';
  static const String weightIdealStatus = '/api/weights/ideal-status';
  static const String addWeight = '/api/weights';

  static const String dailyCommitmentToday = '/api/daily-commitment/today';
  static const String dailyCommitmentAnswer = '/api/daily-commitment/answer';
  static const String dailyCommitmentHistory = '/api/daily-commitment/history';
  static const String dailyCommitmentStats = '/api/daily-commitment/stats';

  static const String activeAds = '/api/ads/active';
  static const String screenshot_permission = '/api/user/screenshot-permission';

  static String getFullMediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;

    final cleanBase = baseUrl.replaceAll(RegExp(r'/api/?$'), '');

    // تنظيف المسار
    String cleanPath = path;
    cleanPath = cleanPath.replaceAll(
        RegExp(r'^(/storage/|storage/|/public/|public/)'), '');

    // بناء الرابط النهائي
    return '$cleanBase/storage/$cleanPath';
  }

  // استبدل mediaUrl الحالية بهذه النسخة الموحّدة
  static String mediaUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    // رابط نسبي قادم من الباك-إند بدون http
    if (!url.startsWith('http')) {
      return getFullMediaUrl(url);
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return url;

    final isGoogleDrive = uri.host.contains('drive.google.com') ||
        uri.host.contains('docs.google.com');

    if (isGoogleDrive) {
      final patterns = [
        RegExp(r'/d/([a-zA-Z0-9_-]+)'),
        RegExp(r'id=([a-zA-Z0-9_-]+)'),
      ];
      for (final pattern in patterns) {
        final match = pattern.firstMatch(url);
        if (match != null) {
          final fileId = match.group(1)!;
          return 'https://drive.google.com/uc?export=download&id=$fileId&confirm=t';
        }
      }
      return url;
    }

    // أي رابط آخر: فرض https دائمًا (بدل تكرار replaceFirst في كل ويدجت)
    return url.replaceFirst('http://', 'https://');
  }
}
