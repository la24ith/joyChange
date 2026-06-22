// lib/main.dart

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/firebase_options.dart';
import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';
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

  try {
    // ✅ تهيئة Firebase بأمان
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e, stackTrace) {
    debugPrint('🔥 Firebase init error: $e');
    debugPrint('📚 StackTrace: $stackTrace');
  }

  try {
    // ============================================================================
    // ✅ 1. تسجيل Adapters فقط - NO Hive.initFlutter() هنا!
    // ============================================================================

    // ============================================================================
    // ✅ 2. تهيئة Service Locator (Hive.initFlutter() ستُستدعى من HiveService)
    // ============================================================================
    await setupServiceLocator();

    // ============================================================================
    // ✅ 3. إصلاح حالة البروفايل
    // ============================================================================
    await _fixProfileStatus();

    // ============================================================================
    // ✅ 4. باقي التهيئة
    // ============================================================================
    await TimezoneService.initialize();

    final notificationPlugin = await LocalNotificationInitializer.init();
    await notificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await registerNotificationSync();

    // ✅ تخزين الـ plugin
    getIt
        .registerSingleton<FlutterLocalNotificationsPlugin>(notificationPlugin);

    debugPrint('✅ All initializations completed successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Fatal initialization error: $e');
    debugPrint('📚 StackTrace: $stackTrace');
  }

  runApp(
    const MyApp(),
  );
}

// ============================================================================
// ✅ Helper Functions
// ============================================================================

