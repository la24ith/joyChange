// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/check_subscription_usecase.dart';
import '../../../../core/utils/device_info.dart';
import '../../domain/repositories/auth_repository.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final DeviceInfoUtil _deviceInfoUtil;
  final CheckSubscriptionUseCase _checkSubscriptionUseCase;

  Timer? _pollingTimer;
  int _pollingCount = 0;
  static const int maxPollingAttempts = 30;
  String? _currentPollingEmail;
  String? _currentPollingDeviceId;

  AuthBloc({
    required AuthRepository authRepository,
    required DeviceInfoUtil deviceInfoUtil,
    required CheckSubscriptionUseCase checkSubscriptionUseCase,
  })  : _authRepository = authRepository,
        _deviceInfoUtil = deviceInfoUtil,
        _checkSubscriptionUseCase = checkSubscriptionUseCase,
        super(const Unauthenticated()) {
    on<CheckSessionEvent>(_onCheckSession);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<CheckSubscriptionStatusEvent>(_onCheckSubscriptionStatus);
    on<CheckDeviceApprovalEvent>(_onCheckDeviceApproval);
    on<RetryLoginEvent>(_onRetryLogin);
    on<LogoutEvent>(_onLogout);
    on<ClearAuthErrorEvent>(_onClearError);
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }

  /// Check session when app starts
  Future<void> _onCheckSession(
    CheckSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    final token = await _authRepository.getStoredToken();

    if (token == null || token.isEmpty) {
      emit(const Unauthenticated());
      return;
    }

    final user = await _authRepository.getStoredUser();
    if (user != null) {
      emit(Authenticated(user: user, token: token));
    } else {
      emit(const Unauthenticated());
    }
  }

  /// Handle login
  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const LoginLoading());

    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
      deviceId: event.deviceId,
    );

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
        Future.delayed(const Duration(seconds: 2), () {
          if (!isClosed) emit(const Unauthenticated());
        });
      },
      (response) {
        final state = response.toAuthState();
        emit(state);

        // Start polling if needed
        if (state is PendingSubscription) {
          _startSubscriptionPolling(emit, state.email);
        } else if (state is PendingDeviceApproval) {
          _startDevicePolling(emit, state.email, event.deviceId);
        }
      },
    );
  }

  /// Handle registration
  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const LoginLoading());

    final result = await _authRepository.register(
      name: event.name,
      email: event.email,
      password: event.password,
      passwordConfirmation: event.password,
      phone: event.phone,
    );

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
        Future.delayed(const Duration(seconds: 2), () {
          if (!isClosed) emit(const Unauthenticated());
        });
      },
      (response) {
        emit(PendingSubscription(
          message: response.message,
          email: response.email,
          userId: response.userId,
        ));
        _startSubscriptionPolling(emit, response.email);
      },
    );
  }

  /// Start polling for subscription activation
  void _startSubscriptionPolling(Emitter<AuthState> emit, String email) {
    _pollingTimer?.cancel();
    _pollingCount = 0;
    _currentPollingEmail = email;

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) async {
        _pollingCount++;

        if (_pollingCount >= maxPollingAttempts) {
          timer.cancel();
          emit(const AuthError(
              message: 'Activation timeout. Please try again later.'));
          Future.delayed(const Duration(seconds: 2), () {
            if (!isClosed) emit(const Unauthenticated());
          });
          return;
        }

        final result = await _authRepository.checkSubscriptionStatus(email);

        result.fold(
          (failure) => null,
          (isActive) {
            if (isActive && !isClosed) {
              timer.cancel();
              emit(const AuthError(
                message: '✅ Subscription activated! Please login again.',
              ));
              Future.delayed(const Duration(seconds: 2), () {
                if (!isClosed) emit(const Unauthenticated());
              });
            }
          },
        );
      },
    );
  }

  /// Start polling for device approval
  void _startDevicePolling(
      Emitter<AuthState> emit, String email, String deviceId) {
    _pollingTimer?.cancel();
    _pollingCount = 0;
    _currentPollingEmail = email;
    _currentPollingDeviceId = deviceId;

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) async {
        _pollingCount++;

        if (_pollingCount >= maxPollingAttempts) {
          timer.cancel();
          emit(const AuthError(
              message: 'Device approval timeout. Please try again later.'));
          Future.delayed(const Duration(seconds: 2), () {
            if (!isClosed) emit(const Unauthenticated());
          });
          return;
        }

        // Retry login to check if device is approved
        if (_currentPollingEmail != null && _currentPollingDeviceId != null) {
          final result = await _authRepository.login(
            email: _currentPollingEmail!,
            password:
                '', // Password is not available, so we need to handle this
            deviceId: _currentPollingDeviceId!,
          );

          result.fold(
            (failure) => null,
            (response) {
              if (response.success && !isClosed) {
                timer.cancel();
                final newState = response.toAuthState();
                if (newState is Authenticated) {
                  emit(newState);
                }
              }
            },
          );
        }
      },
    );
  }

  /// Handle retry login after device approval
  Future<void> _onRetryLogin(
    RetryLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const LoginLoading());

    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
      deviceId: event.deviceId,
    );

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
        Future.delayed(const Duration(seconds: 2), () {
          if (!isClosed) emit(const Unauthenticated());
        });
      },
      (response) {
        final state = response.toAuthState();
        emit(state);
      },
    );
  }

  /// Handle logout
  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    _pollingTimer?.cancel();
    await _authRepository.logout();
    emit(const LoggedOut());
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!isClosed) emit(const Unauthenticated());
    });
  }

  /// Clear error
  void _onClearError(
    ClearAuthErrorEvent event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthError) {
      emit(const Unauthenticated());
    }
  }

