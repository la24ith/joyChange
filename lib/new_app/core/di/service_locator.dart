import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/new_app/core/constant/hive_boxes.dart';
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
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/check_session_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/check_subscription_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/login_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/logout_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/register_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/data/datasources/daily_commitment_remote_ds.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/data/repositories/daily_commitment_repository_impl.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/repositories/aily_commitment_repository.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/usecases/get_answer_history_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/usecases/get_stats_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/usecases/get_today_question_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/usecases/submit_answer_usecase.dart';
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
  // ============================================================================
  // Core Services (Singleton)
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

  await getIt<HiveService>().init();

  if (!Hive.isBoxOpen('user_box')) {
    await Hive.openBox('user_box');
  }
  if (!Hive.isBoxOpen('posts_box')) {
    await Hive.openBox('posts_box');
  }

  final userBox = Hive.box('user_box');

  // ============================================================================
  // Auth Data Layer
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

  // ============================================================================
  // Auth Domain Layer
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

  // ============================================================================
  // Auth Presentation Layer
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

  // ============================================================================
  // Home Feature
  // ============================================================================

  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<HomeLocalDataSource>(() => HomeLocalDataSource());

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

  // ============================================================================
  // Post Details Feature
  // ============================================================================

  getIt.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  // ============================================================================
  // ✅ Weight Feature
  // ============================================================================

  // Initialize Weight Local Data Source
  /* await WeightLocalDataSource.instance.init();

  // Data Sources
  getIt.registerLazySingleton<WeightRemoteDataSource>(
    () => WeightRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<WeightLocalDataSource>(
    () => WeightLocalDataSource.instance,
  );

  // Repository
  getIt.registerLazySingleton<WeightRepository>(
    () => WeightRepositoryImpl(
      remoteDataSource: getIt<WeightRemoteDataSource>(),
      localDataSource: getIt<WeightLocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<GetWeightStatsUseCase>(
    () => GetWeightStatsUseCase(getIt<WeightRepository>()),
  );

  getIt.registerLazySingleton<GetWeightStatusUseCase>(
    () => GetWeightStatusUseCase(getIt<WeightRepository>()),
  );

  getIt.registerLazySingleton<GetWeightHistoryUseCase>(
    () => GetWeightHistoryUseCase(getIt<WeightRepository>()),
  );

  getIt.registerLazySingleton<AddWeightEntryUseCase>(
    () => AddWeightEntryUseCase(getIt<WeightRepository>()),
  );

  // ✅ Bloc
  getIt.registerFactory<WeightBloc>(
    () => WeightBloc(
      getWeightStatsUseCase: getIt<GetWeightStatsUseCase>(),
      getWeightStatusUseCase: getIt<GetWeightStatusUseCase>(),
      getWeightHistoryUseCase: getIt<GetWeightHistoryUseCase>(),
      addWeightEntryUseCase: getIt<AddWeightEntryUseCase>(),
    ),
  );*/

  // ============================================================================
  // طباعة للتأكد
  // ============================================================================

  print('✅ Service Locator initialized');

  getIt.registerLazySingleton<DailyCommitmentRemoteDataSource>(
    () => DailyCommitmentRemoteDataSource(dioClient: getIt<DioClient>()),
  );

// Repository
  getIt.registerLazySingleton<DailyCommitmentRepository>(
    () => DailyCommitmentRepositoryImpl(
      remoteDataSource: getIt<DailyCommitmentRemoteDataSource>(),
    ),
  );

// Use Cases
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

// BLoC
  getIt.registerFactory<DailyCommitmentBloc>(
    () => DailyCommitmentBloc(
      getStatsUseCase: getIt<GetStatsUseCase>(),
      getAnswerHistoryUseCase: getIt<GetAnswerHistoryUseCase>(),
      submitAnswerUseCase: getIt<SubmitAnswerUseCase>(),
    ),
  );

// ============================================================================

// Data Sources
  getIt.registerLazySingleton<AdsRemoteDataSource>(
    () => AdsRemoteDataSource(dioClient: getIt<DioClient>()),
  );

// Repository
  getIt.registerLazySingleton<AdsRepository>(
    () => AdsRepositoryImpl(remoteDataSource: getIt<AdsRemoteDataSource>()),
  );

// Use Cases
  getIt.registerLazySingleton<GetActiveAdsUseCase>(
    () => GetActiveAdsUseCase(getIt<AdsRepository>()),
  );

  getIt.registerLazySingleton<RegisterClickUseCase>(
    () => RegisterClickUseCase(getIt<AdsRepository>()),
  );

// BLoC
  getIt.registerFactory<AdsBloc>(
    () => AdsBloc(
      getActiveAdsUseCase: getIt<GetActiveAdsUseCase>(),
      registerClickUseCase: getIt<RegisterClickUseCase>(),
    ),
  );

// ============================================================================
// Weight Tracking Feature
// ============================================================================

// Data Sources
  getIt.registerLazySingleton<WeightRemoteDataSource>(
    () => WeightRemoteDataSource(dioClient: getIt<DioClient>()),
  );

// Repository
  getIt.registerLazySingleton<WeightRepository>(
    () =>
        WeightRepositoryImpl(remoteDataSource: getIt<WeightRemoteDataSource>()),
  );

// Use Cases
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

// BLoC
  getIt.registerFactory<WeightBloc>(
    () => WeightBloc(
      getWeightsUseCase: getIt<GetWeightsUseCase>(),
      getWeightStatsUseCase: getIt<GetWeightStatsUseCase>(),
      getWeightChartUseCase: getIt<GetWeightChartUseCase>(),
      getIdealWeightStatusUseCase: getIt<GetIdealWeightStatusUseCase>(),
      addWeightUseCase: getIt<AddWeightUseCase>(),
    ),
  );

  // ==========================
  // Notifications
  // ==========================

  final notificationBox = Hive.box<NotificationHiveModel>(notificationsBox);

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

  // Drawer Feature
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
}

void resetServiceLocator() {
  getIt.reset();
}
