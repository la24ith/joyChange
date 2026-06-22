// lib/features/drawer/domain/repositories/subscription_repository.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/user_subscription.dart';

abstract class SubscriptionRepository {
  /// جلب بيانات الاشتراك من الشبكة
  Future<Either<Failure, UserSubscription>> getUserSubscription();

  /// Stream للتحديثات الفورية
  Stream<UserSubscription> watchUserSubscription();

  /// ✅ جلب الاشتراك المخزّن محلياً (Hive) — يعمل بدون إنترنت
  Future<Either<Failure, UserSubscription>?> getCachedSubscription();

  /// ✅ حفظ الاشتراك محلياً (يُستدعى بعد كل تحميل ناجح)
  Future<void> cacheSubscription(UserSubscription subscription);

  /// ✅ مسح الـ Cache (عند تسجيل الخروج)
  Future<void> clearCachedSubscription();

  /// تسجيل الخروج
  Future<Either<Failure, void>> logout();
}
