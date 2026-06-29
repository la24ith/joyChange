// lib/main.dart

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/firebase_options.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_theme.dart';
import 'package:joy_of_change_v3/new_app/core/constant/hive_boxes.dart';
import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';
import 'package:joy_of_change_v3/new_app/core/di/service_locator.dart';
import 'package:joy_of_change_v3/new_app/core/services/local_notification_service.dart';
import 'package:joy_of_change_v3/new_app/core/services/screenshot_service.dart';
import 'package:joy_of_change_v3/new_app/core/services/timezone_service.dart';
import 'package:joy_of_change_v3/new_app/core/storage/secure_storage.dart';
import 'package:joy_of_change_v3/new_app/core/workmanager/workmanager_callback.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/data/datasources/auth_remote_ds.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/entities/user.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/repositories/auth_repository.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/bloc/auth_event.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/bloc/auth_state.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/login_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/pending_device_approval_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/pending_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/profile_setup_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/subscription_expired_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/SubscriptionInactiveScreen.dart';
import 'package:joy_of_change_v3/new_app/feature/home/presentation/bloc/home_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/home/presentation/bloc/home_event.dart';
import 'package:joy_of_change_v3/new_app/feature/navigation/ideal_weight_splash_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/navigation/navigation_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/NotificationHiveModelAdapter.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/notification_hive_model.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/presentation/bloc/notifications_event.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/presentation/bloc/weight_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/presentation/bloc/weight_event.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/presentation/bloc/weight_state.dart';
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:joy_of_change_v3/new_app/core/services/fcm_service.dart';

