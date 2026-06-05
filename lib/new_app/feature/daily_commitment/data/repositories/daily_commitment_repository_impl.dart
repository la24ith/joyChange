// lib/features/daily_commitment/data/repositories/daily_commitment_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/repositories/aily_commitment_repository.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/daily_question.dart';
import '../../domain/entities/daily_answer.dart';
import '../../domain/entities/daily_stats.dart';
import '../datasources/daily_commitment_remote_ds.dart';

class DailyCommitmentRepositoryImpl implements DailyCommitmentRepository {
  final DailyCommitmentRemoteDataSource remoteDataSource;

  DailyCommitmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DailyQuestion>> getTodayQuestion() async {
    try {
      final question = await remoteDataSource.getTodayQuestion();
      return Right(question);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to load question: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, DailyAnswer>> submitAnswer({
    required String answer,
    required DateTime date,
    String? notes,
  }) async {
    try {
      final result = await remoteDataSource.submitAnswer(
        answer: answer,
        date: date,
        notes: notes,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to submit answer: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, List<DailyAnswer>>> getAnswerHistory() async {
    try {
      final history = await remoteDataSource.getAnswerHistory();
      return Right(history);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to load history: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, DailyStats>> getStats() async {
    try {
      final stats = await remoteDataSource.getStats();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to load stats: ${e.toString()}',
      ));
    }
  }
}
