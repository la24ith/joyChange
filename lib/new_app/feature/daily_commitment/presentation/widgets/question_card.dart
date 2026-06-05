import 'package:flutter/material.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_colors.dart';

class QuestionCard extends StatelessWidget {
  final bool isAnswered;
  final String? questionText;

  const QuestionCard({
    super.key,
    required this.isAnswered,
    this.questionText,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      transform: Matrix4.identity()..scale(isAnswered ? 0.98 : 1.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isTablet ? 40 : 32),
        decoration: BoxDecoration(
          gradient: isAnswered
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).cardColor,
                    AppColors.primaryLight.withOpacity(0.05),
                  ],
                ),
          color: isAnswered ? AppColors.successLight.withOpacity(0.3) : null,
          borderRadius: BorderRadius.circular(isTablet ? 32 : 28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAnswered ? Icons.celebration : Icons.track_changes,
                size: isTablet ? 56 : 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Question Text
            Text(
              isAnswered
                  ? 'تم تسجيل إجابتك!'
                  : (questionText ?? 'هل التزمت اليوم بالبرنامج؟'),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 28 : 24,
                    height: 1.3,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Subtitle
            if (!isAnswered)
              Text(
                'سجل تقدمك اليومي وحافظ على التزامك',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),

            if (isAnswered)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'تم الإرسال بنجاح',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
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
