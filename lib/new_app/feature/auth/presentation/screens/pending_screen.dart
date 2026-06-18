// lib/features/auth/presentation/screens/pending_subscription_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/core/di/service_locator.dart';
import 'package:joy_of_change_v3/new_app/core/storage/secure_storage.dart';
import 'package:joy_of_change_v3/new_app/core/utils/device_info.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/data/models/auth_state_model.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/entities/user.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/pending_device_approval_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/profile_setup_screen.dart';
import '../../domain/usecases/check_auth_state_usecase.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class PendingSubscriptionScreen extends StatefulWidget {
  final String message;
  final String email;
  final int userId;
  final String password;

  const PendingSubscriptionScreen({
    super.key,
    required this.message,
    required this.email,
    required this.userId,
    required this.password,
  });

  @override
  State<PendingSubscriptionScreen> createState() =>
      _PendingSubscriptionScreenState();
}

class _PendingSubscriptionScreenState extends State<PendingSubscriptionScreen> {
  Timer? _timer;
  int _checkCount = 0;
  bool _isChecking = false;
  bool _autoLoginTriggered = false;

  static const int maxChecks = 20;
  static const int pollIntervalSeconds = 60;

  late final CheckAuthStateUseCase _checkAuthStateUseCase;

  @override
  void initState() {
    super.initState();
    _checkAuthStateUseCase = getIt<CheckAuthStateUseCase>();
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<String> _getDeviceId() async {
    try {
      final deviceInfoUtil = getIt<DeviceInfoUtil>();
      return await deviceInfoUtil.getDeviceId();
    } catch (e) {
      print('⚠️ Error getting device ID: $e');
      return 'fallback_device_id_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  void _startPeriodicCheck() {
    _timer =
        Timer.periodic(Duration(seconds: pollIntervalSeconds), (timer) async {
      if (_isChecking || _autoLoginTriggered) return;

      _checkCount++;
      if (mounted) setState(() {});

      await _checkAuthState();

      if (_checkCount >= maxChecks && mounted && !_autoLoginTriggered) {
        timer.cancel();
        _showTimeoutDialog();
      }
    });
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('انتهت مهلة الانتظار'),
        content: const Text(
          'لم يتم تفعيل اشتراكك خلال المدة المتوقعة.\n'
          'يرجى التواصل مع الدعم أو المحاولة لاحقاً.',
        ),
        actions: [
          TextButton(
            onPressed: _logout,
            child: const Text('تسجيل الخروج'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkCount = 0;
              _startPeriodicCheck();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkAuthState() async {
    if (_isChecking || _autoLoginTriggered) return;
    setState(() => _isChecking = true);

    try {
      final deviceId = await _getDeviceId();

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔄 Checking auth state (${_checkCount}/$maxChecks)');
      print('📧 Email: ${widget.email}');
      print('📱 Device ID: $deviceId');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final result = await _checkAuthStateUseCase(
        CheckAuthStateParams(
          email: widget.email,
          deviceId: deviceId,
          password: widget.password,
        ),
      );

      result.fold(
        (failure) {
          print('❌ Check auth state failed: ${failure.message}');
        },
        (authState) {
          print('✅ Auth state: ${authState.data.state}');
          print('📊 Code: ${authState.data.code}');

          _handleAuthState(authState);
        },
      );
    } catch (e) {
      print('❌ Error checking auth state: $e');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _handleAuthState(AuthStateModel authState) {
    final stateCode = authState.data.code;

    switch (stateCode) {
      case 'SUBSCRIPTION_INACTIVE':
      case 'NEEDS_SUBSCRIPTION':
        print('⏳ Still waiting for subscription activation...');
        break;

      case 'UNAPPROVED_DEVICE':
        if (!_autoLoginTriggered) {
          print('✅ Subscription activated! Triggering auto-login...');
          _timer?.cancel();
          _autoLoginTriggered = true;

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ تم تفعيل الاشتراك! جاري تسجيل الدخول...'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            _performAutoLogin();
          }
        }
        break;

      case 'ACTIVE':
        if (!_autoLoginTriggered) {
          print('✅ Already active! Auto-login to home...');
          _timer?.cancel();
          _autoLoginTriggered = true;
          _performAutoLogin();
        }
        break;

      default:
        print('⚠️ Unknown state: $stateCode');
    }
  }

  Future<void> _performAutoLogin() async {
    try {
      final deviceId = await _getDeviceId();

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔐 Performing auto-login');
      print('📧 Email: ${widget.email}');
      print('📱 Device ID: $deviceId');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (mounted) {
        context.read<AuthBloc>().add(
              LoginEvent(
                email: widget.email,
                password: widget.password,
                deviceId: deviceId,
              ),
            );
      }
    } catch (e) {
      print('❌ Auto-login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تسجيل الدخول: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    _timer?.cancel();
    context.read<AuthBloc>().add(LogoutEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            print('✅ Auto-login successful! User is authenticated');
            _timer?.cancel();

            // ✅ التحقق من اكتمال البروفايل محلياً
            _checkProfileCompletionAndNavigate(state.user);
          } else if (state is PendingDeviceApproval) {
            print('📱 Device pending approval - navigating to device approval');
            _timer?.cancel();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PendingDeviceApprovalScreen(
                  message: state.message,
                  email: state.email,
                  password: widget.password,
                ),
              ),
            );
          } else if (state is AuthError) {
            print('❌ Auth error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            _autoLoginTriggered = false;
            setState(() {});
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: _isChecking
                      ? const CircularProgressIndicator(
                          color: Colors.orange,
                          strokeWidth: 3,
                        )
                      : Icon(
                          Icons.pending_actions,
                          size: 60,
                          color: Colors.orange.shade700,
                        ),
                ),
                const SizedBox(height: 30),
                Text(
                  'في انتظار تفعيل الاشتراك',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'جاري التحقق تلقائياً... ($_checkCount/$maxChecks)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _checkCount / maxChecks,
                        backgroundColor: Colors.blue.shade100,
                        valueColor:
                            AlwaysStoppedAnimation(Colors.blue.shade700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'سيتم تفعيل اشتراكك قريباً من قبل المشرف.\n'
                          'سيتم تسجيل الدخول تلقائياً عند التفعيل.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: (_isChecking || _autoLoginTriggered)
                        ? null
                        : _checkAuthState,
                    icon: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(_isChecking ? 'جاري التحقق...' : 'التحقق الآن'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل الخروج'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ التحقق من اكتمال البروفايل والتنقل المناسب
  Future<void> _checkProfileCompletionAndNavigate(User user) async {
    try {
      final secureStorage = getIt.get<SecureStorageService>();
      final profileCompleted =
          await secureStorage.read(key: 'profile_completed');

      // ✅ التحقق من اكتمال البيانات أيضاً
      final hasCompleteData = user.currentWeight != null &&
          user.targetWeight != null &&
          user.height != null &&
          user.patientSegment.isNotEmpty &&
          user.patientSegment != 'general' &&
          user.phone != null &&
          user.phone!.isNotEmpty;

      if (profileCompleted == 'true' && hasCompleteData) {
        // ✅ الانتقال إلى الصفحة الرئيسية
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // ✅ الانتقال إلى صفحة إكمال البروفايل
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileSetupScreen(),
          ),
        );
      }
    } catch (e) {
      print('⚠️ Error checking profile completion: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileSetupScreen(),
        ),
      );
    }
  }
}
