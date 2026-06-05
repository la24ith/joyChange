// lib/features/daily_commitment/presentation/widgets/commitment_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_colors.dart';
import '../bloc/daily_commitment_bloc.dart';
import '../bloc/daily_commitment_state.dart';

class CommitmentHeader extends StatelessWidget {
  const CommitmentHeader({super.key});

  String get _formattedDate {
    final now = DateTime.now();
    return '${_getDayName(now.weekday)}، ${now.day} ${_getMonthName(now.month)} ${now.year}';
  }

  String _getDayName(int weekday) {
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Back button and title row
        Row(
          children: [
            Expanded(
              child: Text(
                'السؤال اليومي',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 28 : 24,
                    ),
              ),
            ),
            // Stats indicator
            BlocBuilder<DailyCommitmentBloc, DailyCommitmentState>(
              builder: (context, state) {
                if (state is DailyCommitmentLoaded) {
                  final stats = state.stats;
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 12 : 10,
                      vertical: isTablet ? 6 : 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.stop_circle_sharp,
                          size: isTablet ? 16 : 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${stats.adherenceRate}%',
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Date
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 14 : 12,
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: isTablet ? 16 : 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formattedDate,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
