import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationInitializer {
  static Future<FlutterLocalNotificationsPlugin> init() async {
    final plugin = FlutterLocalNotificationsPlugin();

    const android = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await plugin.initialize(
      settings,
    );

    return plugin;
  }
}
