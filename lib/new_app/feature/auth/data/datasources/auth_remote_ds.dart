// lib/features/auth/data/datasources/auth_remote_ds.dart

import 'package:dio/dio.dart';
import 'package:joy_of_change_v3/new_app/core/constant/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient.instance;

  Future<bool> checkSubscriptionStatus(String email) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.subscriptionStatus);

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data['active'] != null) {
          return data['active'] == true;
        }
      }

      return response.statusCode == 403 ? true : false;
    } catch (e) {
      return true;
    }
  }

  Future<LoginResponseModel> login({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 LOGIN REQUEST');
      print('📍 URL: ${ApiEndpoints.login}');
      print('📦 Data: {email: $email, device_id: $deviceId}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _dioClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
          'device_id': deviceId,
        },
      );

      print('📥 LOGIN RESPONSE');
      print('📊 Status: ${response.statusCode}');
      print('📦 Data: ${response.data}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ DIO ERROR: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      if (e.error is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Register new user
  // lib/features/auth/data/datasources/auth_remote_ds.dart

  Future<({String message, int userId, String email})> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
  }) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 REGISTER REQUEST');
      print('📍 URL: ${ApiEndpoints.register}');
      print('📧 Email: $email');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _dioClient.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
        },
      );

      print('📥 REGISTER RESPONSE');
      print('📊 Status: ${response.statusCode}');
      print('📦 Data: ${response.data}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // ✅ قبول 201 و 200
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        final message =
            response.data['message'] as String? ?? 'Registration successful';
        final userId = response.data['data']['user']['id'] as int;
        final userEmail = response.data['data']['user']['email'] as String;

        print('✅ Registration parsed successfully');
        print('📧 User email: $userEmail');
        print('🆔 User ID: $userId');
        print('💬 Message: $message');

        return (message: message, userId: userId, email: userEmail);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ Dio error: ${e.message}');
      if (e.error is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Check subscription status (for polling)

  /// Logout user
  Future<void> logout() async {
    try {
      await _dioClient.post(ApiEndpoints.logout);
    } catch (e) {
      print('⚠️ Logout API error: $e');
    }
  }
}
