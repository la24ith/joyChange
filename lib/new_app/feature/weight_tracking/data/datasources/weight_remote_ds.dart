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

  Future<List<WeightEntryModel>> getWeights() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.weights);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => WeightEntryModel.fromJson(json)).toList();
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

  Future<void> addWeightEntry(double weight, DateTime date,
      {String? notes}) async {
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
}
