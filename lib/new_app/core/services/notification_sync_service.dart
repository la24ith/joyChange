import 'package:joy_of_change_v3/new_app/feature/notifications/data/datasource/notification_api_service.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/datasource/notification_local_data_source.dart';

import 'notification_scheduler_service.dart';

class NotificationSyncService {
  final NotificationApiService api;

  final NotificationLocalDataSource local;

  final NotificationSchedulerService scheduler;

  NotificationSyncService(
    this.api,
    this.local,
    this.scheduler,
  );

  bool _isSyncing = false;

  Future<void> sync() async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      final remoteNotifications = await api.getNotifications();

      final localNotifications = await local.getNotifications();

      final remoteIds = remoteNotifications.map((e) => e.id).toSet();

      final localIds = localNotifications.map((e) => e.id).toSet();

      //----------------------------------
      // NEW + UPDATE
      //----------------------------------

      for (final remote in remoteNotifications) {
        final exists = await local.exists(remote.id);

        final hiveModel = remote.toHiveModel();

        if (!exists) {
          await local.saveNotifications(
            [hiveModel],
          );

          await scheduler.scheduleNotification(
            hiveModel,
          );

          hiveModel.isScheduled = true;

          await local.updateNotification(
            hiveModel,
          );
        } else {
          final old = await local.getById(
            remote.id,
          );

          final changed = old?.title != hiveModel.title ||
              old?.message != hiveModel.message ||
              old?.sendAt != hiveModel.sendAt ||
              old?.expiresAt != hiveModel.expiresAt;

          if (changed) {
            await scheduler.cancel(
              hiveModel.id,
            );

            hiveModel.isScheduled = false;

            await scheduler.scheduleNotification(
              hiveModel,
            );

            hiveModel.isScheduled = true;
          }

          await local.updateNotification(
            hiveModel,
          );
        }
      }

      //----------------------------------
      // DELETED
      //----------------------------------

      final deletedIds = localIds.difference(
        remoteIds,
      );

      for (final id in deletedIds) {
        await scheduler.cancel(id);

        await local.deleteNotification(
          id,
        );
      }

      //----------------------------------
      // EXPIRED
      //----------------------------------

      final now = DateTime.now();

      final currentLocal = await local.getNotifications();

      for (final notification in currentLocal) {
        if (notification.expiresAt != null &&
            notification.expiresAt!.isBefore(now)) {
          await scheduler.cancel(
            notification.id,
          );

          await local.deleteNotification(
            notification.id,
          );
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}
