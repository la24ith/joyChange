// lib/features/daily_commitment/data/repositories/daily_commitment_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/repositories/aily_commitment_repository.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/daily_question.dart';
import '../../domain/entities/daily_answer.dart';
import '../../domain/entities/daily_stats.dart';
import '../datasources/daily_commitment_remote_ds.dart';
import '../datasources/daily_commitment_local_ds.dart';
import '../models/local_commitment_data.dart';

class DailyCommitmentRepositoryImpl implements DailyCommitmentRepository {
  final DailyCommitmentRemoteDataSource remoteDataSource;
  final DailyCommitmentLocalDataSource localDataSource;

  DailyCommitmentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ============================================================================
  // 🌐 Remote Methods
  // ============================================================================

  @override
  Future<Either<Failure, DailyQuestion>> getTodayQuestion() async {
    try {
      final question = await remoteDataSource.getTodayQuestion();
      return Right(question);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to load question: ${e.toString()}'));
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
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to submit answer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DailyAnswer>>> getAnswerHistory() async {
    try {
      final history = await remoteDataSource.getAnswerHistory();
      return Right(history);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to load history: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DailyStats>> getStats() async {
    try {
      final stats = await remoteDataSource.getStats();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to load stats: ${e.toString()}'));
    }
  }

  // ============================================================================
  // 💾 Local Methods
  // ============================================================================

  @override
  Future<LocalCommitmentData> getLocalData() async {
    return await localDataSource.getCachedData();
  }

  @override
  Future<void> saveLocalData(LocalCommitmentData data) async {
    await localDataSource.saveData(data);
  }

  @override
  Future<void> savePendingAnswer({
    required String answer,
    required DateTime date,
    String? notes,
  }) async {
    await localDataSource.savePendingAnswer(answer: answer, date: date, notes: notes);
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingAnswers() async {
    return await localDataSource.getPendingAnswers();
  }

  @override
  Future<void> clearPendingAnswers() async {
    await localDataSource.clearPendingAnswers();
  }

  @override
  Future<void> removePendingAnswer(int index) async {
    await localDataSource.removePendingAnswer(index);
  }

  @override
  Future<void> syncPendingAnswers() async {
    final pending = await localDataSource.getPendingAnswers();
    if (pending.isEmpty) return;

    print('🔄 Syncing ${pending.length} pending answers...');

    // FIX: iterate in reverse so removing by index stays correct,
    // and treat "already answered" as a success (remove from queue).
    for (var i = pending.length - 1; i >= 0; i--) {
      final answerData = pending[i];
      try {
        await remoteDataSource.submitAnswer(
          answer: answerData['answer'],
          date: DateTime.parse(answerData['date']),
          notes: answerData['notes'],
        );
        await localDataSource.removePendingAnswer(i);
        print('✅ Pending answer synced successfully');
      } on ServerException catch (e) {
        // "Already answered" means the data is on the server → remove from queue
        if (_isAlreadyAnsweredError(e.message)) {
          print('⚠️ Already answered on server — removing stale pending entry');
          await localDataSource.removePendingAnswer(i);
        } else {
          print('❌ Failed to sync pending answer: ${e.message}');
          // Non-recoverable for now; stop and retry later
          break;
        }
      } catch (e) {
        // Treat any "already answered" string in generic exceptions the same way
        final msg = e.toString();
        if (_isAlreadyAnsweredError(msg)) {
          print('⚠️ Already answered on server — removing stale pending entry');
          await localDataSource.removePendingAnswer(i);
        } else {
          print('❌ Failed to sync pending answer: $e');
          break;
        }
      }
    }

    // Mark as synced only when queue is empty
    final remaining = await localDataSource.getPendingAnswers();
    if (remaining.isEmpty) {
      final localData = await localDataSource.getCachedData();
      await localDataSource.saveData(localData.markAsSynced());
      print('✅ All pending answers synced — marked as synced');
    }
  }

  @override
  Future<void> clearAllLocalData() async {
    await localDataSource.clearAll();
  }

  // ============================================================================
  // 🔧 Helpers
  // ============================================================================

  bool _isAlreadyAnsweredError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('already answered') || lower.contains('already');
  }
}
