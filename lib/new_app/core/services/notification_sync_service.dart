// core/services/notification_sync_service.dart
import 'package:flutter/material.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/datasource/notification_api_service.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/datasource/notification_local_data_source.dart';
import 'notification_scheduler_service.dart';

class NotificationSyncService {
  final NotificationApiService api;
  final NotificationLocalDataSource local;
  final NotificationSchedulerService scheduler;

  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  // ✅ الحد الأدنى للفاصل الزمني بين المزامنات (5 دقائق)
  static const Duration minSyncInterval = Duration(minutes: 5);

  NotificationSyncService(
    this.api,
    this.local,
    this.scheduler,
  );

  Future<void> sync({bool force = false}) async {
    // ✅ منع المزامنة المتكررة
    if (!force && _lastSyncTime != null) {
      final elapsed = DateTime.now().difference(_lastSyncTime!);
      if (elapsed < minSyncInterval) {
        debugPrint(
            '⏭️ Skipping sync, last sync was ${elapsed.inSeconds} seconds ago');
        return;
      }
    }

    if (_isSyncing) {
      debugPrint('⏭️ Sync already in progress');
      return;
    }

    _isSyncing = true;
    _lastSyncTime = DateTime.now();
    debugPrint('🔄 Starting notification sync...');

    try {
      final remoteNotifications = await api.getNotifications();
      final localNotifications = await local.getNotifications();

      final remoteIds = remoteNotifications.map((e) => e.id).toSet();
      final localIds = localNotifications.map((e) => e.id).toSet();

      //----------------------------------
      // NEW + UPDATE
      //----------------------------------
      for (final remote in remoteNotifications) {
        try {
          final exists = await local.exists(remote.id);
          final hiveModel = remote.toHiveModel();

          if (!exists) {
            // إضافة جديدة
            await local.saveNotifications([hiveModel]);
            await scheduler.scheduleNotification(hiveModel);

            // ✅ تحديث isScheduled بعد الجدولة الناجحة
            hiveModel.isScheduled = true;
            await local.updateNotification(hiveModel);
            debugPrint('✅ Added new notification: ${remote.id}');
          } else {
            // تحديث موجود
            final old = await local.getById(remote.id);
            final changed = old?.title != hiveModel.title ||
                old?.message != hiveModel.message ||
                old?.sendAt != hiveModel.sendAt ||
                old?.expiresAt != hiveModel.expiresAt;

            if (changed) {
              debugPrint('🔄 Updating notification: ${remote.id}');
              await scheduler.cancel(hiveModel.id ?? 0);
              hiveModel.isScheduled = false;
              await scheduler.scheduleNotification(hiveModel);
              hiveModel.isScheduled = true;
            }
            await local.updateNotification(hiveModel);
          }
        } catch (e) {
          debugPrint('❌ Failed to sync notification ${remote.id}: $e');
        }
      }

      //----------------------------------
      // DELETED
      //----------------------------------
      final deletedIds = localIds.difference(remoteIds);
      for (final id in deletedIds) {
        debugPrint('🗑️ Deleting notification: $id');
        await scheduler.cancel(id ?? 0);
        await local.deleteNotification(id ?? 0);
      }

      //----------------------------------
      // EXPIRED
      //----------------------------------
      final now = DateTime.now();
      final currentLocal = await local.getNotifications();

      for (final notification in currentLocal) {
        if (notification.expiresAt != null &&
            notification.expiresAt!.isBefore(now)) {
          debugPrint('⏰ Notification expired: ${notification.id}');
          await scheduler.cancel(notification.id ?? 0);
          await local.deleteNotification(notification.id ?? 0);
        }
      }

      debugPrint('✅ Sync completed successfully');
    } catch (e) {
      debugPrint('❌ Sync error: $e');
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }
}
