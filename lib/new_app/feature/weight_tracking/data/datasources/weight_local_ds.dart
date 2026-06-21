// lib/features/weight_tracking/data/datasources/weight_local_ds.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weight_entry_model.dart';
import '../models/weight_stats_model.dart';
import '../models/weight_chart_model.dart';
import '../../domain/entities/weight_goal_status.dart';

class WeightLocalDataSource {
  final SharedPreferences _prefs;

  WeightLocalDataSource(this._prefs);

  // مفاتيح التخزين
  static const String _entriesKey = 'weight_entries_cache';
  static const String _statsKey = 'weight_stats_cache';
  static const String _chartKey = 'weight_chart_cache';
  static const String _statusKey = 'weight_status_cache';
  static const String _timestampKey = 'weight_cache_timestamp';
  static const String _etagKey = 'weight_cache_etag';

  // مدة الصلاحية: 30 دقيقة
  static const int _cacheDurationMinutes = 30;

  // ==================== WEIGHT ENTRIES ====================
  Future<void> cacheWeightEntries(List<WeightEntryModel> entries) async {
    try {
      final jsonList = entries.map((e) => e.toJson()).toList();
      await _prefs.setString(_entriesKey, jsonEncode(jsonList));
      await _updateTimestamp();
    } catch (e) {
      // Log error but don't fail
      print('Error caching weight entries: $e');
    }
  }

  List<WeightEntryModel>? getCachedWeightEntries() {
    try {
      final jsonString = _prefs.getString(_entriesKey);
      if (jsonString == null) return null;

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => WeightEntryModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting cached weight entries: $e');
      return null;
    }
  }

  // ==================== WEIGHT STATS ====================
  Future<void> cacheWeightStats(WeightStatsModel stats) async {
    try {
      await _prefs.setString(_statsKey, jsonEncode(stats.toJson()));
      await _updateTimestamp();
    } catch (e) {
      print('Error caching weight stats: $e');
    }
  }

  WeightStatsModel? getCachedWeightStats() {
    try {
      final jsonString = _prefs.getString(_statsKey);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return WeightStatsModel.fromJson(json);
    } catch (e) {
      print('Error getting cached weight stats: $e');
      return null;
    }
  }

  // ==================== WEIGHT CHART ====================
  Future<void> cacheWeightChart(WeightChartModel chart) async {
    try {
      await _prefs.setString(_chartKey, jsonEncode(chart.toJson()));
      await _updateTimestamp();
    } catch (e) {
      print('Error caching weight chart: $e');
    }
  }

  WeightChartModel? getCachedWeightChart() {
    try {
      final jsonString = _prefs.getString(_chartKey);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return WeightChartModel.fromJson(json);
    } catch (e) {
      print('Error getting cached weight chart: $e');
      return null;
    }
  }

  // ==================== WEIGHT STATUS ====================
  Future<void> cacheWeightStatus(WeightGoalStatus status) async {
    try {
      // ✅ إصلاح: التحقق من null قبل التحويل إلى JSON
      final jsonMap = status.toJson();
      final jsonString = jsonEncode(jsonMap);
      await _prefs.setString(_statusKey, jsonString);
      await _updateTimestamp();
    } catch (e) {
      print('Error caching weight status: $e');
    }
  }

  WeightGoalStatus? getCachedWeightStatus() {
    try {
      final jsonString = _prefs.getString(_statusKey);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return WeightGoalStatus.fromJson(json);
    } catch (e) {
      print('Error getting cached weight status: $e');
      return null;
    }
  }

  // ==================== TIMESTAMP & ETAG ====================
  Future<void> _updateTimestamp() async {
    try {
      await _prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error updating timestamp: $e');
    }
  }

  DateTime? getCacheTimestamp() {
    try {
      final timestamp = _prefs.getInt(_timestampKey);
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      print('Error getting cache timestamp: $e');
      return null;
    }
  }

  bool get isCacheValid {
    final timestamp = getCacheTimestamp();
    if (timestamp == null) return false;

    final cacheAge = DateTime.now().difference(timestamp);
    return cacheAge.inMinutes < _cacheDurationMinutes;
  }

  bool get hasValidCache {
    return isCacheValid && hasAnyData;
  }

  bool get hasAnyData {
    return _prefs.containsKey(_entriesKey) ||
        _prefs.containsKey(_statsKey) ||
        _prefs.containsKey(_chartKey) ||
        _prefs.containsKey(_statusKey);
  }

  Future<void> setETag(String etag) async {
    try {
      await _prefs.setString(_etagKey, etag);
    } catch (e) {
      print('Error setting ETag: $e');
    }
  }

  String? getETag() {
    try {
      return _prefs.getString(_etagKey);
    } catch (e) {
      print('Error getting ETag: $e');
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      await _prefs.remove(_entriesKey);
      await _prefs.remove(_statsKey);
      await _prefs.remove(_chartKey);
      await _prefs.remove(_statusKey);
      await _prefs.remove(_timestampKey);
      await _prefs.remove(_etagKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // ==================== CACHE STATISTICS ====================
  int getCacheSize() {
    int size = 0;
    final keys = [
      _entriesKey,
      _statsKey,
      _chartKey,
      _statusKey,
      _timestampKey,
      _etagKey
    ];
    for (var key in keys) {
      final value = _prefs.getString(key);
      if (value != null) {
        size += value.length;
      }
    }
    return size;
  }

  Map<String, dynamic> getCacheInfo() {
    final timestamp = getCacheTimestamp();
    return {
      'hasValidCache': hasValidCache,
      'timestamp': timestamp,
      'cacheAge': timestamp != null
          ? DateTime.now().difference(timestamp).inMinutes
          : null,
      'cacheSize': getCacheSize(),
      'hasEntries': _prefs.containsKey(_entriesKey),
      'hasStats': _prefs.containsKey(_statsKey),
      'hasChart': _prefs.containsKey(_chartKey),
      'hasStatus': _prefs.containsKey(_statusKey),
      'etag': getETag(),
    };
  }
}
