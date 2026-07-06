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

  // ✅ إصلاح: إشعار قادم من الـ API يُعتبر صالحاً للتخزين فقط إذا كان
  //    يحمل عنوان أو رسالة فعليين. هذا يمنع تسريب سجلات فاضية إلى Hive
  //    ومن ثم ظهورها في شاشة الإشعارات ككارد بدون محتوى.
  bool _hasValidContent(dynamic remote) {
    final title = (remote.title as String?)?.trim() ?? '';
    final message = (remote.message as String?)?.trim() ?? '';
    return title.isNotEmpty || message.isNotEmpty;
  }

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

      // ✅ إصلاح: فلترة أي عنصر وصل من الـ API بدون محتوى فعلي (title/message
      //    فاضيين) قبل أي معالجة أخرى — بدل تخزينه بصمت في Hive.
      final validRemoteNotifications = <dynamic>[];
      for (final remote in remoteNotifications) {
        if (_hasValidContent(remote)) {
          validRemoteNotifications.add(remote);
        } else {
          debugPrint(
            '⚠️ Skipped invalid notification from API (empty content): '
            'id=${remote.id}',
          );
        }
      }

      final remoteIds = validRemoteNotifications.map((e) => e.id).toSet();
      final localIds = localNotifications.map((e) => e.id).toSet();

      //------------------------------------------------------
      // NEW + UPDATE — فقط تحديث القائمة المحلية، بدون أي عرض
      //------------------------------------------------------
      for (final remote in validRemoteNotifications) {
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
      // ملاحظة: تُحسب هنا فقط بالنسبة للإشعارات الصالحة القادمة من
      // السيرفر (remoteIds بعد الفلترة)، حتى لا يُحذف محلياً أي إشعار
      // كان صالحاً سابقاً بسبب استبعاد عنصر فاسد من نفس القائمة.
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
