// core/workmanager/workmanager_callback.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';
import 'package:workmanager/workmanager.dart';
import 'package:joy_of_change_v3/new_app/core/di/service_locator.dart';
import 'package:joy_of_change_v3/new_app/core/services/notification_sync_service.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/notification_hive_model.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/NotificationHiveModelAdapter.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().executeTask((task, inputData) async {
    debugPrint('🔧 WorkManager task started: $task');

    try {
      // ✅ تهيئة Hive في الـ isolate (مهم جداً)
      await Hive.initFlutter();

      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(NotificationHiveModelAdapter());
      }

      await Hive.openBox<NotificationHiveModel>(StorageKeys.notificationsBox);
      await setupServiceLocator();

      if (task == 'notification_sync_task') {
        await getIt<NotificationSyncService>().sync();
      }

      debugPrint('✅ WorkManager task completed: $task');
    } catch (e) {
      debugPrint('❌ WorkManager task failed: $e');
    }

    return true;
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
