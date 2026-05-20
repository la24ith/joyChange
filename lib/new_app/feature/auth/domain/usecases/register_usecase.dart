// lib/features/auth/domain/usecases/register_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../repositories/auth_repository.dart';

/// Input parameters for registration
class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String phone;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.phone,
  });
}

/// Result of registration (contains userId for pending activation)
class RegisterResult {
  final String message;
  final int userId;
  final String email;

  const RegisterResult({
    required this.message,
    required this.userId,
    required this.email,
  });
}

/// Use case for user registration
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  /// Execute registration with given parameters
  /// Returns RegisterResult on success, [Failure] on error
  Future<Either<Failure, RegisterResult>> call(RegisterParams params) async {
    // Validate name
    if (params.name.isEmpty) {
      return Left(ValidationFailure(
        message: 'Name is required',
        errors: {
          'name': ['Please enter your full name']
        },
      ));
    }

    if (params.name.length < 3) {
      return Left(ValidationFailure(
        message: 'Name too short',
        errors: {
          'name': ['Name must be at least 3 characters']
        },
      ));
    }

    // Validate email
    if (params.email.isEmpty) {
      return Left(ValidationFailure(
        message: 'Email is required',
        errors: {
          'email': ['Email cannot be empty']
        },
      ));
    }

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

    // Validate password confirmation
    if (params.password != params.passwordConfirmation) {
      return Left(ValidationFailure(
        message: 'Password confirmation does not match',
        errors: {
          'password_confirmation': ['Passwords do not match']
        },
      ));
    }

    // Validate phone (optional but if provided should be valid)
    if (params.phone.isNotEmpty && params.phone.length < 10) {
      return Left(ValidationFailure(
        message: 'Invalid phone number',
        errors: {
          'phone': ['Please enter a valid phone number']
        },
      ));
    }

    // Execute registration
    final result = await repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
      phone: params.phone,
    );

    // Transform the result to include userId
    return result.fold(
      (failure) => Left(failure),
      (response) {
        // response contains message and user data
        return Right(RegisterResult(
          message: response.message,
          userId: response.userId,
          email: params.email,
        ));
      },
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
