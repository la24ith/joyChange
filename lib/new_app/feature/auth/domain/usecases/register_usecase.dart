// lib/features/auth/domain/usecases/register_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String phone;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });
}

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

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, RegisterResult>> call(RegisterParams params) async {
    // Validations
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

    if (params.phone.isNotEmpty && params.phone.length < 8) {
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
      passwordConfirmation: params.password,
      phone: params.phone,
    );

    return result.fold(
      (failure) => Left(failure),
      (response) => Right(RegisterResult(
        message: response.message,
        userId: response.userId,
        email: response.email,
      )),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
