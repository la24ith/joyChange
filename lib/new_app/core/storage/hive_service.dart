// lib/core/storage/hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/notification_hive_model.dart';
import 'package:path_provider/path_provider.dart';
import '../constant/storage_keys.dart';

class HiveService {
  static HiveService? _instance;
  static HiveService get instance => _instance ??= HiveService._();

  HiveService._();

  /// Initialize Hive with custom directory
  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Register adapters here if needed
    // Hive.registerAdapter(PostAdapter());
    // Hive.registerAdapter(WeightEntryAdapter());

    // Open all boxes
    await _openBoxes();
  }

  Future<void> _openBoxes() async {
    if (!Hive.isBoxOpen(StorageKeys.postsBox)) {
      await Hive.openBox(StorageKeys.postsBox);
    }
    if (!Hive.isBoxOpen(StorageKeys.weightsBox)) {
      await Hive.openBox(StorageKeys.weightsBox);
    }
    if (!Hive.isBoxOpen(StorageKeys.dailyCommitmentBox)) {
      await Hive.openBox(StorageKeys.dailyCommitmentBox);
    }
    if (!Hive.isBoxOpen(StorageKeys.syncQueueBox)) {
      await Hive.openBox(StorageKeys.syncQueueBox);
    }
    if (!Hive.isBoxOpen(StorageKeys.notificationsBox)) {
      await Hive.openBox<NotificationHiveModel>(StorageKeys.notificationsBox);
    }
  }

  // Generic get box
  Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }

  // Check if box is open
  bool isBoxOpen(String boxName) {
    return Hive.isBoxOpen(boxName);
  }

  // Clear specific box
  Future<void> clearBox(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  // Close all boxes (useful for logout or app termination)
  Future<void> closeAllBoxes() async {
    await Hive.close();
  }

  // Delete specific box
  Future<void> deleteBox(String boxName) async {
    await Hive.deleteBoxFromDisk(boxName);
  }

  // Get box size (number of entries)
  int getBoxSize(String boxName) {
    return Hive.box(boxName).length;
  }
}
