// lib/features/weight_tracking/data/datasources/weight_remote_ds.dart
import 'package:dio/dio.dart';
import 'package:joy_of_change_v3/new_app/core/constant/api_endpoints.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/entities/weight_goal_status.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/weight_entry_model.dart';
import '../models/weight_stats_model.dart';
import '../models/weight_chart_model.dart';

class WeightRemoteDataSource {
  final DioClient _dioClient;

  WeightRemoteDataSource({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient.instance;

  // ==================== GET WEIGHTS ====================
  Future<List<WeightEntryModel>> getWeights({String? etag}) async {
    try {
      final options = Options(
        headers: {
          if (etag != null) 'If-None-Match': etag,
        },
      );

      final response = await _dioClient.get(
        ApiEndpoints.weights,
        options: options,
      );

      if (response.statusCode == 304) {
        throw const CacheNotModifiedException();
      }

      if (response.statusCode == 200 && response.data['success'] == true) {
        // ✅ إصلاح رئيسي: الـ API يرجع { "data": [...], "meta": {...} }
        // نستخدم fromJsonList الذي يتعامل مع pagination تلقائياً
        return WeightEntryModel.fromJsonList(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load weights',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ==================== GET WEIGHT STATS ====================
  Future<WeightStatsModel> getWeightStats() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.weightStats);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return WeightStatsModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load weight stats',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ==================== GET WEIGHT CHART ====================
  Future<WeightChartModel> getWeightChart() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.weightChart);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return WeightChartModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load weight chart',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ==================== GET IDEAL WEIGHT STATUS ====================
  Future<WeightGoalStatus> getIdealWeightStatus() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.weightIdealStatus);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return WeightGoalStatus.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load weight status',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ==================== ADD WEIGHT ENTRY ====================
  Future<void> addWeightEntry(double weight, DateTime date, {String? notes}) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.addWeight,
        data: {
          'weight': weight,
          'recorded_date': date.toIso8601String().split('T')[0],
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to add weight entry',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ==================== BATCH GET ALL DATA ====================
  Future<Map<String, dynamic>> getAllWeightData() async {
    try {
      final results = await Future.wait([
        _dioClient.get(ApiEndpoints.weights),
        _dioClient.get(ApiEndpoints.weightStats),
        _dioClient.get(ApiEndpoints.weightChart),
        _dioClient.get(ApiEndpoints.weightIdealStatus),
      ]);

      return {
        'weights': results[0].data,  // نمرر الـ response كاملاً
        'stats': results[1].data,
        'chart': results[2].data,
        'status': results[3].data,
        'etag': results[0].headers['etag']?.first,
      };
    } catch (e) {
      throw ServerException(
        message: 'Failed to load all data: ${e.toString()}',
        statusCode: null,
      );
    }
  }
}

// استثناء مخصص لـ 304 Not Modified
class CacheNotModifiedException implements Exception {
  const CacheNotModifiedException();
}
