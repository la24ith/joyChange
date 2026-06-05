import 'package:hive/hive.dart';

import '../models/notification_hive_model.dart';
import 'notification_local_data_source.dart';

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final Box<NotificationHiveModel> box;

  NotificationLocalDataSourceImpl(
    this.box,
  );

  @override
  Future<void> saveNotifications(
    List<NotificationHiveModel> notifications,
  ) async {
    final map = {
      for (final item in notifications) item.id: item,
    };

    await box.putAll(map);
  }

  @override
  Future<List<NotificationHiveModel>> getNotifications() async {
    return box.values.toList();
  }

  @override
  Future<bool> exists(
    int id,
  ) async {
    return box.containsKey(id);
  }

  @override
  Future<NotificationHiveModel?> getById(
    int id,
  ) async {
    return box.get(id);
  }

  @override
  Future<void> updateNotification(
    NotificationHiveModel notification,
  ) async {
    await box.put(
      notification.id,
      notification,
    );
  }

  @override
  Future<void> deleteNotification(
    int id,
  ) async {
    await box.delete(id);
  }

  @override
  Future<void> clearExpiredNotifications() async {
    final now = DateTime.now();

    final expired = box.values.where(
      (e) => e.expiresAt != null && e.expiresAt!.isBefore(now),
    );

    for (final item in expired) {
      await box.delete(item.id);
    }
  }
}
