// lib/features/auth/presentation/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_colors.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/login_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/pending_device_approval_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/widget/custom_text_field.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/widget/gradient_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _agreeTerms = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
    _agreeTerms.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
          title: const Text('إنشاء حساب جديد'),
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.error,
                  content: Text(state.message),
                ),
              );
            } else if (state is Authenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.success,
                  content: Text('تم إنشاء الحساب بنجاح'),
                ),
              );
              Navigator.pushReplacementNamed(context, '/login');
            } else if (state is PendingSubscription) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.orange,
                  content: Text(state.message),
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PendingDeviceApprovalScreen(
                    message: state.message,
                    email: state.email,
                  ),
                ),
              );
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
                          horizontal: 24, vertical: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
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
                                controller: _nameController,
                                labelText: 'الاسم الكامل',
                                prefixIcon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'يرجى إدخال الاسم الكامل';
                                  }
                                  if (value.trim().length < 3) {
                                    return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              CustomTextField(
                                controller: _emailController,
                                labelText: 'البريد الإلكتروني',
                                prefixIcon: Icons.email_outlined,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'يرجى إدخال البريد الإلكتروني';
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return 'يرجى إدخال بريد إلكتروني صحيح';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              CustomTextField(
                                controller: _phoneController,
                                labelText: 'رقم الهاتف',
                                keyboardType: TextInputType.phone,
                                prefixIcon: Icons.phone_outlined,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'يرجى إدخال رقم الهاتف';
                                  }
                                  if (value.trim().length < 8) {
                                    return 'يرجى إدخال رقم هاتف صحيح';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              ValueListenableBuilder<bool>(
                                valueListenable: _obscurePassword,
                                builder: (context, obscure, _) {
                                  return CustomTextField(
                                    controller: _passwordController,
                                    labelText: 'كلمة المرور',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: obscure,
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال كلمة المرور';
                                      }
                                      if (value.length < 6) {
                                        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 14),
                              ValueListenableBuilder<bool>(
                                valueListenable: _obscureConfirmPassword,
                                builder: (context, obscure, _) {
                                  return CustomTextField(
                                    controller: _confirmPasswordController,
                                    labelText: 'تأكيد كلمة المرور',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: obscure,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        _obscureConfirmPassword.value =
                                            !obscure;
                                      },
                                      icon: Icon(
                                        obscure
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.teal.shade600,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى تأكيد كلمة المرور';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'كلمتا المرور غير متطابقتين';
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              ValueListenableBuilder<bool>(
                                valueListenable: _agreeTerms,
                                builder: (context, agree, _) {
                                  return CheckboxListTile(
                                    value: agree,
                                    activeColor: Colors.teal.shade600,
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: const Text(
                                        'الموافقة على الشروط والأحكام'),
                                    onChanged: (value) {
                                      _agreeTerms.value = value ?? false;
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              GradientButton(
                                label: 'إنشاء حساب',
                                isLoading: isLoading,
                                onPressed: () {
                                  if (!_agreeTerms.value) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'يجب الموافقة على الشروط والأحكام'),
                                      ),
                                    );
                                    return;
                                  }
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                          RegisterEvent(
                                            name: _nameController.text.trim(),
                                            email: _emailController.text.trim(),
                                            password:
                                                _passwordController.text.trim(),
                                            /*   passwordConfirmation:
                                                _confirmPasswordController.text
                                                    .trim(),*/
                                            phone: _phoneController.text.trim(),
                                          ),
                                        );
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('لديك حساب بالفعل؟'),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen())),
                                    child: Text(
                                      'تسجيل الدخول',
                                      style: TextStyle(
                                        color: Colors.teal.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