// ✅ يجب أن تكون top-level function خارج أي class
// تعمل عند وصول إشعار FCM والتطبيق مغلق تماماً
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('📩 FCM Background: ${message.notification?.title}');
  // الإشعار يظهر تلقائياً من FCM — لا حاجة لـ flutter_local_notifications هنا
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // ✅ سجّل background handler فور تهيئة Firebase وقبل أي شيء آخر
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e, stackTrace) {
    debugPrint('🔥 Firebase init error: $e');
    debugPrint('📚 StackTrace: $stackTrace');
  }

  try {
    // ✅ الـ plugin يُسجَّل أولاً قبل setupServiceLocator
    // لأن NotificationSchedulerService يحتاجه عند تسجيله في getIt
    final notificationPlugin = await LocalNotificationInitializer.init();
    getIt
        .registerSingleton<FlutterLocalNotificationsPlugin>(notificationPlugin);

    // ✅ إصلاح timezone قبل setupServiceLocator
    await TimezoneService.initialize();

    await setupServiceLocator();
    await _fixProfileStatus();

    await registerNotificationSync();

    debugPrint('✅ All initializations completed successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Fatal initialization error: $e');
    debugPrint('📚 StackTrace: $stackTrace');
  }

  runApp(const MyApp());
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? _screenshotTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // فحص فوري عند بدء التطبيق
    _syncScreenshot();
    // ثم كل دقيقتين
    _screenshotTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _syncScreenshot(),
    );
  }

  @override
  void dispose() {
    _screenshotTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // فحص فوري عند رجوع المستخدم للتطبيق من الخلفية
    if (state == AppLifecycleState.resumed) {
      _syncScreenshot();
    }
  }

  Future<void> _syncScreenshot() async {
    try {
      final canScreenshot =
          await getIt<AuthRemoteDataSource>().fetchScreenshotPermission();
      await ScreenshotService.apply(canScreenshot);
      debugPrint('📸 Screenshot synced: $canScreenshot');
    } catch (e) {
      debugPrint('📸 Screenshot sync error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>(),
        ),
        BlocProvider<HomeBloc>(
          create: (context) {
            final homeBloc = getIt<HomeBloc>();
            homeBloc.add(const FetchPostsEvent(page: 1, limit: 10));
            return homeBloc;
          },
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
        title: 'متتبع وزن المريض',
        debugShowCheckedModeBanner: false,
        // ✅ دعم اللغة العربية والاتجاه من اليمين لليسار
        locale: const Locale('ar', 'SA'),
        supportedLocales: const [
          Locale('ar', 'SA'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestNotificationPermission();
      _checkConnectivity();
    });
  }

  // ✅ طلب إذن الإشعارات بشكل صحيح على Android
  Future<void> _requestNotificationPermission() async {
    if (!Platform.isAndroid) return;

    final status = await Permission.notification.status;
    debugPrint('🔔 Notification permission status: $status');

    if (status.isGranted) {
      debugPrint('✅ Notification permission already granted');
      return;
    }

    if (status.isPermanentlyDenied) {
      // المستخدم رفض بشكل دائم → وجّهه للإعدادات
      debugPrint(
          '⚠️ Notification permission permanently denied → opening settings');
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text(
              'تفعيل الإشعارات',
              textAlign: TextAlign.right,
            ),
            content: const Text(
              'يحتاج التطبيق إذن الإشعارات لإرسال التنبيهات.\nيرجى تفعيله من إعدادات الجهاز.',
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('لاحقاً'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await openAppSettings();
                },
                child: const Text(
                  'فتح الإعدادات',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            ],
          ),
        );
      }
      return;
    }

    // إذن لم يُطلب بعد أو مرفوض مرة واحدة → اطلبه
    final result = await Permission.notification.request();
    debugPrint('🔔 Notification permission result: $result');
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

  // ✅ fallback للوضع offline — يتحقق أيضاً من pending state
  Future<void> _checkCachedSession() async {
    try {
      final authRepository = getIt<AuthRepository>();

      final token = await authRepository.getStoredToken();
      final user = await authRepository.getStoredUser();

      debugPrint('Token: $token');
      debugPrint('User: ${user?.email}');

      if (token != null && token.isNotEmpty && user != null) {
        await _navigateBasedOnProfile(user);
      } else {
        // ✅ لا توكن → تحقق من pending state يدوياً
        await _checkPendingStateAndNavigate();
      }
    } catch (e) {
      debugPrint('Cached session error: $e');
      _navigateToLogin();
    }
  }

  // ✅ تحقق من pending state مباشرة (للـ offline أو fallback)
  Future<void> _checkPendingStateAndNavigate() async {
    try {
      final authRepository = getIt<AuthRepository>();
      final pendingState = await authRepository.getPendingState();

      if (pendingState != null) {
        final state = pendingState['state'];
        final email = pendingState['email'] ?? '';
        final userIdStr = pendingState['userId'];
        final password = pendingState['password'] ?? '';
        final deviceId = pendingState['deviceId'] ?? '';

        debugPrint('📱 Offline pending state: $state for $email');

        if (state == 'PENDING_SUBSCRIPTION' && mounted) {
          Get.offAll(() => PendingSubscriptionScreen(
                message: 'في انتظار تفعيل الاشتراك من قِبل المشرف.',
                email: email,
                userId: int.tryParse(userIdStr ?? '0') ?? 0,
                password: password,
              ));
          return;
        } else if (state == 'PENDING_DEVICE' && mounted) {
          Get.offAll(() => PendingDeviceApprovalScreen(
                message: 'هذا الجهاز في انتظار الموافقة من قِبل المشرف.',
                email: email,
                password: password,
              ));
          return;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error checking pending state: $e');
    }

    _navigateToLogin();
  }

  Future<void> _navigateBasedOnProfile(User user) async {
    if (!mounted) return;

    final isComplete = await _isProfileComplete(user);
    if (mounted) {
      if (isComplete) {
        Get.offAllNamed('/home');
      } else {
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
        context.read<AuthBloc>().add(CheckSessionEvent());
      } catch (e) {
        debugPrint('⚠️ Error reading AuthBloc: $e');
        setState(() {
          _isChecking = false;
          _statusMessage = 'حدث خطأ، يرجى المحاولة مرة أخرى';
        });
      }
    }
  }

  // ✅ الانتقال إلى PendingSubscriptionScreen مع جلب كلمة المرور
  Future<void> _navigateToPendingSubscription(PendingSubscription state) async {
    if (!mounted) return;
    try {
      final secureStorage = getIt.get<SecureStorageService>();
      final password = await secureStorage.read(key: 'pending_password') ?? '';
      if (mounted) {
        Get.offAll(() => PendingSubscriptionScreen(
              message: state.message,
              email: state.email,
              userId: state.userId,
              password: password,
            ));
      }
    } catch (e) {
      debugPrint('⚠️ Error navigating to pending subscription: $e');
      if (mounted) {
        Get.offAll(() => PendingSubscriptionScreen(
              message: state.message,
              email: state.email,
              userId: state.userId,
              password: '',
            ));
      }
    }
  }

  // ✅ الانتقال إلى PendingDeviceApprovalScreen مع جلب كلمة المرور
  Future<void> _navigateToPendingDevice(PendingDeviceApproval state) async {
    if (!mounted) return;
    try {
      final secureStorage = getIt.get<SecureStorageService>();
      final password = await secureStorage.read(key: 'pending_password') ?? '';
      if (mounted) {
        Get.offAll(() => PendingDeviceApprovalScreen(
              message: state.message,
              email: state.email,
              password: password,
            ));
      }
    } catch (e) {
      debugPrint('⚠️ Error navigating to pending device: $e');
      if (mounted) {
        Get.offAll(() => PendingDeviceApprovalScreen(
              message: state.message,
              email: state.email,
              password: '',
            ));
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
        } else if (state is ProfileIncomplete) {
          if (mounted) Get.offAllNamed('/profile-setup');
        } else if (state is SubscriptionInactive) {
          // ✅ اشتراك منتهٍ
          if (mounted) {
            Get.offAll(
                () => SubscriptionInactiveScreen(message: state.message));
          }
        } else if (state is AuthError) {
          if (state.message.contains('subscription') ||
              state.message.contains('expired') ||
              AppState.subscriptionExpired) {
            Get.offAll(() => const SubscriptionExpiredScreen());
            return;
          }
          _handleAuthError(state.message);
        } else if (state is LoginLoading) {
          setState(() {
            _isChecking = true;
            _statusMessage = 'جاري التحقق من الجلسة...';
          });

          // ✅ انتظار الاشتراك — كان مفقوداً
        } else if (state is PendingSubscription) {
          _navigateToPendingSubscription(state);

          // ✅ انتظار تفعيل الجهاز — كان مفقوداً
        } else if (state is PendingDeviceApproval) {
          _navigateToPendingDevice(state);
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
      // ✅ سجّل FCM token عند نجاح الـ session — لا يعطّل الـ UI
      getIt<FcmService>().initAndRegister().catchError((e) {
        debugPrint('⚠️ FCM registration error (non-fatal): $e');
      });

      final isComplete = await _isProfileComplete(user);
      if (mounted) {
        if (isComplete) {
          Get.offAllNamed('/home');
        } else {
          Get.offAllNamed('/profile-setup');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error in _handleAuthenticated: $e');
      if (mounted) Get.offAllNamed('/home');
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
