// lib/features/auth/presentation/screens/profile_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_colors.dart';
import 'package:joy_of_change_v3/new_app/core/di/service_locator.dart';
import 'package:joy_of_change_v3/new_app/core/storage/secure_storage.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/data/datasources/auth_local_ds.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/domain/usecases/update_profile_usecase.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/widget/custom_text_field.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/widget/gradient_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentWeightController =
      TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String? _selectedSegment;
  bool _isLoading = false;

  final List<Map<String, String>> _segments = [
    {'value': 'diabetic', 'label': 'مرضى السكري'},
    {'value': 'breastfeeding', 'label': 'الأمهات المرضعات'},
    {'value': 'weight_loss', 'label': 'إنقاص الوزن'},
    {'value': 'weight_gain', 'label': 'زيادة الوزن'},
    {'value': 'general', 'label': 'عام'},
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    try {
      final authBloc = context.read<AuthBloc>();
      final state = authBloc.state;

      if (state is Authenticated) {
        final user = state.user;
        _nameController.text = user.name;
        _phoneController.text = user.phone ?? '';
        _currentWeightController.text = user.currentWeight?.toString() ?? '';
        _targetWeightController.text = user.targetWeight?.toString() ?? '';
        _heightController.text = user.height?.toString() ?? '';
        if (user.patientSegment.isNotEmpty &&
            user.patientSegment != 'general') {
          _selectedSegment = user.patientSegment;
        }
      }
    } catch (e) {
      print('⚠️ Error loading existing data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    return null;
  }

  String? _validateWeight(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    final weight = double.tryParse(value);
    if (weight == null || weight <= 0) {
      return 'يرجى إدخال وزن صحيح';
    }
    if (weight > 500) {
      return 'الوزن لا يمكن أن يتجاوز 500 كغ';
    }
    return null;
  }

  String? _validateHeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال الطول';
    }
    final height = double.tryParse(value);
    if (height == null || height <= 0) {
      return 'يرجى إدخال طول صحيح';
    }
    if (height > 300) {
      return 'الطول لا يمكن أن يتجاوز 300 سم';
    }
    if (height < 50) {
      return 'الطول لا يمكن أن يكون أقل من 50 سم';
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSegment == null) {
      _showSnackBar('يرجى اختيار الفئة المناسبة', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updateProfileUseCase = getIt<UpdateProfileUseCase>();

      final result = await updateProfileUseCase(
        UpdateProfileParams(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          currentWeight: double.parse(_currentWeightController.text.trim()),
          targetWeight: double.parse(_targetWeightController.text.trim()),
          height: double.parse(_heightController.text.trim()),
          patientSegment: _selectedSegment!,
        ),
      );

      await result.fold(
        (failure) async {
          _showSnackBar(failure.message, isError: true);
          setState(() => _isLoading = false);
        },
        (user) async {
          // ✅ فقط بعد نجاح التحديث، نحفظ حالة الإكمال
          await _saveProfileCompleted();

          // ✅ تحديث المستخدم في AuthBloc
          if (mounted) {
            context.read<AuthBloc>().add(ProfileCompletedEvent(user));
          }

          _showSnackBar('✅ تم حفظ الملف الشخصي بنجاح', isError: false);
          setState(() => _isLoading = false);

          if (mounted) {
            Future.delayed(const Duration(milliseconds: 500), () {
              Get.offAllNamed('/home');
            });
          }
        },
      );
    } catch (e) {
      _showSnackBar('حدث خطأ: ${e.toString()}', isError: true);
      setState(() => _isLoading = false);
    }
  }

  /// ✅ حفظ حالة الإكمال - نسخة مبسطة للغاية
  Future<void> _saveProfileCompleted() async {
    try {
      // ✅ استخدام SecureStorage مباشرة
      final secureStorage = getIt.get<SecureStorageService>();

      // ✅ حفظ القيمة
      await secureStorage.write(key: 'profile_completed', value: 'true');
      print('✅ Profile completion saved: true');

      // ✅ تحقق فوري
      final saved = await secureStorage.read(key: 'profile_completed');
      print('🔍 Verification after save: "$saved"');

      // ✅ إذا لم تحفظ، حاول مرة أخرى
      if (saved != 'true') {
        print('⚠️ Save failed, retrying...');
        await secureStorage.write(key: 'profile_completed', value: 'true');
        final retry = await secureStorage.read(key: 'profile_completed');
        print('🔍 Retry verification: "$retry"');
      }
    } catch (e) {
      print('❌ Error saving profile: $e');
      // ✅ محاولة بديلة
      try {
        final secureStorage = getIt.get<SecureStorageService>();
        await secureStorage.write(key: 'profile_completed', value: 'true');
        print('✅ Fallback save successful');
      } catch (e2) {
        print('❌ Fallback also failed: $e2');
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إكمال الملف الشخصي'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _showExitDialog();
          },
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            _showSnackBar(state.message, isError: true);
            setState(() => _isLoading = false);
          }
        },
        child: Container(
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'يرجى إكمال ملفك الشخصي لتخصيص تجربتك.\nهذه المعلومات ضرورية لمتابعة تقدمك.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _nameController,
                        labelText: 'الاسم الكامل',
                        prefixIcon: Icons.person_outline,
                        validator: (value) => _validateRequired(value, 'الاسم'),
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _phoneController,
                        labelText: 'رقم الهاتف',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            _validateRequired(value, 'رقم الهاتف'),
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _currentWeightController,
                        labelText: 'الوزن الحالي (كغ)',
                        prefixIcon: Icons.monitor_weight_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) =>
                            _validateWeight(value, 'الوزن الحالي'),
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _targetWeightController,
                        labelText: 'الوزن المستهدف (كغ)',
                        prefixIcon: Icons.flag_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) =>
                            _validateWeight(value, 'الوزن المستهدف'),
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _heightController,
                        labelText: 'الطول (سم)',
                        prefixIcon: Icons.height,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: _validateHeight,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'اختر الفئة المناسبة لك',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: _segments.map((segment) {
                            final isSelected =
                                _selectedSegment == segment['value'];
                            return RadioListTile<String>(
                              title: Text(segment['label']!),
                              value: segment['value']!,
                              groupValue: _selectedSegment,
                              activeColor: Colors.teal.shade700,
                              onChanged: (value) {
                                setState(() {
                                  _selectedSegment = value;
                                });
                              },
                              tileColor: isSelected
                                  ? Colors.teal.shade50
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        label: 'حفظ الملف الشخصي',
                        isLoading: _isLoading,
                        onPressed: _saveProfile,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'يمكنك تعديل هذه المعلومات لاحقاً من الإعدادات',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الخروج'),
        content: const Text(
            'هل أنت متأكد من رغبتك في الخروج؟\nسيتم فقدان البيانات التي أدخلتها.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutEvent());
              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }
}
