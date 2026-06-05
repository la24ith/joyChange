import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/notification_hive_model.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationSchedulerService {
  final FlutterLocalNotificationsPlugin plugin;

  NotificationSchedulerService(this.plugin);

  Future<void> scheduleNotification(
    NotificationHiveModel notification,
  ) async {
    if (notification.isScheduled) {
      return;
    }

    final pending = await plugin.pendingNotificationRequests();

    final alreadyExists = pending.any(
      (e) => e.id == notification.id,
    );

    if (alreadyExists) {
      return;
    }

    final scheduleDate = notification.sendAt ?? notification.sentAt;

    if (scheduleDate == null) {
      return;
    }

    final now = DateTime.now();

    if (scheduleDate.isBefore(now)) {
      await showNow(notification);
      return;
    }

    await plugin.zonedSchedule(
      notification.id,
      notification.title,
      notification.message,
      tz.TZDateTime.from(
        scheduleDate,
        tz.local,
      ),
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: notification.id.toString(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showNow(
    NotificationHiveModel notification,
  ) async {
    await plugin.show(
      notification.id,
      notification.title,
      notification.message,
      _details(),
      payload: notification.id.toString(),
    );
  }

  Future<void> cancel(
    int notificationId,
  ) async {
    await plugin.cancel(notificationId);
  }

  Future<void> cancelAll() async {
    await plugin.cancelAll();
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'notifications',
        'Notifications',
        icon: 'ic_notification',
        sound: RawResourceAndroidNotificationSound(
          'notification_sound',
        ),
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }
}
