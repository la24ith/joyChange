// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:joy_of_change_v3/new_app/core/constant/api_endpoints.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_constants.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_theme.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/subscription_expired_screen.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'subscription_interceptor.dart';

class DioClient {
  static DioClient? _instance;
  static DioClient get instance => _instance ??= DioClient._();

  late final Dio _dio;

  DioClient._() {
    _dio = _createDio();
    _setupInterceptors();
  }
  Dio _createDio() {
    String baseUrl = AppConstants.baseUrl;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'Mozilla/5.0',
        },
        validateStatus: (status) => true,
      ),
    );
  }

  // lib/core/network/dio_client.dart
  void _setupInterceptors() {
    _dio.interceptors.clear();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final data = error.response?.data;

          if (error.response?.statusCode == 403 &&
              data != null &&
              data['code'] == "SUBSCRIPTION_INACTIVE") {
            AppState.subscriptionExpired = true;

            // ✅ الحل: استخدم Future.microtask لضمان التنفيذ بعد اكتمال البناء
            Future.microtask(() {
              Get.offAll(() => const SubscriptionExpiredScreen());
            });

            return handler.next(error);
          }

          return handler.next(error);
        },
      ),
    );
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(ErrorInterceptor());
  }

  // Getters for HTTP methods
  Dio get dio => _dio;

  // For GET requests
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (AppState.subscriptionExpired) {
      throw Exception("Subscription expired - request blocked");
    }
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // For POST requests
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (AppState.subscriptionExpired) {
      throw Exception("Subscription expired - request blocked");
    }
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // For PUT requests
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // For DELETE requests
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // For PATCH requests
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // For file uploads
  Future<Response> upload(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (data != null) ...data,
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
