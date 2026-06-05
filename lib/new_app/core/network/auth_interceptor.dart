// lib/core/network/auth_interceptor.dart

import 'package:dio/dio.dart';
import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';
import '../di/service_locator.dart';
import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage = getIt<SecureStorageService>();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final shouldSkipAuth = options.path.contains('/auth/login') ||
        options.path.contains('/auth/register');

    options.headers['ngrok-skip-browser-warning'] = 'true';
    options.headers['User-Agent'] = 'Mozilla/5.0';

    if (!shouldSkipAuth) {
      final token = await _secureStorage.read(key: StorageKeys.accessToken);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      final deviceId = await _secureStorage.read(key: StorageKeys.deviceId);
      if (deviceId != null && deviceId.isNotEmpty) {
        options.headers['X-Device-Id'] = deviceId;
      }
    }

    handler.next(options);
  }
}
