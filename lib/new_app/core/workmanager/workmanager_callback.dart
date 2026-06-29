// lib/new_app/core/workmanager/workmanager_callback.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:joy_of_change_v3/new_app/core/constant/api_endpoints.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';
import 'package:joy_of_change_v3/new_app/core/services/notification_scheduler_service.dart';
import 'package:joy_of_change_v3/new_app/core/services/notification_sync_service.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/datasource/notification_api_service.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/datasource/notification_local_data_source_impl.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/notification_hive_model.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/NotificationHiveModelAdapter.dart';

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

      if (task == 'notification_sync_task') {
        final box =
            Hive.box<NotificationHiveModel>(StorageKeys.notificationsBox);

        // ✅ اقرأ الـ auth token والـ timezone المحفوظَين من SharedPreferences
        // WorkManager يعمل في process منفصل — لا يرث DioClient أو getIt
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token') ?? '';
        final savedTz = prefs.getString('user_timezone') ?? 'UTC';

        // إذا لم يكن هناك token = المستخدم غير مسجّل دخول → تخطَّ
        if (token.isEmpty) {
          debugPrint('⚠️ WorkManager: No auth token, skipping sync');
          return true;
        }

        // ✅ إصلاح: Dio مع baseUrl صحيح وهيدرز المصادقة
        // الكود القديم كان يستخدم Dio() فارغاً → كل الطلبات كانت تفشل
        final dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl, // ← غيّر هذا لـ baseUrl الحقيقي
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );

        // ✅ إعداد timezone من القيمة المحفوظة
        tz.initializeTimeZones();
        try {
          tz.setLocalLocation(tz.getLocation(savedTz));
        } catch (_) {
          tz.setLocalLocation(tz.local);
        }

        // ✅ إعداد flutter_local_notifications للـ background
        final plugin = FlutterLocalNotificationsPlugin();
        await plugin.initialize(
          const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            iOS: DarwinInitializationSettings(),
          ),
        );

        final local = NotificationLocalDataSourceImpl(box);
        final scheduler = NotificationSchedulerService(plugin);
        final apiService = NotificationApiService(dio);
        final syncService =
            NotificationSyncService(apiService, local, scheduler);

        // force: true لأن _lastSyncTime يُصفَّر في كل process جديد
        await syncService.sync(force: true);
      }

      debugPrint('✅ WorkManager task completed: $task');
      return true;
    } catch (e, stack) {
      debugPrint('❌ WorkManager task failed: $e');
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
    // keep: لا تعيد ضبط الـ interval في كل تشغيل للتطبيق
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  debugPrint('✅ WorkManager registered — 15 minute sync');
}
