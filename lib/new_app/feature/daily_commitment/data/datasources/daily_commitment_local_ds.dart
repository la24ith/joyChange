import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/data/models/local_commitment_data.dart';

class DailyCommitmentLocalDataSource {
  static DailyCommitmentLocalDataSource? _instance;
  static DailyCommitmentLocalDataSource get instance =>
      _instance ??= DailyCommitmentLocalDataSource._();

  DailyCommitmentLocalDataSource._();

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(StorageKeys.dailyCommitmentBox);
  }

  // ============================================================================
  // 📖 Read Data
  // ============================================================================

  Future<LocalCommitmentData> getCachedData() async {
    try {
      final jsonString = _box.get('cached_data') as String?;
      if (jsonString == null) {
        return LocalCommitmentData.empty();
      }
      return LocalCommitmentData.fromJson(jsonDecode(jsonString));
    } catch (e) {
      print('⚠️ Failed to load cached data: $e');
      return LocalCommitmentData.empty();
    }
  }

  // ============================================================================
  // 💾 Write Data
  // ============================================================================

  Future<void> saveData(LocalCommitmentData data) async {
    try {
      await _box.put('cached_data', jsonEncode(data.toJson()));
      print('✅ Local data saved successfully');
    } catch (e) {
      print('❌ Failed to save local data: $e');
      rethrow;
    }
  }

  // ============================================================================
  // 📝 Pending Answers
  // ============================================================================

  Future<void> savePendingAnswer({
    required String answer,
    required DateTime date,
    String? notes,
  }) async {
    try {
      final pendingList = _getPendingList();
      final answerData = {
        'answer': answer,
        'date': date.toIso8601String(),
        'notes': notes,
      };
      pendingList.add(answerData);
      await _box.put('pending_answers', jsonEncode(pendingList));
      print('📝 Pending answer saved: $answer');
    } catch (e) {
      print('❌ Failed to save pending answer: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPendingAnswers() async {
    try {
      return _getPendingList();
    } catch (e) {
      print('❌ Failed to get pending answers: $e');
      return [];
    }
  }

  Future<void> clearPendingAnswers() async {
    try {
      await _box.delete('pending_answers');
      print('✅ Pending answers cleared');
    } catch (e) {
      print('❌ Failed to clear pending answers: $e');
    }
  }

  Future<void> removePendingAnswer(int index) async {
    try {
      final pendingList = _getPendingList();
      if (index >= 0 && index < pendingList.length) {
        pendingList.removeAt(index);
        if (pendingList.isEmpty) {
          await _box.delete('pending_answers');
        } else {
          await _box.put('pending_answers', jsonEncode(pendingList));
        }
        print('✅ Pending answer removed at index $index');
      }
    } catch (e) {
      print('❌ Failed to remove pending answer: $e');
    }
  }

  // ============================================================================
  // 🗑️ Clear All
  // ============================================================================

  Future<void> clearAll() async {
    try {
      await _box.clear();
      print('✅ All local commitment data cleared');
    } catch (e) {
      print('❌ Failed to clear data: $e');
    }
  }

  // ============================================================================
  // 🔧 Helpers
  // ============================================================================

  List<Map<String, dynamic>> _getPendingList() {
    try {
      final jsonString = _box.get('pending_answers') as String?;
      if (jsonString == null) return [];
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      return [];
    }
  }
}
