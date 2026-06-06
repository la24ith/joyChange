import 'package:joy_of_change_v3/new_app/core/di/service_locator.dart';
import 'package:joy_of_change_v3/new_app/core/services/notification_sync_service.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await setupServiceLocator();

    await getIt<NotificationSyncService>().sync();

    return true;
  });
}

Future<void> registerNotificationSync() async {
  await Workmanager().initialize(callbackDispatcher);

  await Workmanager().registerPeriodicTask(
    'notification_sync_task',
    'notification_sync_task',
    frequency: const Duration(minutes: 10),
  );
}
