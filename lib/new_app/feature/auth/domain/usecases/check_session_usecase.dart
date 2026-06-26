// lib/features/auth/domain/usecases/check_session_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_theme.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import 'package:joy_of_change_v3/new_app/core/di/service_locator.dart';
import 'package:joy_of_change_v3/new_app/core/storage/secure_storage.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/entities/user.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/repositories/auth_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CheckSessionUseCase {
  final AuthRepository repository;

  CheckSessionUseCase(this.repository);

  Future<Either<Failure, CheckSessionResult>> call() async {
    // ✅ أولاً: التحقق من الاتصال بالإنترنت
    final connectivityResult = await Connectivity().checkConnectivity();
    final isConnected = connectivityResult != ConnectivityResult.none;

    // ✅ ثانياً: الحصول على البيانات المحفوظة
    final token = await repository.getStoredToken();
    final user = await repository.getStoredUser();
    if (token == null || token.isEmpty) {
      final pendingState = await repository.getPendingState();
      if (pendingState != null) {
        final state = pendingState['state'];
        final email = pendingState['email'] ?? '';
        final userIdStr = pendingState['userId'];
        final password = pendingState['password'] ?? '';
        final deviceId = pendingState['deviceId'] ?? '';

        print('📱 Found pending state: $state for $email');

        if (state == 'PENDING_SUBSCRIPTION') {
          return Left(PendingSubscriptionFailure(
            message: 'في انتظار تفعيل الاشتراك',
            email: email,
            userId: int.tryParse(userIdStr ?? '0') ?? 0,
            password: password,
          ));
        } else if (state == 'PENDING_DEVICE') {
          return Left(PendingDeviceFailure(
            message: 'في انتظار تفعيل الجهاز',
            email: email,
            password: password,
            deviceId: deviceId,
          ));
        }
      }

      // لا يوجد token ولا pending state
      return Left(SessionExpiredFailure(
        message: 'No session found. Please login.',
      ));
    }
    // ✅ إذا كان هناك توكن ومستخدم محفوظ
    if (token != null && token.isNotEmpty && user != null) {
      // ✅ التحقق من اكتمال البروفايل من التخزين المحلي
      final isProfileComplete = await _isProfileCompleteLocally(user);

      // ✅ إذا لم يكن هناك اتصال، استخدم البيانات المحفوظة مباشرة
      if (!isConnected) {
        print('📱 Offline mode: Using cached session');
        return Right(CheckSessionResult(
          user: user,
          isProfileComplete: isProfileComplete,
        ));
      }

      // ✅ يوجد اتصال - تحقق من صحة الجلسة مع السيرفر
      try {
        final subscriptionResult =
            await repository.checkSubscriptionStatus(user.email);

        return subscriptionResult.fold(
          (failure) {
            if (failure is SubscriptionExpiredFailure) {
              repository.clearLocalAuthData();
              return Left(failure); // ✅ → صفحة انتهاء الاشتراك
            }
            // ServerFailure أو NetworkFailure → cached data
            print('⚠️ UseCase: Non-subscription failure, using cached');
            return Right(CheckSessionResult(
              user: user,
              isProfileComplete: isProfileComplete,
            ));
          },
          (isActive) {
            if (isActive) {
              return Right(CheckSessionResult(
                user: user,
                isProfileComplete: isProfileComplete,
              ));
            } else {
              repository.clearLocalAuthData();
              return Left(SubscriptionExpiredFailure(
                message: 'Your subscription has expired.',
              ));
            }
          },
        );
      } catch (e) {
        // ✅ الحل: فرّق بين خطأ الـ subscription وأي خطأ آخر
        if (e.toString().contains('Subscription expired') ||
            AppState.subscriptionExpired) {
          repository.clearLocalAuthData();
          return Left(SubscriptionExpiredFailure(
            message: 'Your subscription has expired.',
          ));
        }
        // فقط الأخطاء الأخرى (network، timeout) تستخدم البيانات المخبأة
        print('⚠️ Network error checking session: $e, using cached data');
        return Right(CheckSessionResult(
          user: user,
          isProfileComplete: isProfileComplete,
        ));
      }
    }

    // ✅ لا توجد جلسة محفوظة
    return Left(SessionExpiredFailure(
      message: 'No session found. Please login.',
    ));
  }

  /// ✅ التحقق من اكتمال البروفايل من التخزين المحلي
  Future<bool> _isProfileCompleteLocally(User user) async {
    try {
      // 1. التحقق من وجود بيانات البروفايل
      final hasData = user.currentWeight != null &&
          user.targetWeight != null &&
          user.height != null &&
          user.patientSegment.isNotEmpty &&
          user.patientSegment != 'general' &&
          user.phone != null &&
          user.phone!.isNotEmpty;

      if (!hasData) {
        return false;
      }

      // 2. التحقق من حالة الإكمال في SecureStorage
      final secureStorage = getIt.get<SecureStorageService>();
      final profileCompleted =
          await secureStorage.read(key: 'profile_completed');

      return profileCompleted == 'true';
    } catch (e) {
      print('⚠️ Error checking profile completion: $e');
      return false;
    }
  }
}

/// ✅ نتيجة التحقق من الجلسة
class CheckSessionResult {
  final User user;
  final bool isProfileComplete;

  const CheckSessionResult({
    required this.user,
    required this.isProfileComplete,
  });
}
