// lib/features/drawer/data/repositories/subscription_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_ds.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserSubscription>> getUserSubscription() async {
    try {
      final subscription = await remoteDataSource.getUserSubscription();
      return Right(subscription.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to load subscription: ${e.toString()}',
      ));
    }
  }

  @override
  Stream<UserSubscription> watchUserSubscription() {
    return remoteDataSource
        .watchUserSubscription()
        .map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Logout failed: ${e.toString()}',
      ));
    }
  }
}
