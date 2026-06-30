// lib/new_app/core/workmanager/workmanager_callback.dart
//
// ملاحظة: بعد الاعتماد على FCM فقط لعرض الإشعارات،
// هذا الـ WorkManager لم يعد مسؤولاً عن أي جدولة أو عرض —
// فقط يُحدّث قائمة الإشعارات المحلية (Hive) بصمت في الخلفية
// حتى تكون شاشة "الإشعارات" محدّثة عند فتح التطبيق.

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:joy_of_change_v3/new_app/core/constant/api_endpoints.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';
import 'package:joy_of_change_v3/new_app/core/services/notification_sync_service.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/datasource/notification_api_service.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/datasource/notification_local_data_source_impl.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/notification_hive_model.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/NotificationHiveModelAdapter.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('WorkManager task started: $task');

    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);

      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(NotificationHiveModelAdapter());
      }

      if (!Hive.isBoxOpen(StorageKeys.notificationsBox)) {
        await Hive.openBox<NotificationHiveModel>(StorageKeys.notificationsBox);
      }

      if (task == 'notification_sync_task') {
        final box =
            Hive.box<NotificationHiveModel>(StorageKeys.notificationsBox);

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token') ?? '';

        if (token.isEmpty) {
          debugPrint('WorkManager: No auth token, skipping sync');
          return true;
        }

        final dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );

        final local = NotificationLocalDataSourceImpl(box);
        final apiService = NotificationApiService(dio);

        // لا scheduler بعد الآن — فقط تحديث القائمة المحلية بصمت
        final syncService = NotificationSyncService(apiService, local);

        await syncService.sync(force: true);
      }

      debugPrint('WorkManager task completed: $task');
      return true;
    } catch (e, stack) {
      debugPrint('WorkManager task failed: $e');
      debugPrint(stack.toString());
      return false;
    }
  });
}

Future<void> registerNotificationSync() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: kDebugMode,
  );

  await Workmanager().registerPeriodicTask(
    'notification_sync_task',
    'notification_sync_task',
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  debugPrint('WorkManager registered — list sync only, no local scheduling');
}
