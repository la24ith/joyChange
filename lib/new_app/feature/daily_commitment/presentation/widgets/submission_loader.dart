// lib/features/daily_commitment/presentation/widgets/submission_loader.dart

import 'package:flutter/material.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_colors.dart';

class SubmissionLoader extends StatelessWidget {
  const SubmissionLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 18 : 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: isTablet ? 24 : 20,
            height: isTablet ? 24 : 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'جاري تسجيل التزامك...',
            style: TextStyle(
              fontSize: isTablet ? 15 : 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
