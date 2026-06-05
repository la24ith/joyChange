// lib/features/ads/domain/usecases/get_active_ads_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/ad.dart';
import '../repositories/ads_repository.dart';

class GetActiveAdsUseCase {
  final AdsRepository repository;

  GetActiveAdsUseCase(this.repository);

  Future<Either<Failure, List<Ad>>> call() async {
    return await repository.getActiveAds();
  }
}
