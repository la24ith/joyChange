import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationInitializer {
  static Future<FlutterLocalNotificationsPlugin> init() async {
    final plugin = FlutterLocalNotificationsPlugin();

    const android = AndroidInitializationSettings('ic_notification');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(android: android, iOS: ios);

    await plugin.initialize(settings);

    // ✅ أنشئ الـ channel صراحةً بـ importance عالية
    // هذا يضمن ظهور الإشعار على الشاشة (heads-up notification)
    // ملاحظة: استخدم id جديد 'notifications_v2' لأن Android يتجاهل
    // تعديل channel موجود مسبقاً — الـ id الجديد يجبره على إنشاء channel جديد
    const androidChannel = AndroidNotificationChannel(
      'notifications_v2', // ← id جديد
      'App Notifications',
      description: 'إشعارات التطبيق',
      importance: Importance.max, // ← هذا ما يجعله يظهر على الشاشة
      playSound: true,
      enableVibration: true,
    );

    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    return plugin;
  }
}
