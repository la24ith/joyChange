// lib/features/auth/presentation/screens/pending_device_approval_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class PendingDeviceApprovalScreen extends StatefulWidget {
  final String message;
  final String email;

  const PendingDeviceApprovalScreen({
    super.key,
    required this.message,
    required this.email,
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
  static const int maxChecks = 30; // 5 minutes

  @override
  void initState() {
    super.initState();
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPeriodicCheck() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_isChecking) return;

      _checkCount++;
      if (mounted) setState(() {});

      await _checkDeviceStatus();

      if (_checkCount >= maxChecks) {
        timer.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('انتهت مهلة الانتظار. يرجى تسجيل الدخول لاحقاً.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    });
  }

  Future<void> _checkDeviceStatus() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    // Get device ID from storage
    final deviceId = await _getDeviceId();

    context.read<AuthBloc>().add(
          CheckDeviceApprovalEvent(
            email: widget.email,
            deviceId: deviceId,
          ),
        );

    setState(() => _isChecking = false);
  }

  Future<String> _getDeviceId() async {
    // TODO: Get device ID from DeviceInfoUtil
    return 'device_id_placeholder';
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
            _timer?.cancel();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ تم تفعيل جهازك! جاري تسجيل الدخول...'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
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
                          'سيتم تفعيل جهازك قريباً من قبل المشرف.\nيمكنك متابعة الحالة يدوياً بالضغط على زر التحقق.',
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
                    onPressed: (_isChecking || _checkCount >= maxChecks)
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
