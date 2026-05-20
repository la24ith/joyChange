// lib/core/network/auth_interceptor.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';
import '../di/service_locator.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage = getIt<FlutterSecureStorage>();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Don't add token for login and register endpoints
    final shouldSkipAuth = options.path.contains('/auth/login') ||
        options.path.contains('/auth/register');

    if (!shouldSkipAuth) {
      final token = await _secureStorage.read(key: StorageKeys.accessToken);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Don't handle token refresh here, let ErrorInterceptor handle it
    // Just pass through
    handler.next(err);
  }
}
