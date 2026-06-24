// feature/notifications/data/datasource/notification_api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:joy_of_change_v3/new_app/core/network/dio_client.dart';
import '../models/notification_response_model.dart';

class NotificationApiService {
  final Dio dio;

  // ✅ إصلاح: حذف dioClient غير المستخدم من الـ constructor
  NotificationApiService(
    this.dio,
  );

  // ✅ إصلاح: رمي exception بدل ابتلاعه حتى يتمكن NotificationSyncService
  //    من التمييز بين "لا إنترنت" و"API أرجع قائمة فارغة فعلاً"
  Future<List<NotificationResponseModel>> getNotifications() async {
    final response =
        await dio.get('/api/notifications'); // يرمي DioException عند فشل الشبكة

    if (response.data['data'] == null) {
      debugPrint('⚠️ No data field in response');
      return [];
    }

    final data = response.data['data'] as List;
    return data
        .map((e) =>
            NotificationResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAllRead() async {
    try {
      await dio.put('/api/notifications/read-all');
      debugPrint('✅ Marked all notifications as read');
    } on DioException catch (e) {
      debugPrint('❌ Mark all read error: ${e.message}');
      rethrow;
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await dio.delete('/api/notifications/$id');
      debugPrint('✅ Deleted notification: $id');
    } on DioException catch (e) {
      debugPrint('❌ Delete error: ${e.message}');
      rethrow;
    }
  }
}
