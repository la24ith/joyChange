// lib/features/auth/presentation/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_colors.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/pending_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/screens/profile_setup_screen.dart';
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

  bool _isLoading = false;
  late String password;
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
            onPressed: () => Get.offAllNamed('/login'),
          ),
          title: const Text('إنشاء حساب جديد'),
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is LoginLoading) {
              setState(() => _isLoading = true);
            } else {
              setState(() => _isLoading = false);
            }
            if (state is ProfileIncomplete) {
              _showSnackBar(state.message, isError: false);
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  Get.offAll(() => const ProfileSetupScreen());
                }
              });
            }
            if (state is Authenticated) {
              // ✅ تسجيل ناجح واشتراك فعال
              _showSnackBar('تم إنشاء الحساب بنجاح', isError: false);
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  Get.offAllNamed('/home');
                }
              });
            } else if (state is PendingSubscription) {
              // ✅ ✅ ✅ الحالة المهمة: بانتظار تفعيل الاشتراك
              print('🎯 Navigating to PendingSubscriptionScreen');
              _showSnackBar(state.message, isError: false);
              if (mounted) {
                // ✅ تأكد من تمرير الـ password
                Get.to(
                  () => PendingSubscriptionScreen(
                    message: state.message,
                    email: state.email,
                    userId: state.userId,
                    password:
                        _passwordController.text.trim(), // ✅ تأكد من وجود هذا
                  ),
                );
              }
            } else if (state is SubscriptionInactive) {
              _showSnackBar(state.message, isError: true);
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  Get.toNamed('/subscription-inactive',
                      arguments: state.message);
                }
              });
            } else if (state is PendingDeviceApproval) {
              _showSnackBar(state.message, isError: false);
              if (mounted) {
                Get.toNamed('/pending-device', arguments: {
                  'message': state.message,
                  'email': state.email,
                });
              }
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
                          horizontal: 24, vertical: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
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
                                    _showSnackBar(
                                        'يجب الموافقة على الشروط والأحكام',
                                        isError: true);
                                    return;
                                  }
                                  if (_formKey.currentState!.validate()) {
                                    password = _passwordController.text.trim();

                                    print('PASSWORD SAVED = $password');

                                    context.read<AuthBloc>().add(
                                          RegisterEvent(
                                            name: _nameController.text.trim(),
                                            email: _emailController.text
                                                .trim()
                                                .toLowerCase(),
                                            password: password,
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
                                    onPressed: () => Get.offAllNamed('/login'),
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

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }
}
