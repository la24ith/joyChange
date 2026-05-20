// lib/features/auth/domain/usecases/check_subscription_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../repositories/auth_repository.dart';

/// Input parameters for checking subscription status
class CheckSubscriptionParams {
  final String email;

  const CheckSubscriptionParams({required this.email});
}

/// Use case for checking subscription status
class CheckSubscriptionUseCase {
  final AuthRepository repository;

  CheckSubscriptionUseCase(this.repository);

  /// Execute subscription status check
  /// Returns true if subscription is active, false otherwise
  /// ✅ أضف المعامل email
  Future<Either<Failure, bool>> call(CheckSubscriptionParams params) async {
    if (params.email.isEmpty) {
      return Left(ValidationFailure(
        message: 'Email is required to check subscription status',
      ));
    }

    return await repository.checkSubscriptionStatus(params.email);
  }
}
