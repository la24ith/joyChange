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
import 'package:joy_of_change_v3/new_app/core/workmanager/workmanager_callback.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/bloc/auth_event.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/bloc/auth_state.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/login_screen.dart';
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

  // ❌ إزالة هذا السطر - لا تحذف الـ Box
  // await Hive.deleteBoxFromDisk(notificationsBox);

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
        home: BlocBuilder<WeightBloc, WeightState>(builder: (context, state) {
          if (state is WeightLoaded && state.goalStatus.reached) {
            return const IdealWeightSplashScreen();
          }
          return const SplashScreen();
        }),
        getPages: [
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(name: '/home', page: () => const NavigationScreen()),
        ],
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Get.offAllNamed('/home');
        } else if (state is Unauthenticated) {
          Get.offAllNamed('/login');
        } else if (state is AuthError) {
          Get.offAllNamed('/login');
          Get.snackbar(
            'خطأ',
            state.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.teal),
              const SizedBox(height: 24),
              Text(
                'جاري التحقق من الجلسة...',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
