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

  static const Duration minSyncInterval = Duration(minutes: 5);

  NotificationSyncService(
    this.api,
    this.local,
    this.scheduler,
  );

  Future<void> sync({bool force = false}) async {
    if (!force && _lastSyncTime != null) {
      final elapsed = DateTime.now().difference(_lastSyncTime!);
      if (elapsed < minSyncInterval) {
        debugPrint(
          '⏭️ Skipping sync, last sync was ${elapsed.inSeconds} seconds ago',
        );
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
      final localNotifications = await local.getNotifications();

      List<dynamic> remoteNotifications;

      try {
        // ✅ الآن getNotifications() يرمي exception عند فشل الشبكة
        //    فيدخل الـ catch الصحيح بدلاً من إرجاع [] خاطئ
        remoteNotifications = await api.getNotifications();
      } catch (e) {
        debugPrint(
          '📴 No internet or API unavailable. Using local notifications only.',
        );
        debugPrint('❌ Sync skipped: $e');
        return;
      }

      if (remoteNotifications.isEmpty && localNotifications.isNotEmpty) {
        debugPrint('⚠️ Remote returned empty list while local cache exists.');
        debugPrint('⚠️ Skipping delete sync to protect local data.');
        return;
      }

      final remoteIds = remoteNotifications.map((e) => e.id).toSet();
      final localIds = localNotifications.map((e) => e.id).toSet();

      //------------------------------------------------------
      // NEW + UPDATE
      //------------------------------------------------------
      for (final remote in remoteNotifications) {
        try {
          final exists = await local.exists(remote.id);
          final hiveModel = remote.toHiveModel();

          if (!exists) {
            await local.saveNotifications([hiveModel]);
            await scheduler.scheduleNotification(hiveModel);
            hiveModel.isScheduled = true;
            await local.updateNotification(hiveModel);
            debugPrint('✅ Added new notification: ${remote.id}');
          } else {
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
        } catch (e, stack) {
          debugPrint('❌ Failed to sync notification ${remote.id}');
          debugPrint(e.toString());
          debugPrint(stack.toString());
        }
      }

      //------------------------------------------------------
      // DELETED
      //------------------------------------------------------
      final deletedIds = localIds.difference(remoteIds);

      for (final id in deletedIds) {
        // ✅ إصلاح: تخطي الـ null بدل استخدام ?? 0 الذي يلغي id الصفر بالخطأ
        if (id == null) continue;

        try {
          debugPrint('🗑️ Deleting removed notification: $id');
          await scheduler.cancel(id);
          await local.deleteNotification(id);
        } catch (e) {
          debugPrint('❌ Failed deleting notification $id: $e');
        }
      }

      //------------------------------------------------------
      // EXPIRED
      //------------------------------------------------------
      final now = DateTime.now();
      final currentLocal = await local.getNotifications();

      for (final notification in currentLocal) {
        // ✅ إصلاح: تخطي الـ null بدل استخدام ?? 0
        if (notification.id == null) continue;

        try {
          if (notification.expiresAt != null &&
              notification.expiresAt!.isBefore(now)) {
            debugPrint('⏰ Notification expired: ${notification.id}');
            await scheduler.cancel(notification.id!);
            await local.deleteNotification(notification.id!);
          }
        } catch (e) {
          debugPrint('❌ Failed processing expired notification: $e');
        }
      }

      debugPrint('✅ Sync completed successfully');
    } catch (e, stack) {
      debugPrint('❌ Unexpected sync error');
      debugPrint(e.toString());
      debugPrint(stack.toString());
    } finally {
      _isSyncing = false;
    }
  }
}
