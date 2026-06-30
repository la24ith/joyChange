// core/services/notification_sync_service.dart
import 'package:flutter/material.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/datasource/notification_api_service.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/datasource/notification_local_data_source.dart';

class NotificationSyncService {
  final NotificationApiService api;
  final NotificationLocalDataSource local;

  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  static const Duration minSyncInterval = Duration(minutes: 5);

  // ملاحظة: لم يعد هناك scheduler هنا.
  // FCM هو المصدر الوحيد لعرض الإشعار على الشاشة.
  // هذا الـ service الآن مسؤول فقط عن مزامنة قائمة الإشعارات
  // (لعرضها داخل شاشة "الإشعارات" بالتطبيق) — لا عرض فوري إطلاقاً.
  NotificationSyncService(
    this.api,
    this.local,
  );

  Future<void> sync({bool force = false}) async {
    if (!force && _lastSyncTime != null) {
      final elapsed = DateTime.now().difference(_lastSyncTime!);
      if (elapsed < minSyncInterval) {
        debugPrint(
          'Skipping sync, last sync was ${elapsed.inSeconds} seconds ago',
        );
        return;
      }
    }

    if (_isSyncing) {
      debugPrint('Sync already in progress');
      return;
    }

    _isSyncing = true;
    _lastSyncTime = DateTime.now();

    debugPrint('Starting notification list sync...');

    try {
      final localNotifications = await local.getNotifications();

      List<dynamic> remoteNotifications;

      try {
        remoteNotifications = await api.getNotifications();
      } catch (e) {
        debugPrint('No internet or API unavailable. Using local cache.');
        debugPrint('Sync skipped: $e');
        return;
      }

      if (remoteNotifications.isEmpty && localNotifications.isNotEmpty) {
        debugPrint('Remote returned empty list while local cache exists.');
        debugPrint('Skipping delete sync to protect local data.');
        return;
      }

      final remoteIds = remoteNotifications.map((e) => e.id).toSet();
      final localIds = localNotifications.map((e) => e.id).toSet();

      //------------------------------------------------------
      // NEW + UPDATE — فقط تحديث القائمة المحلية، بدون أي عرض
      //------------------------------------------------------
      for (final remote in remoteNotifications) {
        try {
          final exists = await local.exists(remote.id);
          final hiveModel = remote.toHiveModel();

          if (!exists) {
            await local.saveNotifications([hiveModel]);
            debugPrint('Added new notification to list: ${remote.id}');
          } else {
            final old = await local.getById(remote.id);

            // حافظ على isRead المحلية — لا تكتب فوقها بقيمة السيرفر
            hiveModel.isRead = old?.isRead ?? hiveModel.isRead;
            hiveModel.readAt = old?.readAt ?? hiveModel.readAt;

            await local.updateNotification(hiveModel);
          }
        } catch (e, stack) {
          debugPrint('Failed to sync notification ${remote.id}');
          debugPrint(e.toString());
          debugPrint(stack.toString());
        }
      }

      //------------------------------------------------------
      // DELETED
      //------------------------------------------------------
      final deletedIds = localIds.difference(remoteIds);

      for (final id in deletedIds) {
        if (id == null) continue;
        try {
          debugPrint('Deleting removed notification: $id');
          await local.deleteNotification(id);
        } catch (e) {
          debugPrint('Failed deleting notification $id: $e');
        }
      }

      //------------------------------------------------------
      // EXPIRED
      //------------------------------------------------------
      final now = DateTime.now();
      final currentLocal = await local.getNotifications();

      for (final notification in currentLocal) {
        if (notification.id == null) continue;
        try {
          if (notification.expiresAt != null &&
              notification.expiresAt!.isBefore(now)) {
            debugPrint('Notification expired: ${notification.id}');
            await local.deleteNotification(notification.id!);
          }
        } catch (e) {
          debugPrint('Failed processing expired notification: $e');
        }
      }

      debugPrint('Notification list sync completed successfully');
    } catch (e, stack) {
      debugPrint('Unexpected sync error');
      debugPrint(e.toString());
      debugPrint(stack.toString());
    } finally {
      _isSyncing = false;
    }
  }
}
