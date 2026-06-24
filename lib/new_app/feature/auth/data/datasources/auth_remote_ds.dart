// lib/features/auth/data/datasources/auth_remote_ds.dart

import 'package:dio/dio.dart';
import 'package:joy_of_change_v3/new_app/core/constant/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';
import '../models/auth_state_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient.instance;

  Future<bool> checkSubscriptionStatus(String email) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.subscriptionStatus,
        // ✅ إضافة timeout على مستوى الـ request
        options: Options(
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        final data = response.data['data'];
        return data != null && data['active'] == true;
      }

      return false;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      print('🔍 DS: DioException status=$statusCode type=${e.type}');
      print('🔍 DS: Response data=$data');

      // ✅ إصلاح: أي 403 = اشتراك منتهٍ، بغض النظر عن الـ code
      if (statusCode == 403) {
        final message =
            data?['message'] ?? data?['error'] ?? 'Subscription expired';
        print('🚫 DS: 403 → SubscriptionExpiredException: $message');
        throw SubscriptionExpiredException(message: message);
      }

      // ✅ إصلاح: timeout وضعف النت → استثناء مميّز
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        print('⏱️ DS: Network/timeout → NetworkException');
        throw NetworkException(message: 'Connection timeout or weak network');
      }

      print('⚠️ DS: Other Dio error → rethrow');
      rethrow; // ✅ ارمِ الـ DioException للـ Repository يتعامل معها
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

  /// Check auth state (subscription + device approval status)
  /// This endpoint doesn't require password, only email and device_id
  Future<AuthStateModel> checkAuthState({
    required String email,
    required String deviceId,
    String? password,
  }) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 CHECK AUTH STATE REQUEST');
      print('📍 URL: ${ApiEndpoints.authState}');
      print('📧 Email: $email');
      print('📱 Device ID: $deviceId');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final Map<String, dynamic> requestData = {
        'email': email,
        'device_id': deviceId,
      };

      // Add password if provided (optional)
      if (password != null && password.isNotEmpty) {
        requestData['password'] = password;
      }

      final response = await _dioClient.post(
        ApiEndpoints.authState,
        data: requestData,
      );

      print('📥 CHECK AUTH STATE RESPONSE');
      print('📊 Status: ${response.statusCode}');
      print('📦 Data: ${response.data}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        return AuthStateModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to check auth state',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ DIO ERROR: ${e.message}');
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

  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    double? currentWeight,
    double? targetWeight,
    double? height,
    String? patientSegment,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (currentWeight != null) data['current_weight'] = currentWeight;
      if (targetWeight != null) data['target_weight'] = targetWeight;
      if (height != null) data['height'] = height;
      if (patientSegment != null) data['patient_segment'] = patientSegment;

      final response = await _dioClient.put(
        ApiEndpoints.profile,
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final userData = response.data['data']['user'] as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update profile',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
