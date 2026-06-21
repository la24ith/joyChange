// lib/features/daily_commitment/domain/repositories/daily_commitment_repository.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/daily_question.dart';
import '../entities/daily_answer.dart';
import '../entities/daily_stats.dart';
import '../../data/models/local_commitment_data.dart';

abstract class DailyCommitmentRepository {
  // Remote
  Future<Either<Failure, DailyQuestion>> getTodayQuestion();
  Future<Either<Failure, DailyAnswer>> submitAnswer({
    required String answer,
    required DateTime date,
    String? notes,
  });
  Future<Either<Failure, List<DailyAnswer>>> getAnswerHistory();
  Future<Either<Failure, DailyStats>> getStats();

  // Local
  Future<LocalCommitmentData> getLocalData();
  Future<void> saveLocalData(LocalCommitmentData data);
  Future<void> savePendingAnswer({
    required String answer,
    required DateTime date,
    String? notes,
  });
  Future<List<Map<String, dynamic>>> getPendingAnswers();
  Future<void> clearPendingAnswers();
  Future<void> removePendingAnswer(int index);
  Future<void> syncPendingAnswers();
  Future<void> clearAllLocalData();
}
