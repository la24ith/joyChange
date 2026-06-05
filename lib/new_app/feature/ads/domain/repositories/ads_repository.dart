// lib/features/ads/domain/repositories/ads_repository.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/ad.dart';

abstract class AdsRepository {
  Future<Either<Failure, List<Ad>>> getActiveAds();
  Future<Either<Failure, void>> registerClick(int adId);
}
