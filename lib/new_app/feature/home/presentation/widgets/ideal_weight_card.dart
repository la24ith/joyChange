// lib/features/home/presentation/widgets/ideal_weight_card.dart

import 'package:flutter/material.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_colors.dart';

class IdealWeightCard extends StatelessWidget {
  final VoidCallback onDismiss;
  final double? screenWidth;

  const IdealWeightCard({
    super.key,
    required this.onDismiss,
    this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final width = screenWidth ?? MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final horizontalMargin = isTablet ? 24.0 : 16.0;
    final iconSize = isTablet ? 28.0 : 24.0;
    final titleFontSize = isTablet ? 18.0 : 16.0;
    final subtitleFontSize = isTablet ? 14.0 : 13.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 8),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.celebration,
                        color: AppColors.success,
                        size: iconSize,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🎉 تهانينا!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: titleFontSize,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'لقد وصلت إلى وزنك المثالي! حافظ على استمراريتك',
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: onDismiss,
                  splashRadius: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
