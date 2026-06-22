// lib/features/drawer/data/repositories/subscription_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/data/models/user_subscription_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constant/storage_keys.dart';
import '../../domain/entities/user_subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_ds.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  // ✅ مفتاح تخزين الاشتراك في Hive
  static const String _cacheKey = 'cached_subscription';

  SubscriptionRepositoryImpl({required this.remoteDataSource});

  // ✅ Helper: الوصول لـ Box التخزين
  Box get _box => Hive.box(StorageKeys.postsBox); // استخدم نفس الـ Box الموجود

  @override
  Future<Either<Failure, UserSubscription>> getUserSubscription() async {
    try {
      final subscription = await remoteDataSource.getUserSubscription();
      return Right(subscription.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to load subscription: ${e.toString()}',
      ));
    }
  }

  @override
  Stream<UserSubscription> watchUserSubscription() {
    return remoteDataSource
        .watchUserSubscription()
        .map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Logout failed: ${e.toString()}',
      ));
    }
  }

  // ✅ جلب الاشتراك المخزّن محلياً — يعمل بدون إنترنت
  @override
  Future<Either<Failure, UserSubscription>?> getCachedSubscription() async {
    try {
      final cached = _box.get(_cacheKey);
      if (cached == null) return null;

      // تحويل البيانات المخزنة إلى Map<String, dynamic>
      final Map<String, dynamic> json = {};
      if (cached is Map) {
        cached.forEach((key, value) {
          json[key.toString()] = value;
        });
      }

      // ✅ غيّر UserSubscriptionModel لاسم الـ Model الصحيح عندك
      final subscription = UserSubscriptionModel.fromJson(json).toEntity();
      return Right(subscription);
    } catch (e) {
      debugPrint('getCachedSubscription error: $e');
      return null; // لا Cache = أرجع null وليس خطأ
    }
  }

  // ✅ حفظ الاشتراك محلياً بعد كل تحميل ناجح
  @override
  Future<void> cacheSubscription(UserSubscription subscription) async {
    try {
      // ✅ غيّر UserSubscriptionModel لاسم الـ Model الصحيح عندك
      final model = UserSubscriptionModel.fromEntity(subscription);
      await _box.put(_cacheKey, model.toJson());
    } catch (e) {
      debugPrint('cacheSubscription error: $e');
      // فشل الحفظ لا يوقف التطبيق
    }
  }

  // ✅ مسح الـ Cache عند تسجيل الخروج
  @override
  Future<void> clearCachedSubscription() async {
    try {
      await _box.delete(_cacheKey);
    } catch (e) {
      debugPrint('clearCachedSubscription error: $e');
    }
  }
}
