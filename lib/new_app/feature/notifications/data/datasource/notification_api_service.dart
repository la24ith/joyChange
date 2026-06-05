import 'package:dio/dio.dart';
import 'package:joy_of_change_v3/new_app/core/network/dio_client.dart';

import '../models/notification_response_model.dart';

class NotificationApiService {
  final Dio dio;

  NotificationApiService(this.dio, {required DioClient dioClient});

  Future<List<NotificationResponseModel>> getNotifications() async {
    final response = await dio.get(
      '/api/notifications',
    );

    final data = response.data['data'] as List;

    return data
        .map(
          (e) => NotificationResponseModel.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> markAllRead() async {
    await dio.put('/api/notifications/read-all');
  }

  Future<void> deleteNotification(int id) async {
    await dio.delete('/api/notifications/$id');
  }
}
