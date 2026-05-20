// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/new_app/core/di/service_locator.dart';
import 'package:joy_of_change_v3/new_app/core/routes/routes.dart';
import 'package:joy_of_change_v3/new_app/core/utils/device_info.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize secure storage for device ID generation
  const secureStorage = FlutterSecureStorage();

  // Initialize Hive
  await Hive.initFlutter();

  // Setup dependency injection
  await setupServiceLocator();

  // Generate and store device ID if not exists
  final deviceInfoUtil = getIt<DeviceInfoUtil>();
  await deviceInfoUtil.getDeviceId(); // This generates and stores if needed

  // Run app
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
            // Check session after first frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              authBloc.add(CheckSessionEvent());
            });
            return authBloc;
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'Patient Weight Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
