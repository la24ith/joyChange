// lib/new_app/core/di/service_locator.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';
import 'package:joy_of_change_v3/new_app/core/services/notification_scheduler_service.dart';
import 'package:joy_of_change_v3/new_app/core/services/notification_sync_service.dart';
import 'package:joy_of_change_v3/new_app/feature/ads/data/datasources/ads_remote_ds.dart';
import 'package:joy_of_change_v3/new_app/feature/ads/data/repositories/ads_repository_impl.dart';
import 'package:joy_of_change_v3/new_app/feature/ads/domain/repositories/ads_repository.dart';
import 'package:joy_of_change_v3/new_app/feature/ads/domain/usecases/get_active_ads_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/ads/domain/usecases/register_click_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/ads/presentation/bloc/ads_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/data/datasources/auth_local_ds.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/data/datasources/auth_remote_ds.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/repositories/auth_repository.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/check_auth_state_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/check_session_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/check_subscription_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/login_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/logout_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/register_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/update_profile_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/data/datasources/daily_commitment_local_ds.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/data/datasources/daily_commitment_remote_ds.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/data/repositories/daily_commitment_repository_impl.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/repositories/aily_commitment_repository.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/usecases/get_answer_history_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/usecases/get_local_data_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/usecases/get_stats_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/usecases/get_today_question_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/usecases/save_local_data_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/usecases/save_pending_answer_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/usecases/submit_answer_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/usecases/sync_pending_answers_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/presentation/bloc/daily_commitment_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/data/datasources/subscription_remote_ds.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/data/repositories/subscription_repository_impl.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/domain/repositories/subscription_repository.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/presentation/bloc/drawer_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/home/data/datasources/home_local_ds.dart';
import 'package:joy_of_change_v3/new_app/feature/home/data/datasources/home_remote_ds.dart';
import 'package:joy_of_change_v3/new_app/feature/home/data/repositories/home_repository_impl.dart';
import 'package:joy_of_change_v3/new_app/feature/home/domain/repositories/home_repository.dart';
import 'package:joy_of_change_v3/new_app/feature/home/domain/usecases/get_posts_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/home/presentation/bloc/home_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/post_details/data/datasources/post_remote_ds.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/data/datasources/weight_local_ds.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/data/datasources/weight_remote_ds.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/data/repositories/weight_repository_impl.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/repositories/weight_repository.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/usecases/add_weight_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/usecases/get_ideal_weight_status_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/usecases/get_weight_chart_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/usecases/get_weight_stats_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/usecases/get_weights_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/presentation/bloc/weight_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/datasource/notification_api_service.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/datasource/notification_local_data_source.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/datasource/notification_local_data_source_impl.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/notification_hive_model.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/repository/notification_repository_impl.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/domain/entities/repository/notification_repository.dart';
import '../network/dio_client.dart';
import '../storage/hive_service.dart';
import '../storage/secure_storage.dart';
import '../utils/device_info.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  debugPrint('🔄 Starting Service Locator setup...');

  // ============================================================================
  // ✅ 1. تهيئة SharedPreferences أولاً
  // ============================================================================
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  debugPrint('✅ SharedPreferences registered');

  // ============================================================================
  // ✅ 2. Core Services (Singleton)
  // ============================================================================

  getIt.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());
  getIt.registerLazySingleton<SecureStorageService>(
      () => SecureStorageService());
  getIt.registerLazySingleton<HiveService>(() => HiveService.instance);
  getIt.registerLazySingleton<DeviceInfoUtil>(
    () => DeviceInfoUtil(secureStorage: getIt<FlutterSecureStorage>()),
  );
  getIt.registerLazySingleton<DioClient>(() => DioClient.instance);
  debugPrint('✅ Core services registered');

  // ============================================================================
  // ✅ 3. تهيئة HiveService - THIS IS THE ONLY PLACE WHERE Hive.initFlutter() IS CALLED
  // ============================================================================
  try {
    await getIt<HiveService>().init();
    debugPrint('✅ HiveService initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing HiveService: $e');
    // ✅ محاولة فتح الصناديق بشكل يدوي في حالة الفشل
    debugPrint('🔄 Attempting to open boxes manually...');
    await _openBoxesManually();
  }

  // ✅ الحصول على مراجع الصناديق - فقط نستخدم Hive.box() لأن HiveService فتحها بالفعل
  Box userBox;
  Box<NotificationHiveModel> notificationBox;

  try {
    userBox = Hive.box('user_box');
    debugPrint('✅ user_box retrieved');
  } catch (e) {
    debugPrint('⚠️ user_box not open, opening now...');
    userBox = await Hive.openBox('user_box');
    debugPrint('✅ user_box opened');
  }

  try {
    notificationBox =
        Hive.box<NotificationHiveModel>(StorageKeys.notificationsBox);
    debugPrint('✅ notification_box retrieved');
  } catch (e) {
    debugPrint('⚠️ Notification box not open, opening now...');
    notificationBox =
        await Hive.openBox<NotificationHiveModel>(StorageKeys.notificationsBox);
    debugPrint('✅ notification_box opened');
  }

  // ============================================================================
  // ✅ 4. Auth Data Layer
  // ============================================================================

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(dioClient: getIt<DioClient>()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(
        secureStorage: getIt<SecureStorageService>(), userBox: userBox),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );
  debugPrint('✅ Auth layer registered');

  // ============================================================================
  // ✅ 5. Auth Domain Layer
  // ============================================================================

  getIt.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<CheckSessionUseCase>(
      () => CheckSessionUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<CheckSubscriptionUseCase>(
      () => CheckSubscriptionUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<CheckAuthStateUseCase>(
    () => CheckAuthStateUseCase(getIt<AuthRepository>()),
  );
  debugPrint('✅ Auth usecases registered');

  // ============================================================================
  // ✅ 6. Auth Presentation Layer
  // ============================================================================

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepository>(),
      deviceInfoUtil: getIt<DeviceInfoUtil>(),
      checkSubscriptionUseCase: getIt<CheckSubscriptionUseCase>(),
      checkSessionUseCase: getIt<CheckSessionUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
    ),
  );
  debugPrint('✅ AuthBloc registered');

  // ============================================================================
  // ✅ 7. Home Feature
  // ============================================================================

  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSource(),
  );

  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: getIt<HomeRemoteDataSource>(),
      localDataSource: getIt<HomeLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetPostsUseCase>(
      () => GetPostsUseCase(getIt<HomeRepository>()));
  getIt.registerFactory<HomeBloc>(
      () => HomeBloc(getPostsUseCase: getIt<GetPostsUseCase>()));
  debugPrint('✅ Home feature registered');

  // ============================================================================
  // ✅ 8. Post Details Feature
  // ============================================================================

  getIt.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSource(dioClient: getIt<DioClient>()),
  );
  debugPrint('✅ Post details feature registered');

  // ============================================================================
  // ✅ 9. Daily Commitment Feature
  // ============================================================================

  // Initialize Local Data Source
  await DailyCommitmentLocalDataSource.instance.init();

  getIt.registerLazySingleton<DailyCommitmentRemoteDataSource>(
    () => DailyCommitmentRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<DailyCommitmentLocalDataSource>(
    () => DailyCommitmentLocalDataSource.instance,
  );

  getIt.registerLazySingleton<DailyCommitmentRepository>(
    () => DailyCommitmentRepositoryImpl(
      remoteDataSource: getIt<DailyCommitmentRemoteDataSource>(),
      localDataSource: getIt<DailyCommitmentLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetTodayQuestionUseCase>(
    () => GetTodayQuestionUseCase(getIt<DailyCommitmentRepository>()),
  );

  getIt.registerLazySingleton<GetStatsUseCase>(
    () => GetStatsUseCase(getIt<DailyCommitmentRepository>()),
  );

  getIt.registerLazySingleton<GetAnswerHistoryUseCase>(
    () => GetAnswerHistoryUseCase(getIt<DailyCommitmentRepository>()),
  );

  getIt.registerLazySingleton<SubmitAnswerUseCase>(
    () => SubmitAnswerUseCase(getIt<DailyCommitmentRepository>()),
  );

  getIt.registerLazySingleton<GetLocalDataUseCase>(
    () => GetLocalDataUseCase(getIt<DailyCommitmentRepository>()),
  );

  getIt.registerLazySingleton<SaveLocalDataUseCase>(
    () => SaveLocalDataUseCase(getIt<DailyCommitmentRepository>()),
  );

  getIt.registerLazySingleton<SavePendingAnswerUseCase>(
    () => SavePendingAnswerUseCase(getIt<DailyCommitmentRepository>()),
  );

  getIt.registerLazySingleton<SyncPendingAnswersUseCase>(
    () => SyncPendingAnswersUseCase(getIt<DailyCommitmentRepository>()),
  );

  getIt.registerFactory<DailyCommitmentBloc>(
    () => DailyCommitmentBloc(
      getStatsUseCase: getIt<GetStatsUseCase>(),
      getAnswerHistoryUseCase: getIt<GetAnswerHistoryUseCase>(),
      submitAnswerUseCase: getIt<SubmitAnswerUseCase>(),
      getLocalDataUseCase: getIt<GetLocalDataUseCase>(),
      saveLocalDataUseCase: getIt<SaveLocalDataUseCase>(),
      savePendingAnswerUseCase: getIt<SavePendingAnswerUseCase>(),
      syncPendingAnswersUseCase: getIt<SyncPendingAnswersUseCase>(),
    ),
  );
  debugPrint('✅ Daily Commitment feature registered');

  // ============================================================================
  // ✅ 10. Ads Feature
  // ============================================================================

  getIt.registerLazySingleton<AdsRemoteDataSource>(
    () => AdsRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<AdsRepository>(
    () => AdsRepositoryImpl(remoteDataSource: getIt<AdsRemoteDataSource>()),
  );

  getIt.registerLazySingleton<GetActiveAdsUseCase>(
    () => GetActiveAdsUseCase(getIt<AdsRepository>()),
  );

  getIt.registerLazySingleton<RegisterClickUseCase>(
    () => RegisterClickUseCase(getIt<AdsRepository>()),
  );

  getIt.registerFactory<AdsBloc>(
    () => AdsBloc(
      getActiveAdsUseCase: getIt<GetActiveAdsUseCase>(),
      registerClickUseCase: getIt<RegisterClickUseCase>(),
    ),
  );
  debugPrint('✅ Ads feature registered');

  // ============================================================================
  // ✅ 11. Weight Tracking Feature
  // ============================================================================

  getIt.registerLazySingleton<WeightLocalDataSource>(
    () => WeightLocalDataSource(getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<WeightRemoteDataSource>(
    () => WeightRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<WeightRepository>(
    () => WeightRepositoryImpl(
      remoteDataSource: getIt<WeightRemoteDataSource>(),
      localDataSource: getIt<WeightLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetWeightsUseCase>(
    () => GetWeightsUseCase(getIt<WeightRepository>()),
  );

  getIt.registerLazySingleton<GetWeightStatsUseCase>(
    () => GetWeightStatsUseCase(getIt<WeightRepository>()),
  );

  getIt.registerLazySingleton<GetWeightChartUseCase>(
    () => GetWeightChartUseCase(getIt<WeightRepository>()),
  );

  getIt.registerLazySingleton<GetIdealWeightStatusUseCase>(
    () => GetIdealWeightStatusUseCase(getIt<WeightRepository>()),
  );

  getIt.registerLazySingleton<AddWeightUseCase>(
    () => AddWeightUseCase(getIt<WeightRepository>()),
  );

  getIt.registerFactory<WeightBloc>(
    () => WeightBloc(
      getWeightsUseCase: getIt<GetWeightsUseCase>(),
      getWeightStatsUseCase: getIt<GetWeightStatsUseCase>(),
      getWeightChartUseCase: getIt<GetWeightChartUseCase>(),
      getIdealWeightStatusUseCase: getIt<GetIdealWeightStatusUseCase>(),
      addWeightUseCase: getIt<AddWeightUseCase>(),
    ),
  );
  debugPrint('✅ Weight Tracking feature registered');

  // ============================================================================
  // ✅ 12. Notifications Feature
  // ============================================================================

  getIt.registerLazySingleton<NotificationApiService>(
    () => NotificationApiService(
      getIt<DioClient>().dio,
      dioClient: getIt<DioClient>(),
    ),
  );

  getIt.registerLazySingleton<NotificationLocalDataSource>(
    () => NotificationLocalDataSourceImpl(notificationBox),
  );

  getIt.registerLazySingleton<NotificationSchedulerService>(
    () => NotificationSchedulerService(FlutterLocalNotificationsPlugin()),
  );

  getIt.registerLazySingleton<NotificationSyncService>(
    () => NotificationSyncService(
      getIt<NotificationApiService>(),
      getIt<NotificationLocalDataSource>(),
      getIt<NotificationSchedulerService>(),
    ),
  );

  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      api: getIt<NotificationApiService>(),
      local: getIt<NotificationLocalDataSource>(),
      syncService: getIt<NotificationSyncService>(),
      scheduler: getIt<NotificationSchedulerService>(),
    ),
  );

  getIt.registerFactory<NotificationBloc>(
    () => NotificationBloc(getIt<NotificationRepository>()),
  );
  debugPrint('✅ Notifications feature registered');

  // ============================================================================
  // ✅ 13. Drawer Feature
  // ============================================================================

  getIt.registerLazySingleton<SubscriptionRemoteDataSource>(
    () => SubscriptionRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      remoteDataSource: getIt<SubscriptionRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<DrawerBloc>(
    () => DrawerBloc(
      subscriptionRepository: getIt<SubscriptionRepository>(),
    ),
  );
  debugPrint('✅ Drawer feature registered');

  debugPrint('✅ Service Locator initialized successfully!');
}

// ============================================================================
// ✅ Helper Functions
// ============================================================================

Future<void> _openBoxesManually() async {
  debugPrint('🔄 Opening boxes manually...');
  try {
    if (!Hive.isBoxOpen('user_box')) {
      await Hive.openBox('user_box');
      debugPrint('✅ user_box opened manually');
    }
  } catch (e) {
    debugPrint('❌ Error opening user_box manually: $e');
  }

  try {
    if (!Hive.isBoxOpen('posts_box')) {
      await Hive.openBox('posts_box');
      debugPrint('✅ posts_box opened manually');
    }
  } catch (e) {
    debugPrint('❌ Error opening posts_box manually: $e');
  }

  try {
    if (!Hive.isBoxOpen(StorageKeys.notificationsBox)) {
      await Hive.openBox<NotificationHiveModel>(StorageKeys.notificationsBox);
      debugPrint('✅ notifications_box opened manually');
    }
  } catch (e) {
    debugPrint('❌ Error opening notifications_box manually: $e');
  }

  try {
    if (!Hive.isBoxOpen(StorageKeys.weightsBox)) {
      await Hive.openBox(StorageKeys.weightsBox);
      debugPrint('✅ weights_box opened manually');
    }
  } catch (e) {
    debugPrint('❌ Error opening weights_box manually: $e');
  }

  try {
    if (!Hive.isBoxOpen(StorageKeys.dailyCommitmentBox)) {
      await Hive.openBox(StorageKeys.dailyCommitmentBox);
      debugPrint('✅ dailyCommitment_box opened manually');
    }
  } catch (e) {
    debugPrint('❌ Error opening dailyCommitment_box manually: $e');
  }

  try {
    if (!Hive.isBoxOpen(StorageKeys.syncQueueBox)) {
      await Hive.openBox(StorageKeys.syncQueueBox);
      debugPrint('✅ syncQueue_box opened manually');
    }
  } catch (e) {
    debugPrint('❌ Error opening syncQueue_box manually: $e');
  }
}

void resetServiceLocator() {
  getIt.reset();
  debugPrint('🔄 Service Locator reset');
}
