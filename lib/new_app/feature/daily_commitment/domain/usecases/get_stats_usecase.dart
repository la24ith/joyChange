// lib/features/daily_commitment/domain/usecases/get_stats_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/repositories/aily_commitment_repository.dart';
import '../entities/daily_stats.dart';

class GetStatsUseCase {
  final DailyCommitmentRepository repository;

  GetStatsUseCase(this.repository);

  Future<Either<Failure, DailyStats>> call() async {
    return await repository.getStats();
  }
}
