import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/notification_hive_model.dart';

abstract class NotificationRepository {
  Future<void> syncNotifications();

  Future<List<NotificationHiveModel>> getNotifications();

  Stream<List<NotificationHiveModel>> watchNotifications();

  Future<void> markAllRead();

  Future<void> deleteNotification(
    int notificationId,
  );

  Future<void> readNotification(
    int notificationId,
  );
}
