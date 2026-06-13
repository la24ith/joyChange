// lib/features/auth/domain/usecases/check_session_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class CheckSessionUseCase {
  final AuthRepository repository;

  CheckSessionUseCase(this.repository);

  Future<Either<Failure, User>> call() async {
    // ✅ محاولة استرجاع token من التخزين المحلي
    final token = await repository.getStoredToken();

    if (token == null || token.isEmpty) {
      print('🔐 No stored token found');
      return Left(SessionExpiredFailure(
        message: 'No session found. Please login.',
      ));
    }

    print('✅ Stored token found: ${token.substring(0, 20)}...');

    // ✅ محاولة استرجاع المستخدم من التخزين المحلي
    final user = await repository.getStoredUser();

    if (user == null) {
      print('❌ No stored user found');
      return Left(SessionExpiredFailure(
        message: 'User data not found. Please login again.',
      ));
    }

    print('✅ Stored user found: ${user.email}');

    // ✅ التحقق من صلاحية الاشتراك (اختياري)
    try {
      final subscriptionResult =
          await repository.checkSubscriptionStatus(user.email);

      return subscriptionResult.fold(
        (failure) {
          print('⚠️ Subscription check failed: ${failure.message}');
          // في حال فشل التحقق، نعتبر المستخدم مسجلاً دخول
          return Right(user);
        },
        (isActive) {
          if (isActive) {
            print('✅ Subscription is active');
            return Right(user);
          } else {
            print('❌ Subscription is inactive');
            return Left(SubscriptionExpiredFailure(
              message: 'Your subscription has expired. Please contact support.',
            ));
          }
        },
      );
    } catch (e) {
      print('⚠️ Error checking subscription: $e');
      return Right(user);
    }
  }
}
