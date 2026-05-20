// lib/features/auth/domain/usecases/login_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/data/models/login_response_model.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Input parameters for login use case
class LoginParams {
  final String email;
  final String password;
  final String deviceId;

  const LoginParams({
    required this.email,
    required this.password,
    required this.deviceId,
  });
}

/// Use case for user login
/// Follows the clean architecture pattern where each use case has a single responsibility
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Execute login with given parameters
  /// Returns [User] on success, [Failure] on error
  Future<Either<Failure, LoginResponseModel>> call(LoginParams params) async {
    // Validate email
    if (params.email.isEmpty) {
      return Left(ValidationFailure(
        message: 'Email is required',
        errors: {
          'email': ['Email cannot be empty']
        },
      ));
    }

    // Validate email format
    if (!_isValidEmail(params.email)) {
      return Left(ValidationFailure(
        message: 'Invalid email format',
        errors: {
          'email': ['Please enter a valid email address']
        },
      ));
    }

    // Validate password
    if (params.password.isEmpty) {
      return Left(ValidationFailure(
        message: 'Password is required',
        errors: {
          'password': ['Password cannot be empty']
        },
      ));
    }

    if (params.password.length < 6) {
      return Left(ValidationFailure(
        message: 'Password too short',
        errors: {
          'password': ['Password must be at least 6 characters']
        },
      ));
    }

    // Validate device ID
    if (params.deviceId.isEmpty) {
      return Left(ValidationFailure(
        message: 'Device ID is required',
        errors: {
          'device': ['Device identification failed']
        },
      ));
    }
    print('📱 Device ID being sent: $params.deviceId'); // ✅ أضف هذا للتأكد
    // Execute login
    return await repository.login(
      email: params.email,
      password: params.password,
      deviceId: params.deviceId,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
