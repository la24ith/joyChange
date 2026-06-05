// lib/features/weight_tracking/presentation/widgets/current_weight_card.dart

import 'package:flutter/material.dart';
import '../../domain/entities/weight_goal_status.dart';

class CurrentWeightCard extends StatelessWidget {
  final WeightGoalStatus status;

  const CurrentWeightCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 28 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.shade600,
              Colors.teal.shade400,
            ],
          ),
          borderRadius: BorderRadius.circular(isTablet ? 32 : 28),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الوزن الحالي',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status.formattedCurrentWeight,
                      style: TextStyle(
                        fontSize: isTablet ? 48 : 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: isTablet ? 70 : 60,
                  height: isTablet ? 70 : 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.monitor_weight,
                    size: isTablet ? 40 : 32,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoItem(
                  'آخر قياس',
                  status.latestWeight != null
                      ? '${status.latestWeight!.toStringAsFixed(1)} كجم'
                      : '--',
                  Icons.history,
                  isTablet,
                ),
                const SizedBox(width: 16),
                _buildInfoItem(
                  'تاريخ آخر قياس',
                  status.latestWeight != null
                      ? _formatDate(status.latestRecordedDate)
                      : '--',
                  Icons.calendar_today,
                  isTablet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      String label, String value, IconData icon, bool isTablet) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: isTablet ? 20 : 18, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 11 : 10,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.day}/${date.month}/${date.year}';
  }
}

extension _WeightGoalStatusExtension on WeightGoalStatus {
  DateTime? get latestRecordedDate =>
      latestWeight != null ? DateTime.now() : null;
}
