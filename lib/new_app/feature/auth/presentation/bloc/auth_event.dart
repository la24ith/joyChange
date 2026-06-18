// lib/features/auth/presentation/bloc/auth_event.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Base class for all authentication events
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check session when app starts
final class CheckSessionEvent extends AuthEvent {}

/// Event to login user
final class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String deviceId;

  const LoginEvent({
    required this.email,
    required this.password,
    required this.deviceId,
  });

  @override
  List<Object?> get props => [email, password, deviceId];
}

/// Event to register new user
final class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String phone;

  const RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, email, password, phone];
}

/// Event to check subscription status (polling)
final class CheckSubscriptionStatusEvent extends AuthEvent {
  final String email;

  const CheckSubscriptionStatusEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event to check device approval status (polling)
final class CheckDeviceApprovalEvent extends AuthEvent {
  final String email;
  final String deviceId;

  const CheckDeviceApprovalEvent({
    required this.email,
    required this.deviceId,
  });

  @override
  List<Object?> get props => [email, deviceId];
}

/// Event to retry login after device approval
final class RetryLoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String deviceId;

  const RetryLoginEvent({
    required this.email,
    required this.password,
    required this.deviceId,
  });

  @override
  List<Object?> get props => [email, password, deviceId];
}

/// Event to logout user
final class LogoutEvent extends AuthEvent {}

/// Event to clear error message
final class ClearAuthErrorEvent extends AuthEvent {}

/// ✅ Event to start subscription polling
final class StartSubscriptionPollingEvent extends AuthEvent {
  final String email;
  const StartSubscriptionPollingEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// ✅ Event to start device polling
final class StartDevicePollingEvent extends AuthEvent {
  final String email;
  final String deviceId;
  const StartDevicePollingEvent({required this.email, required this.deviceId});

  @override
  List<Object?> get props => [email, deviceId];
}

/// ✅ Event to stop polling
final class StopPollingEvent extends AuthEvent {}

/// ✅ Event to mark profile as completed (مع النوع الصحيح)
final class ProfileCompletedEvent extends AuthEvent {
  final User user;

  const ProfileCompletedEvent(this.user);

  @override
  List<Object?> get props => [user];
}
