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

  // Full URL getters
  static String get fullRegister => '$baseUrl$register';
  static String get fullLogin => '$baseUrl$login';
  static String get fullLogout => '$baseUrl$logout';
  static String get fullUser => '$baseUrl$user';
  static String get fullProfile => '$baseUrl$profile';
  static String get fullChangePassword => '$baseUrl$changePassword';
  static String get fullSubscriptionStatus => '$baseUrl$subscriptionStatus';
}
