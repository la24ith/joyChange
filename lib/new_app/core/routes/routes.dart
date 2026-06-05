// lib/core/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/SubscriptionInactiveScreen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/login_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/pending_device_approval_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/pending_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/register_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/presentation/screens/daily_commitment_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/home/presentation/screens/home_screen.dart';

class AppRouter {
  static final routes = [
    GetPage(name: '/login', page: () => const LoginScreen()),
    GetPage(name: '/register', page: () => const RegisterScreen()),
    GetPage(name: '/home', page: () => const HomeScreen()),

    // ✅ تأكد من وجود هذه routes
    GetPage(
      name: '/pending-subscription',
      page: () => PendingSubscriptionScreen(
        message: Get.arguments?['message'] ?? '',
        email: Get.arguments?['email'] ?? '',
        userId: Get.arguments?['userId'] ?? 0,
        password: Get.arguments?['password'] ?? '',
      ),
    ),
    GetPage(
      name: '/subscription-inactive',
      page: () => SubscriptionInactiveScreen(
        message: Get.arguments ?? 'Your subscription has expired',
      ),
    ),
    GetPage(
      name: '/pending-device',
      page: () => PendingDeviceApprovalScreen(
        message: Get.arguments?['message'] ?? '',
        email: Get.arguments?['email'] ?? '',
        password: Get.arguments?['password'] ?? '',
      ),
    ),
    GetPage(
      name: '/daily-commitment',
      page: () => const DailyCommitmentScreen(),
      transition: Transition.cupertino,
    ),
  ];
}
