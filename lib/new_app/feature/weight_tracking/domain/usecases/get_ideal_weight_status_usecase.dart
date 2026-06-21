// lib/features/weight_tracking/domain/usecases/get_ideal_weight_status_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/weight_goal_status.dart';
import '../repositories/weight_repository.dart';

class GetIdealWeightStatusUseCase {
  final WeightRepository repository;

  GetIdealWeightStatusUseCase(this.repository);

  Future<Either<Failure, WeightGoalStatus>> call({
    bool forceRefresh = false,
  }) async {
    return await repository.getIdealWeightStatus(forceRefresh: forceRefresh);
  }
}
