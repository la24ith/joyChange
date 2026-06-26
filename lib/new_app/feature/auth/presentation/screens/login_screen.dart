// lib/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_colors.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_strings.dart';
import 'package:joy_of_change_v3/new_app/core/di/service_locator.dart';
import 'package:joy_of_change_v3/new_app/core/services/screenshot_service.dart';
import 'package:joy_of_change_v3/new_app/core/storage/secure_storage.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/entities/user.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/pending_device_approval_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/pending_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/profile_setup_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/register_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/subscription_expired_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/widget/custom_text_field.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/widget/gradient_button.dart';
import 'package:joy_of_change_v3/new_app/feature/navigation/navigation_screen.dart';
import '../../../../core/di/service_locator.dart';
import 'package:get/get.dart';
import '../../../../core/utils/device_info.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onLoginSuccess});

  final VoidCallback? onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );
    if (!emailRegex.hasMatch(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
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

  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('استعادة كلمة المرور'),
        content: const Text(
          'سيتم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني المسجل',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني',
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoginLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is Authenticated) {
            _showSnackBar('تم تسجيل الدخول بنجاح', isError: false);
            // ✅ التحقق من اكتمال البروفايل محلياً
            _checkProfileCompletionAndNavigate(state.user);
          } else if (state is PendingSubscription) {
            _showSnackBar(state.message, isError: false);
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Get.to(
                  () => PendingSubscriptionScreen(
                    message: state.message,
                    email: state.email,
                    userId: state.userId,
                    password: _passwordController.text.trim(),
                  ),
                );
              }
            });
          } else if (state is SubscriptionInactive) {
            _showSnackBar(state.message, isError: true);
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Get.offAll(() => const SubscriptionExpiredScreen());
              }
            });
          } else if (state is PendingDeviceApproval) {
            _showSnackBar(state.message, isError: false);
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Get.to(() => PendingDeviceApprovalScreen(
                      message: state.message,
                      email: state.email,
                      password: _passwordController.text.trim(),
                    ));
              }
            });
          } else if (state is InvalidCredentials) {
            _showSnackBar(state.message, isError: true);
          } else if (state is AuthError) {
            _showSnackBar(state.message, isError: true);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final bool isLoading = state is LoginLoading;

            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.gradientStart,
                    AppColors.gradientMiddle,
                    AppColors.gradientEnd,
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogoSection(),
                        const SizedBox(height: 20),
                        _buildWelcomeText(),
                        const SizedBox(height: 40),
                        _buildFormSection(isLoading),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: const AssetImage('assets/icon/icon.png'),
          fit: BoxFit.contain,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade200.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      //  child: Image.asset('assets/icon/icon.png'),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          AppStrings.welcome,
          style: TextStyle(
            fontSize: 18,
            color: Colors.teal.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade900,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormSection(bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              controller: _emailController,
              labelText: 'البريد الإلكتروني',
              prefixIcon: Icons.email_outlined,
              focusNode: _emailFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: _obscurePassword,
              builder: (context, obscure, _) {
                return CustomTextField(
                  controller: _passwordController,
                  labelText: 'كلمة المرور',
                  prefixIcon: Icons.lock_outline,
                  obscureText: obscure,
                  focusNode: _passwordFocusNode,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _obscurePassword.value = !obscure;
                    },
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.teal.shade600,
                    ),
                  ),
                  validator: _validatePassword,
                );
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _showResetPasswordDialog,
                child: Text(
                  'نسيت كلمة المرور؟',
                  style: TextStyle(
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'تسجيل الدخول',
              isLoading: isLoading,
              onPressed: _handleLogin,
            ),
            const SizedBox(height: 20),
            //_buildSignUpRow(),
          ],
        ),
      ),
    );
  }

/*
  Widget _buildSignUpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ليس لديك حساب؟',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () => Get.to(() => const RegisterScreen()),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            'سجل الآن',
            style: TextStyle(
              color: Colors.teal.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
*/
  void _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // ✅ الحصول على deviceId
      final deviceId = await _getDeviceId();

      context.read<AuthBloc>().add(
            LoginEvent(
              email: _emailController.text.trim().toLowerCase(),
              password: _passwordController.text.trim(),
              deviceId: deviceId,
            ),
          );


    }
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

      // ✅ إذا كان البروفايل مكتملاً أو البيانات موجودة
      if (profileCompleted == 'true' && hasCompleteData) {
        Get.offAll(() => const NavigationScreen());
      } else {
        // ✅ إذا لم يكتمل البروفايل بعد
        Get.offAll(() => const ProfileSetupScreen());
      }
    } catch (e) {
      print('⚠️ Error checking profile completion: $e');
      // في حالة الخطأ، ننتقل إلى ProfileSetupScreen كإجراء آمن
      Get.offAll(() => const ProfileSetupScreen());
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 3 : 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
