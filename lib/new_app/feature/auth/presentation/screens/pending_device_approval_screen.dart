// lib/features/auth/presentation/screens/pending_device_approval_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/core/di/service_locator.dart';
import 'package:joy_of_change_v3/new_app/core/utils/device_info.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/data/models/auth_state_model.dart';
import '../../domain/usecases/check_auth_state_usecase.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class PendingDeviceApprovalScreen extends StatefulWidget {
  final String message;
  final String email;
  final String password;

  const PendingDeviceApprovalScreen({
    super.key,
    required this.message,
    required this.email,
    required this.password,
  });

  @override
  State<PendingDeviceApprovalScreen> createState() =>
      _PendingDeviceApprovalScreenState();
}

class _PendingDeviceApprovalScreenState
    extends State<PendingDeviceApprovalScreen> {
  Timer? _timer;
  int _checkCount = 0;
  bool _isChecking = false;
  bool _autoLoginTriggered = false; // ✅ منع تكرار تسجيل الدخول

  static const int maxChecks = 20; // 20 محاولة (حوالي 20 دقيقة)
  static const int pollIntervalSeconds = 60; // كل 60 ثانية

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

      await _checkDeviceStatus();

      if (_checkCount >= maxChecks && mounted && !_autoLoginTriggered) {
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('انتهت مهلة الانتظار. يرجى تسجيل الدخول لاحقاً.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  Future<void> _checkDeviceStatus() async {
    if (_isChecking || _autoLoginTriggered) return;
    setState(() => _isChecking = true);

    try {
      final deviceId = await _getDeviceId();

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔄 Checking device approval (${_checkCount}/$maxChecks)');
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
          if (mounted && _checkCount % 3 == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ في التحقق: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (authState) {
          print('✅ Auth state: ${authState.data.state}');
          print('📊 Can access: ${authState.data.canAccess}');
          print(
              '📱 Device approved: ${authState.data.device?.isApproved ?? false}');

          _handleAuthState(authState);
        },
      );
    } catch (e) {
      print('❌ Error checking device status: $e');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _handleAuthState(AuthStateModel authState) {
    final stateCode = authState.data.code;
    final canAccess = authState.data.canAccess;
    final isDeviceApproved = authState.data.device?.isApproved ?? false;

    switch (stateCode) {
      case 'UNAPPROVED_DEVICE':
        // Still waiting for device approval
        print('⏳ Still waiting for device approval...');
        if (!isDeviceApproved) {
          print('📱 Device approval status: pending');
        }
        break;

      case 'ACTIVE':
        // ✅ Device is approved! Full access granted
        if (canAccess && isDeviceApproved && !_autoLoginTriggered) {
          print('✅✅✅ DEVICE APPROVED! Auto-login to home...');
          _timer?.cancel();
          _autoLoginTriggered = true;

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ تم تفعيل جهازك! جاري تسجيل الدخول...'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            _performAutoLogin();
          }
        }
        break;

      case 'NEEDS_SUBSCRIPTION':
      case 'SUBSCRIPTION_INACTIVE':
        // Subscription became inactive? This shouldn't happen, but handle it
        if (!_autoLoginTriggered) {
          print('⚠️ Subscription inactive while waiting for device approval');
          _timer?.cancel();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('انتهت صلاحية الاشتراك. يرجى التواصل مع الدعم.'),
                backgroundColor: Colors.orange,
              ),
            );
            _logout();
          }
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
      print('🔐 Device approved! Performing auto-login');
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
            // ✅ Login successful! Navigate to home
            print('✅✅✅ Auto-login successful! Navigating to home...');
            _timer?.cancel();

            // Save user data already handled by AuthRepositoryImpl
            // Navigate to home
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthError) {
            print('❌ Auth error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );

            // If auto-login failed, reset flag
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
                // ✅ أيقونة الجهاز
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: _isChecking
                      ? const CircularProgressIndicator(
                          color: Colors.purple,
                          strokeWidth: 3,
                        )
                      : Icon(
                          Icons.devices,
                          size: 60,
                          color: Colors.purple.shade700,
                        ),
                ),
                const SizedBox(height: 30),

                // ✅ عنوان الشاشة
                Text(
                  'في انتظار تفعيل الجهاز',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ رسالة الحالة
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 8),

                // ✅ البريد الإلكتروني
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

                // ✅ مؤشر التقدم
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

                // ✅ أيقونة التنبيه
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
                          'سيتم تفعيل جهازك قريباً من قبل المشرف.\nسيتم تسجيل الدخول تلقائياً عند التفعيل.',
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

                // ✅ زر التحقق اليدوي
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: (_isChecking || _autoLoginTriggered)
                        ? null
                        : _checkDeviceStatus,
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

                // ✅ زر تسجيل الخروج
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
}
