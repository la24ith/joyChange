// lib/core/network/error_interceptor.dart

import 'package:dio/dio.dart';
import 'package:joy_of_change_v3/new_app/core/errors/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle network errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: NetworkException(
            message: 'Network error. Please check your connection.',
          ),
        ),
      );
    }

    // Handle HTTP status codes
    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      final data = err.response!.data;

      switch (statusCode) {
        case 400:
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: BadRequestException(
                message: _extractErrorMessage(data),
                statusCode: statusCode,
                errors: _extractValidationErrors(data),
              ),
            ),
          );

        case 401:
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: UnauthorizedException(
                message: 'Session expired. Please login again.',
                statusCode: statusCode,
              ),
            ),
          );

        case 403:
          // Check if it's subscription or device related
          final message = _extractErrorMessage(data).toLowerCase();
          if (message.contains('subscription') ||
              (data?['data']?['active'] == false)) {
            return handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                error: SubscriptionExpiredException(
                  message: 'Your subscription has expired.',
                  statusCode: statusCode,
                ),
              ),
            );
          } else if (message.contains('device') ||
              message.contains('another device')) {
            return handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                error: DeviceNotAllowedException(
                  message: 'This account is logged in on another device.',
                  statusCode: statusCode,
                ),
              ),
            );
          }
          return handler.reject(err);

        case 404:
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: NotFoundException(
                message: 'Resource not found.',
                statusCode: statusCode,
              ),
            ),
          );

        case 500:
        case 502:
        case 503:
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: ServerException(
                message: 'Server error. Please try again later.',
                statusCode: statusCode,
              ),
            ),
          );

        default:
          return handler.reject(err);
      }
    }

    handler.next(err);
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map) {
      return data['message'] ?? data['error'] ?? 'An error occurred';
    }
    return 'An error occurred';
  }

  Map<String, List<String>>? _extractValidationErrors(dynamic data) {
    if (data is Map && data['errors'] is Map) {
      final errors = <String, List<String>>{};
      (data['errors'] as Map).forEach((key, value) {
        if (value is List) {
          errors[key] = List<String>.from(value);
        } else if (value is String) {
          errors[key] = [value];
        }
      });
      return errors;
    }
    return null;
  }
}
