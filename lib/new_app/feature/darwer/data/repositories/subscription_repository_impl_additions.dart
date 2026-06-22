// lib/features/drawer/data/repositories/subscription_repository_impl.dart
// ✅ مثال على تطبيق الـ Cache في الـ Repository
// أضف هذه الدوال إلى الـ Implementation الحالية لديك

// في الـ class الحالية أضف:

// ✅ مفتاح الـ Hive لتخزين بيانات الاشتراك
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/data/models/user_subscription_model.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/domain/entities/user_subscription.dart';

const String _cacheKey = 'cached_subscription';

@override
Future<Either<Failure, UserSubscription>?> getCachedSubscription() async {
  try {
    final box = Hive.box(StorageKeys.userBox); // أو أي Box تستخدمه
    final cached = box.get(_cacheKey);
    if (cached == null) return null;

    // تحويل البيانات المخزنة إلى Map
    final Map<String, dynamic> json = {};
    if (cached is Map) {
      cached.forEach((key, value) {
        json[key.toString()] = value;
      });
    }

    final subscription = UserSubscriptionModel.fromJson(json).toEntity();
    return Right(subscription);
  } catch (e) {
    return null; // لا Cache = أرجع null (ليس خطأ)
  }
}

@override
Future<void> cacheSubscription(UserSubscription subscription) async {
  try {
    final box = Hive.box(StorageKeys.userBox);
    final model = UserSubscriptionModel.fromEntity(subscription);
    await box.put(_cacheKey, model.toJson());
  } catch (e) {
    // فشل الحفظ = تجاهل بصمت (لا يوقف التطبيق)
    debugPrint('Failed to cache subscription: $e');
  }
}

@override
Future<void> clearCachedSubscription() async {
  try {
    final box = Hive.box(StorageKeys.userBox);
    await box.delete(_cacheKey);
  } catch (e) {
    debugPrint('Failed to clear subscription cache: $e');
  }
}
