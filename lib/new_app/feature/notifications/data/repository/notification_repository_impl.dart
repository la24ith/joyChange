import 'package:hive/hive.dart';
import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/domain/entities/repository/notification_repository.dart';

import '../datasource/notification_api_service.dart';
import '../datasource/notification_local_data_source.dart';

import '../models/notification_hive_model.dart';

import '../../../../core/services/notification_scheduler_service.dart';
import '../../../../core/services/notification_sync_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationApiService api;

  final NotificationLocalDataSource local;

  final NotificationSyncService syncService;

  final NotificationSchedulerService scheduler;

  NotificationRepositoryImpl({
    required this.api,
    required this.local,
    required this.syncService,
    required this.scheduler,
  });

  @override
  Future<void> syncNotifications() async {
    await syncService.sync();
  }

  @override
  Future<List<NotificationHiveModel>> getNotifications() {
    return local.getNotifications();
  }

  @override
  Stream<List<NotificationHiveModel>> watchNotifications() {
    final box = Hive.box<NotificationHiveModel>(StorageKeys.notificationsBox);

    // ✅ أضف StreamController لإرسال القيم الحالية فور الاشتراك
    return Stream<List<NotificationHiveModel>>.multi((controller) {
      // أرسل البيانات الحالية فوراً
      final current = box.values.toList()
        ..sort((a, b) =>
            (b.sentAt ?? DateTime(1970)).compareTo(a.sentAt ?? DateTime(1970)));
      controller.add(current);

      // ثم استمع للتغييرات
      final sub = box.watch().listen((_) {
        final updated = box.values.toList()
          ..sort((a, b) => (b.sentAt ?? DateTime(1970))
              .compareTo(a.sentAt ?? DateTime(1970)));
        controller.add(updated);
      });

      controller.onCancel = () => sub.cancel();
    });
  }

  @override
  Future<void> markAllRead() async {
    await api.markAllRead();

    final notifications = await local.getNotifications();

    for (final notification in notifications) {
      notification.isRead = true;

      notification.readAt = DateTime.now();

      await local.updateNotification(
        notification,
      );
    }
  }

  @override
  Future<void> deleteNotification(
    int notificationId,
  ) async {
    await api.deleteNotification(
      notificationId,
    );

    await scheduler.cancel(
      notificationId,
    );

    await local.deleteNotification(
      notificationId,
    );
  }
}
