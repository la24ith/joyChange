// core/services/notification_scheduler_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/notification_hive_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationSchedulerService {
  final FlutterLocalNotificationsPlugin plugin;

  NotificationSchedulerService(this.plugin);

  Future<void> scheduleNotification(NotificationHiveModel notification) async {
    // ✅ إصلاح: استخدام == true بدل ! لتجنب null crash
    if (notification.isScheduled == true) {
      debugPrint('⏭️ Notification ${notification.id} already scheduled');
      return;
    }

    try {
      final pending = await plugin.pendingNotificationRequests();
      final alreadyExists = pending.any((e) => e.id == notification.id);

      if (alreadyExists) {
        debugPrint(
            '⏭️ Notification ${notification.id} already exists in pending');
        return;
      }

      final scheduleDate = notification.sendAt ?? notification.sentAt;
      if (scheduleDate == null) {
        debugPrint('⚠️ Notification ${notification.id} has no schedule date');
        return;
      }

      final now = DateTime.now();

      final maxFuture = now.add(const Duration(days: 365));
      if (scheduleDate.isAfter(maxFuture)) {
        debugPrint('⚠️ Notification ${notification.id} is too far in future');
        return;
      }

      if (scheduleDate.isBefore(now)) {
        debugPrint(
            '📢 Showing notification ${notification.id} immediately (past date)');
        await showNow(notification);
        return;
      }

      await plugin.zonedSchedule(
        notification.id!,
        notification.title,
        notification.message,
        tz.TZDateTime.from(scheduleDate, tz.local),
        _details(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: notification.id.toString(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint(
          '✅ Scheduled notification ${notification.id} for $scheduleDate');
    } catch (e) {
      debugPrint('❌ Failed to schedule notification ${notification.id}: $e');
      rethrow;
    }
  }

  Future<void> showNow(NotificationHiveModel notification) async {
    try {
      await plugin.show(
        notification.id!,
        notification.title,
        notification.message,
        _details(),
        payload: notification.id.toString(),
      );
      debugPrint('✅ Showed notification ${notification.id} immediately');
    } catch (e) {
      debugPrint('❌ Failed to show notification ${notification.id}: $e');
    }
  }

  Future<void> cancel(int notificationId) async {
    try {
      await plugin.cancel(notificationId);
      debugPrint('❌ Cancelled notification: $notificationId');
    } catch (e) {
      debugPrint('❌ Failed to cancel notification $notificationId: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await plugin.cancelAll();
      debugPrint('❌ Cancelled all notifications');
    } catch (e) {
      debugPrint('❌ Failed to cancel all notifications: $e');
    }
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'notifications',
        'Notifications',
        channelDescription: 'إشعارات التطبيق',
        icon: 'ic_notification',
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}
