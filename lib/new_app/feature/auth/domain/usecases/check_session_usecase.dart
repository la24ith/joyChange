// lib/features/auth/domain/usecases/check_session_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class CheckSessionUseCase {
  final AuthRepository repository;

  CheckSessionUseCase(this.repository);

  Future<Either<Failure, User>> call() async {
    final token = await repository.getStoredToken();

    if (token == null || token.isEmpty) {
      return Left(SessionExpiredFailure(
        message: 'No session found. Please login.',
      ));
    }

    final user = await repository.getStoredUser();

    if (user == null) {
      return Left(SessionExpiredFailure(
        message: 'User data not found. Please login again.',
      ));
    }

    try {
      final subscriptionResult =
          await repository.checkSubscriptionStatus(user.email);

      return subscriptionResult.fold(
        (failure) => Right(user),
        (isActive) {
          if (isActive) {
            return Right(user);
          } else {
            return Left(SubscriptionExpiredFailure(
              message: 'Your subscription has expired. Please contact support.',
            ));
          }
        },
      );
    } catch (e) {
      return Right(user);
    }
  }
}
