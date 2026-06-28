// lib/features/weight_tracking/domain/usecases/add_weight_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../repositories/weight_repository.dart';

class AddWeightParams {
  final double weight;
  final DateTime date;
  final String? notes;

  const AddWeightParams({
    required this.weight,
    required this.date,
    this.notes,
  });
}

class AddWeightUseCase {
  final WeightRepository repository;

  AddWeightUseCase(this.repository);

  Future<Either<Failure, void>> call(AddWeightParams params) async {
    if (params.weight <= 0) {
      return Left(ValidationFailure(message: 'الوزن يجب أن يكون أكبر من صفر'));
    }

    if (params.weight > 500) {
      return Left(
          ValidationFailure(message: 'الوزن يجب أن يكون أقل من 500 كغ'));
    }

    if (params.date.isAfter(DateTime.now())) {
      return Left(ValidationFailure(message: 'لا يمكن إضافة قياس في المستقبل'));
    }

    return await repository.addWeightEntry(
      weight: params.weight,
      date: params.date,
      notes: params.notes,
    );
  }
}
