// lib/features/auth/domain/usecases/change_password_usecase.dart
/*
import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../repositories/auth_repository.dart';

/// Input parameters for password change
class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });
}

/// Use case for changing user password
class ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCase(this.repository);

  /// Execute password change with given parameters
  /// Returns success message on success, [Failure] on error
  Future<Either<Failure, String>> call(ChangePasswordParams params) async {
    // Validate current password
    if (params.currentPassword.isEmpty) {
      return Left(ValidationFailure(
        message: 'Current password is required',
        errors: {
          'current_password': ['Please enter your current password']
        },
      ));
    }

    // Validate new password
    if (params.newPassword.isEmpty) {
      return Left(ValidationFailure(
        message: 'New password is required',
        errors: {
          'new_password': ['Please enter a new password']
        },
      ));
    }

    if (params.newPassword.length < 6) {
      return Left(ValidationFailure(
        message: 'Password too short',
        errors: {
          'new_password': ['Password must be at least 6 characters']
        },
      ));
    }

    // Check if new password is different from current
    if (params.newPassword == params.currentPassword) {
      return Left(ValidationFailure(
        message: 'Password must be different',
        errors: {
          'new_password': [
            'New password must be different from current password'
          ]
        },
      ));
    }

    // Validate password confirmation
    if (params.newPassword != params.newPasswordConfirmation) {
      return Left(ValidationFailure(
        message: 'Password confirmation does not match',
        errors: {
          'new_password_confirmation': ['Passwords do not match']
        },
      ));
    }

    // Execute password change
    return await repository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
      newPasswordConfirmation: params.newPasswordConfirmation,
    );
  }
}*/
