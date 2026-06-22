// lib/core/storage/hive_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/NotificationHiveModelAdapter.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/notification_hive_model.dart';
import 'package:path_provider/path_provider.dart';
import '../constant/storage_keys.dart';

class HiveService {
  static HiveService? _instance;
  static HiveService get instance => _instance ??= HiveService._();

  HiveService._();

  /// Initialize Hive with custom directory - THIS IS THE ONLY PLACE
  /// where Hive.initFlutter() should be called!
  Future<void> init() async {
    try {
      // ✅ Hive.initFlutter() تُستدعى مرة واحدة فقط هنا
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);
      debugPrint('✅ Hive initialized with path: ${appDocumentDir.path}');

      // ✅ تسجيل Adapter للإشعارات إن لم يكن مسجلاً
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(NotificationHiveModelAdapter());
        debugPrint('✅ NotificationHiveModelAdapter registered in HiveService');
      }

      // ✅ فتح جميع الصناديق
      await _openBoxes();
      debugPrint('✅ All Hive boxes opened successfully');
    } catch (e) {
      debugPrint('❌ Error initializing HiveService: $e');
      rethrow;
    }
  }

  Future<void> _openBoxes() async {
    // ✅ فتح user_box
    if (!Hive.isBoxOpen('user_box')) {
      await Hive.openBox('user_box');
      debugPrint('✅ user_box opened');
    }

    // ✅ فتح posts_box
    if (!Hive.isBoxOpen(StorageKeys.postsBox)) {
      await Hive.openBox(StorageKeys.postsBox);
      debugPrint('✅ ${StorageKeys.postsBox} opened');
    }

    // ✅ فتح weights_box
    if (!Hive.isBoxOpen(StorageKeys.weightsBox)) {
      await Hive.openBox(StorageKeys.weightsBox);
      debugPrint('✅ ${StorageKeys.weightsBox} opened');
    }

    // ✅ فتح dailyCommitment_box
    if (!Hive.isBoxOpen(StorageKeys.dailyCommitmentBox)) {
      await Hive.openBox(StorageKeys.dailyCommitmentBox);
      debugPrint('✅ ${StorageKeys.dailyCommitmentBox} opened');
    }

    // ✅ فتح syncQueue_box
    if (!Hive.isBoxOpen(StorageKeys.syncQueueBox)) {
      await Hive.openBox(StorageKeys.syncQueueBox);
      debugPrint('✅ ${StorageKeys.syncQueueBox} opened');
    }

    // ✅ فتح notifications_box مع النوع المحدد
    if (!Hive.isBoxOpen(StorageKeys.notificationsBox)) {
      await Hive.openBox<NotificationHiveModel>(StorageKeys.notificationsBox);
      debugPrint('✅ ${StorageKeys.notificationsBox} opened');
    }
  }

  // Generic get box with type safety
  Box<T> getBox<T>(String boxName) {
    try {
      return Hive.box<T>(boxName);
    } catch (e) {
      debugPrint('⚠️ Error getting box $boxName: $e');
      rethrow;
    }
  }

  // Check if box is open
  bool isBoxOpen(String boxName) {
    return Hive.isBoxOpen(boxName);
  }

  // Clear specific box
  Future<void> clearBox(String boxName) async {
    try {
      final box = Hive.box(boxName);
      await box.clear();
      debugPrint('✅ Box $boxName cleared');
    } catch (e) {
      debugPrint('❌ Error clearing box $boxName: $e');
      rethrow;
    }
  }

  // Close all boxes (useful for logout or app termination)
  Future<void> closeAllBoxes() async {
    try {
      await Hive.close();
      debugPrint('✅ All Hive boxes closed');
    } catch (e) {
      debugPrint('❌ Error closing Hive boxes: $e');
      rethrow;
    }
  }

  // Delete specific box
  Future<void> deleteBox(String boxName) async {
    try {
      await Hive.deleteBoxFromDisk(boxName);
      debugPrint('✅ Box $boxName deleted');
    } catch (e) {
      debugPrint('❌ Error deleting box $boxName: $e');
      rethrow;
    }
  }

  // Get box size (number of entries)
  int getBoxSize(String boxName) {
    try {
      return Hive.box(boxName).length;
    } catch (e) {
      debugPrint('⚠️ Error getting box size for $boxName: $e');
      return 0;
    }
  }

  // Check if box is empty
  bool isBoxEmpty(String boxName) {
    try {
      return Hive.box(boxName).isEmpty;
    } catch (e) {
      debugPrint('⚠️ Error checking if box $boxName is empty: $e');
      return true;
    }
  }
}
