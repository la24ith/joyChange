// lib/core/network/subscription_interceptor.dart

import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

class SubscriptionInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data == null || response.data is! Map) {
      handler.next(response);
      return;
    }

    final data = response.data as Map;
    final success = data['success'] ?? false;
    final code = data['code'] as String?;
    final message = data['message'] as String?;

    if (code == 'SUBSCRIPTION_INACTIVE' ||
        (message?.toLowerCase().contains('subscription') == true && !success)) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          error: SubscriptionExpiredException(
            message: message ?? 'Your subscription has expired',
          ),
        ),
      );
      return;
    }

    handler.next(response);
  }
}
