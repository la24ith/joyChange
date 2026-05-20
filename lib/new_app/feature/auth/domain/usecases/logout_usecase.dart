// lib/features/auth/domain/usecases/logout_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../repositories/auth_repository.dart';

/// Use case for user logout
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  /// Execute logout
  /// Returns void on success, [Failure] on error
  Future<Either<Failure, void>> call() async {
    // Try to call logout API, but even if it fails, clear local data
    final result = await repository.logout();

    // Always clear local data regardless of API result
    await repository.clearLocalAuthData();

    return result;
  }
}
