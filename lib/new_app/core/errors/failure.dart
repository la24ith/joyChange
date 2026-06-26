// lib/core/errors/failures.dart

import 'package:equatable/equatable.dart';

/// Abstract class for all failures in the app
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Server related failures (5xx, 4xx except auth)
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.statusCode});
}

/// Cache/storage related failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.statusCode});
}

/// Authentication failures (invalid token, expired token)
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

/// Subscription expired or inactive
class SubscriptionExpiredFailure extends Failure {
  const SubscriptionExpiredFailure({required super.message, super.statusCode});

  factory SubscriptionExpiredFailure.fromApi() {
    return const SubscriptionExpiredFailure(
      message: 'Your subscription has expired. Please contact admin.',
      statusCode: 403,
    );
  }
}

/// Device not allowed (multiple device login)
class DeviceNotAllowedFailure extends Failure {
  const DeviceNotAllowedFailure({required super.message, super.statusCode});

  factory DeviceNotAllowedFailure.fromApi() {
    return const DeviceNotAllowedFailure(
      message: 'This account is logged in on another device.',
      statusCode: 403,
    );
  }
}

/// Session expired (token expired or invalid)
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure({required super.message, super.statusCode});

  factory SessionExpiredFailure.fromApi() {
    return const SessionExpiredFailure(
      message: 'Session expired. Please login again.',
      statusCode: 401,
    );
  }
}

/// Validation failures (form validation)
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    required super.message,
    this.errors,
    super.statusCode,
  });
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.statusCode});
}

class PendingSubscriptionFailure extends Failure {
  final String email;
  final int userId;
  final String password;

  const PendingSubscriptionFailure({
    required super.message,
    required this.email,
    required this.userId,
    this.password = '',
  });
}

class PendingDeviceFailure extends Failure {
  final String email;
  final String password;
  final String deviceId;

  const PendingDeviceFailure({
    required super.message,
    required this.email,
    required this.password,
    required this.deviceId,
  });
}
