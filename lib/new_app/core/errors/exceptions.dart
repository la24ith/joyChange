// lib/core/errors/exceptions.dart

/// Base exception class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException({required super.message, super.statusCode});
}

/// Server error (5xx)
class ServerException extends AppException {
  ServerException({required super.message, super.statusCode});
}

/// Bad request (400)
class BadRequestException extends AppException {
  final Map<String, List<String>>? errors;

  BadRequestException({
    required super.message,
    super.statusCode,
    this.errors,
  });
}

/// Unauthorized (401)
class UnauthorizedException extends AppException {
  UnauthorizedException({required super.message, super.statusCode});
}

/// Forbidden (403) - General
class ForbiddenException extends AppException {
  ForbiddenException({required super.message, super.statusCode});
}

/// Subscription expired (403 with subscription context)

/// Device not allowed (403 with device context)
class DeviceNotAllowedException extends AppException {
  DeviceNotAllowedException({required super.message, super.statusCode});
}

/// Not found (404)
class NotFoundException extends AppException {
  NotFoundException({required super.message, super.statusCode});
}

/// Cache exception
class CacheException extends AppException {
  CacheException({required super.message, super.statusCode});
}

/// Unknown exception
class UnknownException extends AppException {
  UnknownException({required super.message, super.statusCode});
}

class SubscriptionExpiredException implements Exception {
  final String message;

  SubscriptionExpiredException({required this.message});
}
