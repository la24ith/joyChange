import 'package:hive/hive.dart';

import '../models/notification_hive_model.dart';

abstract class NotificationLocalDataSource {
  Future<void> saveNotifications(
    List<NotificationHiveModel> notifications,
  );

  Future<List<NotificationHiveModel>> getNotifications();

  Future<void> updateNotification(
    NotificationHiveModel notification,
  );

  Future<void> deleteNotification(
    int id,
  );

  Future<void> clearExpiredNotifications();

  Future<bool> exists(
    int id,
  );

  Future<NotificationHiveModel?> getById(int id);
}
