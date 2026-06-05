// lib/features/home/presentation/widgets/sync_status.dart

import 'package:flutter/material.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_colors.dart';

class SyncStatus extends StatelessWidget {
  final double? screenWidth;

  const SyncStatus({super.key, this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final width = screenWidth ?? MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'جاري المزامنة...',
            style: TextStyle(
              fontSize: isTablet ? 13 : 12,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
