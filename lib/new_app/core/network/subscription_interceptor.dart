// lib/core/network/subscription_interceptor.dart

import 'package:dio/dio.dart';
import 'package:joy_of_change_v3/new_app/core/errors/exceptions.dart';

class SubscriptionInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check subscription status in every response
    if (response.data is Map) {
      final data = response.data as Map;

      // Check if response contains subscription status
      if (data.containsKey('data') && data['data'] is Map) {
        final innerData = data['data'] as Map;

        if (innerData.containsKey('active') && innerData['active'] == false) {
          // Subscription is inactive, throw exception
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              error: SubscriptionExpiredException(
                message: 'Your subscription has expired.',
                statusCode: response.statusCode,
              ),
            ),
          );
        }
      }

      // Check for subscription expired message in response
      final message = data['message']?.toString().toLowerCase() ?? '';
      if (message.contains('subscription') &&
          (data['success'] == false ||
              data['code'] == 'SUBSCRIPTION_EXPIRED')) {
        return handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            error: SubscriptionExpiredException(
              message: data['message'] ?? 'Subscription expired.',
              statusCode: response.statusCode,
            ),
          ),
        );
      }
    }

    handler.next(response);
  }
}
