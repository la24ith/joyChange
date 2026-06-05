// lib/core/storage/hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';
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
    await Hive.openBox(StorageKeys.postsBox);
    await Hive.openBox(StorageKeys.weightsBox);
    await Hive.openBox(StorageKeys.dailyAnswersBox);
    await Hive.openBox(StorageKeys.syncQueueBox);
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
