// lib/core/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/SubscriptionInactiveScreen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/login_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/pending_device_approval_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/pending_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/register_screen.dart'
    show RegisterScreen;
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/subscription_expired_screen.dart';
import '../constant/storage_keys.dart';
import '../di/service_locator.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: _checkInitialRoute(),
    routes: [
// lib/core/routes/app_router.dart (أضف هذه imports والشاشات)

// داخل routes array أضف:

      GoRoute(
        name: 'pending-subscription',
        path: '/pending-subscription',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return PendingSubscriptionScreen(
            message: args?['message'] as String? ??
                'Waiting for subscription activation',
            email: args?['email'] as String? ?? '',
            userId: args?['userId'] as int? ?? 0,
          );
        },
      ),

      GoRoute(
        name: 'subscription-inactive',
        path: '/subscription-inactive',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return SubscriptionInactiveScreen(
            message: args?['message'] as String? ??
                'Your subscription has expired or is not active',
          );
        },
      ),

      GoRoute(
        name: 'pending-device',
        path: '/pending-device',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return PendingDeviceApprovalScreen(
            message: args?['message'] as String? ??
                'This device is awaiting approval',
            email: args?['email'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) {
          // TODO: Replace with actual LoginScreen
          return LoginScreen();
        },
      ),
      GoRoute(
        name: 'register',
        path: '/register',
        builder: (context, state) {
          // TODO: Replace with actual RegisterScreen
          return RegisterScreen();
        },
      ),
      GoRoute(
        name: 'subscription-expired',
        path: '/subscription-expired',
        builder: (context, state) {
          // TODO: Replace with actual SubscriptionExpiredScreen
          return const SubscriptionExpiredScreen();
        },
      ),
      GoRoute(
        name: 'device-blocked',
        path: '/device-blocked',
        builder: (context, state) {
          // TODO: Replace with actual DeviceBlockedScreen
          return const Scaffold(
            body: Center(child: Text('Device Blocked - Contact Support')),
          );
        },
      ),
      GoRoute(
        name: 'home',
        path: '/home',
        builder: (context, state) {
          // TODO: Replace with actual HomeScreen
          return const Scaffold(
            body: Center(child: Text('Home Screen - Coming Soon')),
          );
        },
      ),
    ],
    redirect: _redirectLogic,
  );

  /// Check if user is logged in for initial route
  static String _checkInitialRoute() {
    // We'll check async in redirect logic, so start with login
    return '/login';
  }

  /// Redirect logic based on authentication and subscription status
  static Future<String?> _redirectLogic(
    BuildContext context,
    GoRouterState state,
  ) async {
    final secureStorage = getIt<FlutterSecureStorage>();

    // Get stored token
    final token = await secureStorage.read(key: StorageKeys.accessToken);
    final isLoggedIn = token != null && token.isNotEmpty;

    final currentLocation = state.matchedLocation;
    final isAuthRoute =
        currentLocation == '/login' || currentLocation == '/register';
    final isBlockedRoute = currentLocation == '/subscription-expired' ||
        currentLocation == '/device-blocked';

    // If not logged in and not on auth routes, go to login
    if (!isLoggedIn && !isAuthRoute && !isBlockedRoute) {
      return '/login';
    }

    // If logged in and on auth routes, go to home
    if (isLoggedIn && isAuthRoute) {
      // TODO: Check subscription status here before going to home
      // For now, go to home
      return '/home';
    }

    // Check subscription status if logged in and not on blocked routes
    if (isLoggedIn && !isBlockedRoute) {
      // TODO: Implement subscription check with API
      // For now, allow access
      return null;
    }

    // No redirect needed
    return null;
  }

  /// Navigate to login with clearing stack
  static void goToLogin(BuildContext context) {
    context.go('/login');
  }

  /// Navigate to home with clearing stack
  static void goToHome(BuildContext context) {
    context.go('/home');
  }

  /// Navigate to subscription expired screen
  static void goToSubscriptionExpired(BuildContext context) {
    context.go('/subscription-expired');
  }

  /// Navigate to device blocked screen
  static void goToDeviceBlocked(BuildContext context) {
    context.go('/device-blocked');
  }
}
