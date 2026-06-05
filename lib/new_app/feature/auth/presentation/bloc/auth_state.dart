// lib/features/auth/presentation/bloc/auth_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Base class for all authentication states
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// User is not authenticated (no session or logged out)
final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Login is in progress (loading)
final class LoginLoading extends AuthState {
  const LoginLoading();
}

/// Invalid email or password
final class InvalidCredentials extends AuthState {
  final String message;

  const InvalidCredentials({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Account created but waiting for subscription activation (NEEDS_SUBSCRIPTION)
final class PendingSubscription extends AuthState {
  final String message;
  final String email;
  final int userId;

  const PendingSubscription({
    required this.message,
    required this.email,
    required this.userId,
  });

  @override
  List<Object?> get props => [message, email, userId];
}

/// Subscription is inactive or expired (SUBSCRIPTION_INACTIVE)
final class SubscriptionInactive extends AuthState {
  final String message;

  const SubscriptionInactive({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Device is pending approval from admin (UNAPPROVED_DEVICE)
final class PendingDeviceApproval extends AuthState {
  final String message;
  final String email;

  const PendingDeviceApproval({
    required this.message,
    required this.email,
  });

  @override
  List<Object?> get props => [message, email];
}

/// User is fully authenticated (active subscription + approved device)
final class Authenticated extends AuthState {
  final User user;
  final String token;
  final bool hasActiveSubscription;

  const Authenticated({
    required this.user,
    required this.token,
    this.hasActiveSubscription = true,
  });

  @override
  List<Object?> get props => [user, token, hasActiveSubscription];

  Authenticated copyWith({
    User? user,
    String? token,
    bool? hasActiveSubscription,
  }) {
    return Authenticated(
      user: user ?? this.user,
      token: token ?? this.token,
      hasActiveSubscription:
          hasActiveSubscription ?? this.hasActiveSubscription,
    );
  }
}

/// User logged out (can be redirected to login)
final class LoggedOut extends AuthState {
  const LoggedOut();
}

/// General error state
final class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
