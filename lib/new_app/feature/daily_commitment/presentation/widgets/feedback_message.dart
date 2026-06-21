// lib/features/daily_commitment/presentation/widgets/feedback_message.dart

import 'package:flutter/material.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_colors.dart';

class FeedbackMessage extends StatelessWidget {
  final String message;
  final bool isPositive;

  const FeedbackMessage({
    super.key,
    required this.message,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final safeOpacity = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: safeOpacity,
          child: Transform.scale(
            scale: safeOpacity,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPositive
                ? [AppColors.successLight, AppColors.success]
                : [AppColors.warningLight, AppColors.accentWarm],
          ),
          borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
          boxShadow: [
            BoxShadow(
              color: (isPositive ? AppColors.success : AppColors.accentWarm)
                  .withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPositive ? Icons.emoji_emotions : Icons.emoji_events,
                color: isPositive ? AppColors.success : AppColors.accentWarm,
                size: isTablet ? 32 : 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPositive ? '🎉 ممتاز!' : '💪 لا بأس',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
