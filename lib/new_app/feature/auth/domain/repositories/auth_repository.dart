// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/user.dart';
import '../../data/models/login_response_model.dart';
import '../../data/models/auth_state_model.dart';

/// Response from register
// lib/features/auth/domain/repositories/auth_repository.dart

class RegisterResponse {
  final String message;
  final int userId;
  final String email;

  const RegisterResponse({
    required this.message,
    required this.userId,
    required this.email,
  });
}

/// Abstract repository interface
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, LoginResponseModel>> login({
    required String email,
    required String password,
    required String deviceId,
  });

  /// Register new user
  Future<Either<Failure, RegisterResponse>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
  });

  /// Check subscription status
  Future<Either<Failure, bool>> checkSubscriptionStatus(String email);

  /// Check if session is valid
  Future<Either<Failure, bool>> isSessionValid();

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Clear local data
  Future<void> clearLocalAuthData();

  /// Save token
  Future<void> saveToken(String token);

  /// Save user
  Future<void> saveUser(User user);

  /// Get stored token
  Future<String?> getStoredToken();

  /// Get stored user
  Future<User?> getStoredUser();

  /// Check authentication state (subscription + device approval)
  /// Returns AuthStateModel with current state: NEEDS_SUBSCRIPTION, DEVICE_PENDING_APPROVAL, ACTIVE
  Future<Either<Failure, AuthStateModel>> checkAuthState({
    required String email,
    required String deviceId,
    String? password,
  });
}
