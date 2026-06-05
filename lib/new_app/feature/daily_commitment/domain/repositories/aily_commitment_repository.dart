// lib/features/daily_commitment/domain/repositories/daily_commitment_repository.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/daily_question.dart';
import '../entities/daily_answer.dart';
import '../entities/daily_stats.dart';

abstract class DailyCommitmentRepository {
  Future<Either<Failure, DailyQuestion>> getTodayQuestion();
  Future<Either<Failure, DailyAnswer>> submitAnswer({
    required String answer,
    required DateTime date,
    String? notes,
  });
  Future<Either<Failure, List<DailyAnswer>>> getAnswerHistory();
  Future<Either<Failure, DailyStats>> getStats();
}
