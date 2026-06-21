// lib/features/weight_tracking/domain/repositories/weight_repository.dart
import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/entities/weight_entry.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/entities/weight_goal_status.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/entities/weight_stats.dart';

abstract class WeightRepository {
  Future<Either<Failure, List<WeightEntry>>> getWeights(
      {bool forceRefresh = false});
  Future<Either<Failure, WeightStats>> getWeightStats(
      {bool forceRefresh = false});
  Future<Either<Failure, List<double>>> getWeightChart(
      {bool forceRefresh = false});
  Future<Either<Failure, WeightGoalStatus>> getIdealWeightStatus(
      {bool forceRefresh = false});
  Future<Either<Failure, void>> addWeightEntry({
    required double weight,
    required DateTime date,
    String? notes,
  });
  Future<Either<Failure, void>> clearCache();
  Future<Either<Failure, Map<String, dynamic>>> getCacheInfo();
}
