// lib/features/auth/domain/usecases/check_auth_state_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../../data/models/auth_state_model.dart';
import '../repositories/auth_repository.dart';

/// Parameters for checking auth state
class CheckAuthStateParams {
  final String email;
  final String deviceId;
  final String? password;

  const CheckAuthStateParams({
    required this.email,
    required this.deviceId,
    this.password,
  });
}

/// Use case for checking authentication state
/// This is used for polling after registration to check when subscription is activated
class CheckAuthStateUseCase {
  final AuthRepository repository;

  CheckAuthStateUseCase(this.repository);

  /// Execute auth state check
  /// Returns [AuthStateModel] with current state
  Future<Either<Failure, AuthStateModel>> call(
      CheckAuthStateParams params) async {
    // Validate email
    if (params.email.isEmpty) {
      return Left(ValidationFailure(
        message: 'Email is required',
        errors: {
          'email': ['Email cannot be empty'],
        },
      ));
    }

    // Validate device ID
    if (params.deviceId.isEmpty) {
      return Left(ValidationFailure(
        message: 'Device ID is required',
        errors: {
          'device_id': ['Device ID cannot be empty'],
        },
      ));
    }

    return await repository.checkAuthState(
      email: params.email,
      deviceId: params.deviceId,
      password: params.password,
    );
  }
}
