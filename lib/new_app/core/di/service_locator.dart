// lib/core/di/service_locator.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/data/datasources/auth_local_ds.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/data/datasources/auth_remote_ds.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/repositories/auth_repository.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/check_session_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/check_subscription_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/login_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/logout_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/register_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/bloc/auth_bloc.dart';
import '../network/dio_client.dart';
import '../storage/hive_service.dart';
import '../storage/secure_storage.dart';
import '../utils/device_info.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ============================================================================
  // Core Services (Singleton)
  // ============================================================================

  // Secure Storage
  getIt.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());
  getIt.registerLazySingleton<SecureStorageService>(
      () => SecureStorageService());

  // Hive Service
  getIt.registerLazySingleton<HiveService>(() => HiveService.instance);

  // Device Info
  getIt.registerLazySingleton<DeviceInfoUtil>(
    () => DeviceInfoUtil(
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );

  // Dio Client
  getIt.registerLazySingleton<DioClient>(() => DioClient.instance);

  // Initialize Hive
  await getIt<HiveService>().init();

  // Open user box for caching
  if (!Hive.isBoxOpen('user_box')) {
    await Hive.openBox('user_box');
  }
  final userBox = Hive.box('user_box');

  // ============================================================================
  // Auth Data Layer
  // ============================================================================

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(
      secureStorage: getIt<SecureStorageService>(),
      userBox: userBox,
    ),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // ============================================================================
  // Auth Domain Layer (Use Cases)
  // ============================================================================

  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<CheckSessionUseCase>(
    () => CheckSessionUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<CheckSubscriptionUseCase>(
    () => CheckSubscriptionUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<AuthRepository>()),
  );

  // ============================================================================
  // Auth Presentation Layer (BLoC)
  // ============================================================================

  // ✅ تأكد من تسجيل AuthBloc بشكل صحيح
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepository>(),
      deviceInfoUtil: getIt<DeviceInfoUtil>(),
      checkSubscriptionUseCase: getIt<CheckSubscriptionUseCase>(),
    ),
  );

  // ============================================================================
  // طباعة للتأكد من التسجيل
  // ============================================================================

  print('✅ Service Locator initialized successfully');
  print('✅ AuthBloc registered: ${getIt.isRegistered<AuthBloc>()}');
  print('✅ AuthRepository registered: ${getIt.isRegistered<AuthRepository>()}');
}

/// Helper to reset service locator (useful for testing)
void resetServiceLocator() {
  getIt.reset();
}
