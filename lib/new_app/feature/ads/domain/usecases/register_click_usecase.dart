// lib/features/ads/domain/usecases/register_click_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../repositories/ads_repository.dart';

class RegisterClickUseCase {
  final AdsRepository repository;

  RegisterClickUseCase(this.repository);

  Future<Either<Failure, void>> call(int adId) async {
    if (adId <= 0) {
      return Left(ValidationFailure(message: 'Invalid ad ID'));
    }
    return await repository.registerClick(adId);
  }
}
