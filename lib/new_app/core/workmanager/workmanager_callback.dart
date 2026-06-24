// core/workmanager/workmanager_callback.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';
import 'package:joy_of_change_v3/new_app/core/services/notification_scheduler_service.dart';
import 'package:joy_of_change_v3/new_app/core/services/notification_sync_service.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/datasource/notification_api_service.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/datasource/notification_local_data_source_impl.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/notification_hive_model.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/NotificationHiveModelAdapter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('🔧 WorkManager task started: $task');
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);

      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(NotificationHiveModelAdapter());
      }

      if (!Hive.isBoxOpen(StorageKeys.notificationsBox)) {
        await Hive.openBox<NotificationHiveModel>(StorageKeys.notificationsBox);
      }

      // ✅ إصلاح: تنفيذ المزامنة الفعلية بدل التعليق الفارغ
      if (task == 'notification_sync_task') {
        final box =
            Hive.box<NotificationHiveModel>(StorageKeys.notificationsBox);

        final plugin = FlutterLocalNotificationsPlugin();
        const android = AndroidInitializationSettings('@mipmap/ic_launcher');
        const ios = DarwinInitializationSettings();
        await plugin.initialize(
          const InitializationSettings(android: android, iOS: ios),
        );

        final local = NotificationLocalDataSourceImpl(box);
        final scheduler = NotificationSchedulerService(plugin);
        final dio =
            Dio(); // يستخدم الـ base options الافتراضية في الـ background
        final apiService = NotificationApiService(
          dio,
        );

        final syncService =
            NotificationSyncService(apiService, local, scheduler);

        await syncService.sync(force: true);
      }

      debugPrint('✅ WorkManager task completed: $task');
      return true;
    } catch (e) {
      debugPrint('❌ WorkManager task failed: $e');
      return false;
    }
  });
}

Future<void> registerNotificationSync() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: kDebugMode,
  );

  // ✅ إصلاح: استخدام keep بدل replace لتجنب إعادة ضبط الـ interval في كل تشغيل
  await Workmanager().registerPeriodicTask(
    'notification_sync_task',
    'notification_sync_task',
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  debugPrint('✅ WorkManager registered with 15 minute frequency');
}
