// lib/features/weight_tracking/domain/usecases/get_weight_stats_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/weight_stats.dart';
import '../repositories/weight_repository.dart';

class GetWeightStatsUseCase {
  final WeightRepository repository;

  GetWeightStatsUseCase(this.repository);

  Future<Either<Failure, WeightStats>> call({
    bool forceRefresh = false,
  }) async {
    return await repository.getWeightStats(forceRefresh: forceRefresh);
  }
}