Future<void> _fixProfileStatus() async {
  try {
    final secureStorage = getIt.get<SecureStorageService>();
    final authRepo = getIt.get<AuthRepository>();

    final user = await authRepo.getStoredUser();

    if (user != null) {
      debugPrint('👤 Found user: ${user.email}');

      final hasCompleteData = user.currentWeight != null &&
          user.targetWeight != null &&
          user.height != null &&
          user.patientSegment.isNotEmpty &&
          user.patientSegment != 'general' &&
          user.phone != null &&
          user.phone!.isNotEmpty;

      debugPrint('📊 Has complete data: $hasCompleteData');

      if (hasCompleteData) {
        final current = await secureStorage.read(key: 'profile_completed');
        debugPrint('🔍 Current profile_completed: "$current"');

        if (current != 'true') {
          await secureStorage.write(key: 'profile_completed', value: 'true');
          debugPrint('✅ Auto-fixed profile status for: ${user.email}');

          final fixed = await secureStorage.read(key: 'profile_completed');
          debugPrint('🔍 After fix: "$fixed"');
        } else {
          debugPrint('✅ Profile status already correct');
        }
      } else {
        debugPrint('⚠️ User data incomplete, profile setup needed');
        await secureStorage.write(key: 'profile_completed', value: 'false');
      }
    } else {
      debugPrint('⚠️ No user found in storage');
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Error fixing profile status: $e');
    debugPrint('📚 StackTrace: $stackTrace');
  }
}

// ============================================================================
// ✅ MyApp
// ============================================================================

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
        BlocProvider<NotificationBloc>(
          create: (context) => getIt<NotificationBloc>()
            ..add(LoadNotifications())
            ..add(SyncNotifications()),
        ),
        BlocProvider<WeightBloc>(
          create: (context) => getIt<WeightBloc>()..add(LoadWeightsEvent()),
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
            name: '/profile-setup',
            page: () => const ProfileSetupScreen(),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ✅ SplashScreen
// ============================================================================

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    if (!mounted) return;

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _isConnected = connectivityResult != ConnectivityResult.none;

      if (!_isConnected) {
        setState(() {
          _statusMessage =
              'لا يوجد اتصال بالإنترنت\nجاري عرض البيانات المحفوظة...';
          _isChecking = false;
        });
        await _checkCachedSession();
      } else {
        setState(() {
          _statusMessage = 'جاري التحقق من الجلسة...';
        });
        _retryCheckSession();
      }
    } catch (e) {
      debugPrint('⚠️ Connectivity check error: $e');
      setState(() {
        _isConnected = false;
        _isChecking = false;
        _statusMessage =
            'فشل التحقق من الاتصال\nجاري استخدام البيانات المحفوظة';
      });
      await _checkCachedSession();
    }
  }

  Future<void> _checkCachedSession() async {
    if (!mounted) return;

    try {
      final authRepository = getIt.get<AuthRepository>();
      final token = await authRepository.getStoredToken();
      final user = await authRepository.getStoredUser();

      if (token != null && token.isNotEmpty && user != null) {
        await _navigateBasedOnProfile(user);
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      debugPrint('⚠️ Error checking cached session: $e');
      _navigateToLogin();
    }
  }

  Future<void> _navigateBasedOnProfile(User user) async {
    if (!mounted) return;

    final isComplete = await _isProfileComplete(user);
    if (isComplete) {
      if (mounted) {
        Get.offAllNamed('/home');
      }
    } else {
      if (mounted) {
        Get.offAllNamed('/profile-setup');
      }
    }
  }

  Future<bool> _isProfileComplete(User user) async {
    try {
      final secureStorage = getIt.get<SecureStorageService>();
      final profileCompleted =
          await secureStorage.read(key: 'profile_completed');

      final hasCompleteData = user.currentWeight != null &&
          user.targetWeight != null &&
          user.height != null &&
          user.patientSegment.isNotEmpty &&
          user.patientSegment != 'general' &&
          user.phone != null &&
          user.phone!.isNotEmpty;

      return profileCompleted == 'true' && hasCompleteData;
    } catch (e) {
      debugPrint('⚠️ Error checking profile completion: $e');
      return false;
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Get.offAllNamed('/login');
    }
  }

  void _retryCheckSession() {
    if (mounted) {
      try {
        final authBloc = context.read<AuthBloc>();
        authBloc.add(CheckSessionEvent());
      } catch (e) {
        debugPrint('⚠️ Error reading AuthBloc: $e');
        setState(() {
          _isChecking = false;
          _statusMessage = 'حدث خطأ، يرجى المحاولة مرة أخرى';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!mounted) return;

        setState(() {
          _isChecking = false;
        });

        if (state is Authenticated) {
          _handleAuthenticated(state.user);
        } else if (state is Unauthenticated) {
          _navigateToLogin();
        } else if (state is AuthError) {
          _handleAuthError(state.message);
        } else if (state is LoginLoading) {
          setState(() {
            _isChecking = true;
            _statusMessage = 'جاري التحقق من الجلسة...';
          });
        } else if (state is ProfileIncomplete) {
          if (mounted) {
            Get.offAllNamed('/profile-setup');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isConnected
                    ? const Icon(Icons.wifi, size: 48, color: Colors.teal)
                    : Icon(
                        Icons.wifi_off,
                        size: 48,
                        color: Colors.orange.shade700,
                      ),
                const SizedBox(height: 24),
                _isChecking
                    ? const CircularProgressIndicator(color: Colors.teal)
                    : Icon(
                        _isConnected ? Icons.check_circle : Icons.warning_amber,
                        color: _isConnected ? Colors.green : Colors.orange,
                        size: 40,
                      ),
                const SizedBox(height: 24),
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
                if (!_isConnected)
                  TextButton(
                    onPressed: _checkConnectivity,
                    child: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
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
      ),
    );
  }

  void _handleAuthenticated(User user) async {
    if (!mounted) return;

    try {
      final isComplete = await _isProfileComplete(user);
      if (isComplete) {
        if (mounted) {
          Get.offAllNamed('/home');
        }
      } else {
        if (mounted) {
          Get.offAllNamed('/profile-setup');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error in _handleAuthenticated: $e');
      if (mounted) {
        Get.offAllNamed('/home');
      }
    }
  }

  void _handleAuthError(String message) async {
    if (!mounted) return;

    debugPrint('⚠️ Auth error: $message');

    try {
      final authRepository = getIt.get<AuthRepository>();
      final token = await authRepository.getStoredToken();
      final user = await authRepository.getStoredUser();

      if (token != null && token.isNotEmpty && user != null) {
        await _navigateBasedOnProfile(user);
        return;
      }
    } catch (e) {
      debugPrint('⚠️ Error getting cached data: $e');
    }

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
