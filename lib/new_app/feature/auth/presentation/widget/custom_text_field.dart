import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.focusNode,
    this.onFieldSubmitted,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.textInputAction,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines = 1,
    this.hintText,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.autofillHints,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final bool enabled;
  final int maxLines;
  final int minLines;
  final String? hintText;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final Iterable<String>? autofillHints;
  final bool autocorrect;
  final bool enableSuggestions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom label for better styling
        Padding(
          padding: const EdgeInsets.only(bottom: 8, right: 4),
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.teal.shade800,
              letterSpacing: 0.3,
            ),
          ),
        ),
        // Text Field
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          enabled: enabled,
          maxLines: obscureText ? 1 : maxLines,
          minLines: obscureText ? 1 : minLines,
          readOnly: readOnly,
          onChanged: onChanged,
          onTap: onTap,
          autofillHints: autofillHints,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: Colors.teal.shade600,
              size: 22,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: readOnly ? Colors.grey.shade100 : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.teal.shade400,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.red.shade300,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.red.shade500,
                width: 2,
              ),
            ),
            errorStyle: TextStyle(
              color: Colors.red.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// إضافة Extension method لسهولة الاستخدام
extension CustomTextFieldExtensions on CustomTextField {
  // يمكن إضافة دوال مساعدة هنا إذا لزم الأمر
}

// إضافة Widget منفصل لـ Phone Text Field (متخصص)
class PhoneTextField extends StatelessWidget {
  const PhoneTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: 'رقم الهاتف',
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال رقم الهاتف';
        }
        final phoneRegex = RegExp(r'^[0-9+]{8,15}$');
        if (!phoneRegex.hasMatch(value.trim())) {
          return 'يرجى إدخال رقم هاتف صحيح (8-15 رقم)';
        }
        return null;
      },
      autofillHints: const [AutofillHints.telephoneNumber],
    );
  }
}

// إضافة Widget منفصل لـ Email Text Field (متخصص)
class EmailTextField extends StatelessWidget {
  const EmailTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: 'البريد الإلكتروني',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
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
      },
      autofillHints: const [AutofillHints.email],
    );
  }
}

// إضافة Widget منفصل لـ Password Text Field (متخصص)
class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.next,
    this.labelText = 'كلمة المرور',
    this.confirmPasswordController,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction textInputAction;
  final String labelText;
  final TextEditingController? confirmPasswordController;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _obscurePassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscurePassword,
      builder: (context, obscure, _) {
        return CustomTextField(
          controller: widget.controller,
          labelText: widget.labelText,
          prefixIcon: Icons.lock_outline,
          obscureText: obscure,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
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
            if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
              return 'كلمة المرور يجب أن تحتوي على حروف وأرقام';
            }
            return null;
          },
          autofillHints: const [AutofillHints.password],
        );
      },
    );
  }
}
