// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/core/di/service_locator.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import 'package:joy_of_change_v3/new_app/core/storage/secure_storage.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/check_session_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/check_subscription_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/register_usecase.dart';
import '../../../../core/utils/device_info.dart';
import '../../domain/repositories/auth_repository.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final DeviceInfoUtil _deviceInfoUtil;
  final CheckSubscriptionUseCase _checkSubscriptionUseCase;
  final CheckSessionUseCase _checkSessionUseCase;
  final RegisterUseCase _registerUseCase;

  Timer? _pollingTimer;
  int _pollingCount = 0;
  static const int maxPollingAttempts = 30;
  String? _currentPollingEmail;
  String? _currentPollingDeviceId;

  AuthBloc({
    required AuthRepository authRepository,
    required DeviceInfoUtil deviceInfoUtil,
    required CheckSessionUseCase checkSessionUseCase,
    required CheckSubscriptionUseCase checkSubscriptionUseCase,
    required RegisterUseCase registerUseCase,
  })  : _authRepository = authRepository,
        _deviceInfoUtil = deviceInfoUtil,
        _checkSubscriptionUseCase = checkSubscriptionUseCase,
        _checkSessionUseCase = checkSessionUseCase, // ✅ استخدم الـ injected
        _registerUseCase = registerUseCase,
        super(const Unauthenticated()) {
    on<CheckSessionEvent>(_onCheckSession);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<CheckSubscriptionStatusEvent>(_onCheckSubscriptionStatus);
    on<CheckDeviceApprovalEvent>(_onCheckDeviceApproval);
    on<RetryLoginEvent>(_onRetryLogin);
    on<LogoutEvent>(_onLogout);
    on<ClearAuthErrorEvent>(_onClearError);
    on<StartSubscriptionPollingEvent>(_onStartSubscriptionPolling);
    on<StartDevicePollingEvent>(_onStartDevicePolling);
    on<StopPollingEvent>(_onStopPolling);
    on<ProfileCompletedEvent>(_onProfileCompleted); // ✅ أضف هذا
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }

  // ============================================================
  // ✅ معالجة CheckSession
  // ============================================================
  Future<void> _onCheckSession(
    CheckSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const LoginLoading());

    final result = await _checkSessionUseCase();

    result.fold(
      (failure) {
        if (failure is SessionExpiredFailure) {
          emit(const Unauthenticated());
        } else if (failure is SubscriptionExpiredFailure) {
          emit(SubscriptionInactive(message: failure.message));
        } else {
          _emitCachedState(emit);
        }
      },
      (sessionResult) {
        if (!sessionResult.isProfileComplete) {
          emit(ProfileIncomplete(
            user: sessionResult.user,
            message: 'يرجى إكمال ملفك الشخصي',
          ));
        } else {
          emit(Authenticated(
            user: sessionResult.user,
            token: '',
          ));
        }
      },
    );
  }

  /// ✅ محاولة استخدام البيانات المحفوظة في حالة الخطأ
  Future<void> _emitCachedState(Emitter<AuthState> emit) async {
    try {
      final user = await _authRepository.getStoredUser();
      final token = await _authRepository.getStoredToken();

      if (user != null && token != null && token.isNotEmpty) {
        final secureStorage = getIt.get<SecureStorageService>();
        final profileCompleted =
            await secureStorage.read(key: 'profile_completed');

        print('🔍 _emitCachedState - profile_completed: "$profileCompleted"');

        final hasCompleteData = user.currentWeight != null &&
            user.targetWeight != null &&
            user.height != null &&
            user.patientSegment.isNotEmpty &&
            user.patientSegment != 'general' &&
            user.phone != null &&
            user.phone!.isNotEmpty;

        print('🔍 _emitCachedState - hasCompleteData: $hasCompleteData');

        if (profileCompleted == 'true' && hasCompleteData) {
          emit(Authenticated(
            user: user,
            token: token,
          ));
        } else {
          emit(ProfileIncomplete(
            user: user,
            message: 'يرجى إكمال ملفك الشخصي',
          ));
        }
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      print('⚠️ Error emitting cached state: $e');
      emit(const Unauthenticated());
    }
  }

  // ============================================================
  // ✅ معالجة Login
  // ============================================================
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
        add(ClearAuthErrorEvent());
      },
      (response) {
        final state = response.toAuthState();
        emit(state);

        if (state is PendingSubscription) {
          add(StartSubscriptionPollingEvent(email: state.email));
        } else if (state is PendingDeviceApproval) {
          add(StartDevicePollingEvent(
              email: state.email, deviceId: event.deviceId));
        }
      },
    );
  }

  // ============================================================
  // ✅ معالجة Register
  // ============================================================
  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const LoginLoading());

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📝 Registering user: ${event.email}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final result = await _registerUseCase(RegisterParams(
      name: event.name.trim(),
      email: event.email.trim(),
      password: event.password,
      phone: event.phone.trim(),
    ));

    result.fold(
      (failure) {
        print('❌ Registration failed: ${failure.message}');
        emit(AuthError(message: failure.message));
      },
      (registerResult) {
        print('✅ Registration successful!');
        print('📧 Email: ${registerResult.email}');
        print('🆔 UserId: ${registerResult.userId}');
        print('💬 Message: ${registerResult.message}');

        emit(PendingSubscription(
          message: registerResult.message,
          email: registerResult.email,
          userId: registerResult.userId,
        ));
      },
    );
  }

  // ============================================================
  // ✅ معالجة ProfileCompletedEvent
  // ============================================================
  Future<void> _onProfileCompleted(
    ProfileCompletedEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('✅ ProfileCompletedEvent received for user: ${event.user.email}');

    // ✅ تحديث الحالة إلى Authenticated مع المستخدم المحدث
    emit(Authenticated(
      user: event.user,
      token: '',
      hasActiveSubscription: true,
    ));
  }

  // ============================================================
  // ✅ دوال Polling
  // ============================================================
  void _onStartSubscriptionPolling(
    StartSubscriptionPollingEvent event,
    Emitter<AuthState> emit,
  ) {
    _startSubscriptionPolling(emit, event.email);
  }

  void _onStartDevicePolling(
    StartDevicePollingEvent event,
    Emitter<AuthState> emit,
  ) {
    _startDevicePolling(emit, event.email, event.deviceId);
  }

  void _onStopPolling(
    StopPollingEvent event,
    Emitter<AuthState> emit,
  ) {
    _pollingTimer?.cancel();
    _pollingCount = 0;
  }

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

        if (_currentPollingEmail != null && _currentPollingDeviceId != null) {
          final result = await _authRepository.login(
            email: _currentPollingEmail!,
            password: '',
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

  // ============================================================
  // ✅ دوال أخرى
  // ============================================================
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

  void _onClearError(
    ClearAuthErrorEvent event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthError) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onCheckSubscriptionStatus(
    CheckSubscriptionStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
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

  Future<void> _onCheckDeviceApproval(
    CheckDeviceApprovalEvent event,
    Emitter<AuthState> emit,
  ) async {
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

  Future<String?> _getStoredPassword() async {
    return null;
  }

  bool get mounted => !isClosed;
}
