// lib/features/weight_tracking/presentation/widgets/weight_empty_state.dart

import 'package:flutter/material.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_colors.dart';

class WeightEmptyState extends StatelessWidget {


  const WeightEmptyState({super.key,});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isTablet ? 120 : 100,
              height: isTablet ? 120 : 100,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.monitor_weight_outlined,
                size: isTablet ? 60 : 50,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد قياسات',
              style: TextStyle(
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف أول قياس لبدء تتبع تقدمك',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 32),
         ],
        ),
      ),
    );
  }
}