// lib/features/auth/presentation/bloc/auth_bloc.dart

// أضف هذه الدوال في نهاية ملف AuthBloc، قبل الدوال الأخرى:

  /// Handle check subscription status (polling)
  Future<void> _onCheckSubscriptionStatus(
    CheckSubscriptionStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Check subscription status using the repository
    final result = await _authRepository.checkSubscriptionStatus(event.email);

    result.fold(
      (failure) {
        print('⚠️ Subscription check failed: ${failure.message}');
      },
      (isActive) {
        if (isActive && !isClosed) {
          _pollingTimer?.cancel();
          if (mounted) {
            emit(const AuthError(
              message: '✅ Subscription activated! Please login again.',
            ));
            Future.delayed(const Duration(seconds: 2), () {
              if (!isClosed) emit(const Unauthenticated());
            });
          }
        }
      },
    );
  }

  /// Handle check device approval status (polling)
  Future<void> _onCheckDeviceApproval(
    CheckDeviceApprovalEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Retry login to check if device is approved
    // Note: We don't have the password during polling, so we need to get it from storage
    final storedPassword = await _getStoredPassword();

    if (storedPassword == null || storedPassword.isEmpty) {
      print('⚠️ No stored password for device approval check');
      _pollingTimer?.cancel();
      return;
    }

    final result = await _authRepository.login(
      email: event.email,
      password: storedPassword,
      deviceId: event.deviceId,
    );

    result.fold(
      (failure) {
        print('⚠️ Device check failed: ${failure.message}');
      },
      (response) {
        if (response.success && !isClosed) {
          _pollingTimer?.cancel();
          final newState = response.toAuthState();
          if (newState is Authenticated && mounted) {
            emit(newState);
          }
        }
      },
    );
  }

  /// Helper to get stored password (if needed for polling)
  /// Note: In production, you should NOT store passwords.
  /// This is a temporary solution. Better approach: Have a dedicated API for device approval check.
  Future<String?> _getStoredPassword() async {
    // For security reasons, we don't store passwords
    // This is a limitation of the current approach
    // Ideally, the backend should have an endpoint to check device approval without password
    return null;
  }

  /// Check if the bloc is still mounted (not closed)
  bool get mounted => !isClosed;
}
