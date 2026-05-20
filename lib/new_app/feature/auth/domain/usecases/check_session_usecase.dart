// lib/features/auth/domain/usecases/check_session_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case to check if current session is valid
class CheckSessionUseCase {
  final AuthRepository repository;

  CheckSessionUseCase(this.repository);

  /// Check session validity
  /// Returns [User] on success (session valid), [Failure] on error
  Future<Either<Failure, User>> call() async {
    // First check if we have a stored token
    final token = await repository.getStoredToken();

    if (token == null || token.isEmpty) {
      return Left(SessionExpiredFailure(
        message: 'No session found. Please login.',
      ));
    }

    // Check if we have stored user
    final storedUser = await repository.getStoredUser();

    if (storedUser != null) {
      // We have a cached user, return it
      return Right(storedUser);
    }

    // No cached user, but we have token - consider session valid
    // The user will be loaded when needed
    return Left(SessionExpiredFailure(
      message: 'User data not found. Please login again.',
    ));
  }
}
