// lib/features/weight_tracking/domain/usecases/get_weight_chart_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../repositories/weight_repository.dart';

class GetWeightChartUseCase {
  final WeightRepository repository;

  GetWeightChartUseCase(this.repository);

  Future<Either<Failure, List<double>>> call({
    bool forceRefresh = false,
  }) async {
    return await repository.getWeightChart(forceRefresh: forceRefresh);
  }
}
