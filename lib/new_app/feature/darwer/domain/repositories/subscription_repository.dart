// lib/features/drawer/domain/repositories/subscription_repository.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/domain/entities/user_subscription.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, UserSubscription>> getUserSubscription();
  Stream<UserSubscription> watchUserSubscription();
  Future<Either<Failure, void>> logout();
}
