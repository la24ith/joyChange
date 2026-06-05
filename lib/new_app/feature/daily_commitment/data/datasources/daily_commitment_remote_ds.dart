// lib/features/daily_commitment/data/datasources/daily_commitment_remote_ds.dart

import 'package:dio/dio.dart';
import 'package:joy_of_change_v3/new_app/core/constant/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/daily_question_model.dart';
import '../models/daily_answer_model.dart';
import '../models/daily_stats_model.dart';

class DailyCommitmentRemoteDataSource {
  final DioClient _dioClient;

  DailyCommitmentRemoteDataSource({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient.instance;

  Future<DailyQuestionModel> getTodayQuestion() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.dailyCommitmentToday);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return DailyQuestionModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load question',
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

  Future<DailyAnswerModel> submitAnswer({
    required String answer,
    required DateTime date,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.dailyCommitmentAnswer,
        data: {
          'answer': answer,
          'date': date.toIso8601String().split('T')[0],
          if (notes != null) 'notes': notes,
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        return DailyAnswerModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to submit answer',
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

  Future<List<DailyAnswerModel>> getAnswerHistory() async {
    try {
      final response =
          await _dioClient.get(ApiEndpoints.dailyCommitmentHistory);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => DailyAnswerModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load history',
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

  Future<DailyStatsModel> getStats() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.dailyCommitmentStats);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return DailyStatsModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load stats',
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
