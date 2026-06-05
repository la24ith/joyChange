// lib/features/drawer/data/datasources/subscription_remote_ds.dart

import 'package:dio/dio.dart';
import 'package:joy_of_change_v3/new_app/core/constant/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_subscription_model.dart';

class SubscriptionRemoteDataSource {
  final DioClient _dioClient;

  SubscriptionRemoteDataSource({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient.instance;

  Future<UserSubscriptionModel> getUserSubscription() async {
    try {
      // ✅ جلب بيانات المستخدم أولاً
      final userResponse = await _dioClient.get(ApiEndpoints.user);

      if (userResponse.statusCode != 200 ||
          userResponse.data['success'] != true) {
        throw ServerException(
          message: 'Failed to load user data',
          statusCode: userResponse.statusCode,
        );
      }

      // ✅ جلب حالة الاشتراك
      final subscriptionResponse =
          await _dioClient.get(ApiEndpoints.subscriptionStatus);

      if (subscriptionResponse.statusCode != 200 ||
          subscriptionResponse.data['success'] != true) {
        throw ServerException(
          message: 'Failed to load subscription status',
          statusCode: subscriptionResponse.statusCode,
        );
      }

      // ✅ دمج البيانات
      final userData =
          userResponse.data['data']['user'] as Map<String, dynamic>;
      final subscriptionData =
          subscriptionResponse.data['data'] as Map<String, dynamic>;

      final combinedData = {
        ...userData,
        'data': subscriptionData,
      };

      return UserSubscriptionModel.fromJson(combinedData);
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Stream<UserSubscriptionModel> watchUserSubscription() {
    // التحقق الدوري كل 30 ثانية للتحديثات
    return Stream.periodic(const Duration(seconds: 30), (_) async {
      return await getUserSubscription();
    }).asyncMap((event) => event);
  }

  Future<void> logout() async {
    try {
      await _dioClient.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw ServerException(
        message: 'Logout failed: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
