// lib/features/weight_tracking/domain/repositories/weight_repository.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/weight_entry.dart';
import '../entities/weight_stats.dart';
import '../entities/weight_goal_status.dart';

abstract class WeightRepository {
  Future<Either<Failure, List<WeightEntry>>> getWeights();
  Future<Either<Failure, WeightStats>> getWeightStats();
  Future<Either<Failure, List<double>>> getWeightChart();
  Future<Either<Failure, WeightGoalStatus>> getIdealWeightStatus();
  Future<Either<Failure, void>> addWeightEntry({
    required double weight,
    required DateTime date,
    String? notes,
  });
}
