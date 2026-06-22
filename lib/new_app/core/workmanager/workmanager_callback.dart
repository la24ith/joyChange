// core/workmanager/workmanager_callback.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:joy_of_change_v3/new_app/core/di/service_locator.dart';
import 'package:joy_of_change_v3/new_app/core/services/notification_sync_service.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/notification_hive_model.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/NotificationHiveModelAdapter.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('🔧 WorkManager task started: $task');
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path); // ✅ نفس مسار HiveService

      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(NotificationHiveModelAdapter());
      }

      if (!Hive.isBoxOpen(StorageKeys.notificationsBox)) {
        await Hive.openBox<NotificationHiveModel>(StorageKeys.notificationsBox);
      }

      // ✅ بدل setupServiceLocator() الكاملة
      if (task == 'notification_sync_task') {
        // sync logic هنا مباشرة
      }

      debugPrint('✅ WorkManager task completed: $task');
      return true;
    } catch (e) {
      debugPrint('❌ WorkManager task failed: $e');
      return false; // ✅ كان true
    }
  });
}

Future<void> registerNotificationSync() async {
  // ✅ التهيئة مع isInDebugMode
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: kDebugMode,
  );

  // ✅ الحل الصحيح: استخدام ExistingPeriodicWorkPolicy
  await Workmanager().registerPeriodicTask(
    'notification_sync_task',
    'notification_sync_task',
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace, // ✅ التغيير هنا
  );

  debugPrint('✅ WorkManager registered with 15 minute frequency');
}
