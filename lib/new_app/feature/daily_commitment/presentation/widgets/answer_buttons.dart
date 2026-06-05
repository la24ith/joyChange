// lib/features/daily_commitment/presentation/widgets/answer_buttons.dart

import 'package:flutter/material.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_colors.dart';

class AnswerButtons extends StatefulWidget {
  final VoidCallback onYesPressed;
  final VoidCallback onNoPressed;

  const AnswerButtons({
    super.key,
    required this.onYesPressed,
    required this.onNoPressed,
  });

  @override
  State<AnswerButtons> createState() => _AnswerButtonsState();
}

class _AnswerButtonsState extends State<AnswerButtons> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Column(
      children: [
        // Yes Button
        _buildAnswerButton(
          label: 'نعم',
          icon: Icons.check_circle_outline,
          color: AppColors.success,
          onPressed: widget.onYesPressed,
          isTablet: isTablet,
        ),
        const SizedBox(height: 16),

        // No Button
        _buildAnswerButton(
          label: 'لا',
          icon: Icons.close_outlined,
          color: AppColors.warning,
          onPressed: widget.onNoPressed,
          isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildAnswerButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _isPressed ? 0.97 : 1.0,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
              backgroundColor: color.withOpacity(0.15),
              foregroundColor: color,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(60),
                side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: isTablet ? 28 : 24),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
