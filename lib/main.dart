// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/firebase_options.dart';
import 'package:joy_of_change_v3/new_app/core/constant/hive_boxes.dart';
import 'package:joy_of_change_v3/new_app/core/di/service_locator.dart';
import 'package:joy_of_change_v3/new_app/core/services/local_notification_service.dart';
import 'package:joy_of_change_v3/new_app/core/services/timezone_service.dart';
import 'package:joy_of_change_v3/new_app/core/storage/secure_storage.dart';
import 'package:joy_of_change_v3/new_app/core/workmanager/workmanager_callback.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/entities/user.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/repositories/auth_repository.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/bloc/auth_event.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/bloc/auth_state.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/login_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/profile_setup_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/home/presentation/bloc/home_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/navigation/ideal_weight_splash_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/navigation/navigation_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/NotificationHiveModelAdapter.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/notification_hive_model.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/presentation/bloc/notifications_event.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/presentation/bloc/weight_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/presentation/bloc/weight_event.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/presentation/bloc/weight_state.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تهيئة Firebase بأمان
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  await Hive.initFlutter();

  Hive.registerAdapter(NotificationHiveModelAdapter());

  await Hive.openBox<NotificationHiveModel>(notificationsBox);

  await TimezoneService.initialize();

  final notificationPlugin = await LocalNotificationInitializer.init();
  await notificationPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  await registerNotificationSync();
  await setupServiceLocator();

  // ✅ تخزين الـ plugin في service locator
  getIt.registerSingleton<FlutterLocalNotificationsPlugin>(notificationPlugin);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) {
            final authBloc = getIt<AuthBloc>();
            authBloc.add(CheckSessionEvent());
            return authBloc;
          },
        ),
        BlocProvider<HomeBloc>(
          create: (context) => getIt<HomeBloc>(),
        ),
        BlocProvider<NotificationBloc>.value(
          value: getIt<NotificationBloc>()
            ..add(LoadNotifications())
            ..add(SyncNotifications()),
        ),
        BlocProvider<WeightBloc>.value(
          value: getIt<WeightBloc>()..add(LoadWeightsEvent()),
        ),
      ],
      child: GetMaterialApp(
        title: 'Patient Weight Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Cairo',
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        home: BlocBuilder<WeightBloc, WeightState>(
          builder: (context, state) {
            if (state is WeightLoaded && state.goalStatus.reached) {
              return const IdealWeightSplashScreen();
            }
            return const SplashScreen();
          },
        ),
        getPages: [
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(name: '/home', page: () => const NavigationScreen()),
          GetPage(
              name: '/profile-setup', page: () => const ProfileSetupScreen()),
        ],
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isConnected = true;
  bool _isChecking = true;
  String _statusMessage = 'جاري التحقق من الجلسة...';

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    // ✅ التحقق من الاتصال
    final connectivityResult = await Connectivity().checkConnectivity();
    _isConnected = connectivityResult != ConnectivityResult.none;

    if (!_isConnected) {
      // ✅ وضع عدم الاتصال - عرض البيانات المحفوظة
      setState(() {
        _statusMessage =
            'لا يوجد اتصال بالإنترنت\nجاري عرض البيانات المحفوظة...';
        _isChecking = false;
      });

      // ✅ محاولة التحقق من الجلسة المحفوظة
      await _checkCachedSession();
    } else {
      // ✅ يوجد اتصال - التحقق من الجلسة
      setState(() {
        _statusMessage = 'جاري التحقق من الجلسة...';
      });

      // ✅ إعادة التحقق من الجلسة
      _retryCheckSession();
    }
  }

  Future<void> _checkCachedSession() async {
    try {
      final authRepository = getIt.get<AuthRepository>();
      final token = await authRepository.getStoredToken();
      final user = await authRepository.getStoredUser();

      if (token != null && token.isNotEmpty && user != null) {
        // ✅ يوجد جلسة محفوظة - انتقل للصفحة المناسبة
        _navigateBasedOnProfile(user);
      } else {
        // ✅ لا توجد جلسة محفوظة - انتقل لتسجيل الدخول
        _navigateToLogin();
      }
    } catch (e) {
      print('⚠️ Error checking cached session: $e');
      _navigateToLogin();
    }
  }

  void _navigateBasedOnProfile(User user) {
    // ✅ التحقق من اكتمال البروفايل
    final hasCompleteData = user.currentWeight != null &&
        user.targetWeight != null &&
        user.height != null &&
        user.patientSegment.isNotEmpty &&
        user.patientSegment != 'general' &&
        user.phone != null &&
        user.phone!.isNotEmpty;

    // ✅ التحقق من حالة الإكمال في SecureStorage
    _checkProfileCompletionAndNavigate(user, hasCompleteData);
  }

  Future<void> _checkProfileCompletionAndNavigate(
      User user, bool hasCompleteData) async {
    try {
      final secureStorage = getIt.get<SecureStorageService>();
      final profileCompleted =
          await secureStorage.read(key: 'profile_completed');

      if (profileCompleted == 'true' && hasCompleteData) {
        // ✅ البروفايل مكتمل - انتقل للصفحة الرئيسية
        if (mounted) {
          Get.offAllNamed('/home');
        }
      } else {
        // ✅ البروفايل غير مكتمل - انتقل لصفحة الإكمال
        if (mounted) {
          Get.offAllNamed('/profile-setup');
        }
      }
    } catch (e) {
      print('⚠️ Error checking profile completion: $e');
      if (hasCompleteData) {
        if (mounted) Get.offAllNamed('/home');
      } else {
        if (mounted) Get.offAllNamed('/profile-setup');
      }
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Get.offAllNamed('/login');
    }
  }

  void _retryCheckSession() {
    // ✅ إعادة التحقق من الجلسة
    final authBloc = context.read<AuthBloc>();
    authBloc.add(CheckSessionEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        setState(() {
          _isChecking = false;
        });

        if (state is Authenticated) {
          // ✅ تحقق من اكتمال البروفايل قبل الانتقال
          _handleAuthenticated(state.user);
        } else if (state is Unauthenticated) {
          _navigateToLogin();
        } else if (state is AuthError) {
          // ✅ في حالة الخطأ، حاول استخدام البيانات المحفوظة
          _handleAuthError(state.message);
        } else if (state is LoginLoading) {
          setState(() {
            _isChecking = true;
            _statusMessage = 'جاري التحقق من الجلسة...';
          });
        } else if (state is ProfileIncomplete) {
          // ✅ حالة البروفايل غير مكتمل
          if (mounted) {
            Get.offAllNamed('/profile-setup');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ أيقونة الاتصال
              _isConnected
                  ? const Icon(
                      Icons.wifi,
                      size: 48,
                      color: Colors.teal,
                    )
                  : Icon(
                      Icons.wifi_off,
                      size: 48,
                      color: Colors.orange.shade700,
                    ),
              const SizedBox(height: 24),

              // ✅ مؤشر التحميل
              _isChecking
                  ? const CircularProgressIndicator(color: Colors.teal)
                  : Icon(
                      _isConnected ? Icons.check_circle : Icons.warning_amber,
                      color: _isConnected ? Colors.green : Colors.orange,
                      size: 40,
                    ),
              const SizedBox(height: 24),

              // ✅ رسالة الحالة
              Text(
                _statusMessage,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // ✅ زر إعادة المحاولة (عند الخطأ أو عدم الاتصال)
              if (!_isConnected)
                TextButton(
                  onPressed: _checkConnectivity,
                  child: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),

              // ✅ زر إعادة المحاولة عند الخطأ
              if (!_isChecking && _isConnected)
                TextButton(
                  onPressed: _retryCheckSession,
                  child: const Text(
                    'إعادة التحقق',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAuthenticated(User user) async {
    try {
      final secureStorage = getIt.get<SecureStorageService>();
      final profileCompleted =
          await secureStorage.read(key: 'profile_completed');

      // ✅ التحقق من اكتمال البيانات
      final hasCompleteData = user.currentWeight != null &&
          user.targetWeight != null &&
          user.height != null &&
          user.patientSegment.isNotEmpty &&
          user.patientSegment != 'general' &&
          user.phone != null &&
          user.phone!.isNotEmpty;

      if (profileCompleted == 'true' && hasCompleteData) {
        if (mounted) {
          Get.offAllNamed('/home');
        }
      } else {
        if (mounted) {
          Get.offAllNamed('/profile-setup');
        }
      }
    } catch (e) {
      print('⚠️ Error in _handleAuthenticated: $e');
      if (mounted) {
        Get.offAllNamed('/home');
      }
    }
  }

  void _handleAuthError(String message) async {
    print('⚠️ Auth error: $message');

    // ✅ محاولة استخدام البيانات المحفوظة في حالة الخطأ
    try {
      final authRepository = getIt.get<AuthRepository>();
      final token = await authRepository.getStoredToken();
      final user = await authRepository.getStoredUser();

      if (token != null && token.isNotEmpty && user != null) {
        // ✅ توجد بيانات محفوظة - استخدمها
        _navigateBasedOnProfile(user);
        return;
      }
    } catch (e) {
      print('⚠️ Error getting cached data: $e');
    }

    // ✅ في حالة عدم وجود بيانات محفوظة
    if (mounted) {
      Get.offAllNamed('/login');
      Get.snackbar(
        'خطأ',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
