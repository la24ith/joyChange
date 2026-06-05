// lib/features/ads/data/repositories/ads_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/ad.dart';
import '../../domain/repositories/ads_repository.dart';
import '../datasources/ads_remote_ds.dart';

class AdsRepositoryImpl implements AdsRepository {
  final AdsRemoteDataSource remoteDataSource;

  AdsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Ad>>> getActiveAds() async {
    try {
      final ads = await remoteDataSource.getActiveAds();
      return Right(ads.map((a) => a.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to load ads: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> registerClick(int adId) async {
    try {
      await remoteDataSource.registerClick(adId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to register click: ${e.toString()}',
      ));
    }
  }
}
