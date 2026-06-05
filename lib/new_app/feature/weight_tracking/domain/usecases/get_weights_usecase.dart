// lib/features/weight_tracking/domain/usecases/get_weights_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/weight_entry.dart';
import '../repositories/weight_repository.dart';

class GetWeightsUseCase {
  final WeightRepository repository;

  GetWeightsUseCase(this.repository);

  Future<Either<Failure, List<WeightEntry>>> call() async {
    return await repository.getWeights();
  }
}
