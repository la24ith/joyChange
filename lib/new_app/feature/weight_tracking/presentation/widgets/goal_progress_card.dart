// lib/features/weight_tracking/presentation/widgets/goal_progress_card.dart

import 'package:flutter/material.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_colors.dart';
import '../../domain/entities/weight_goal_status.dart';

class GoalProgressCard extends StatelessWidget {
  final WeightGoalStatus status;

  const GoalProgressCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final progress = status.progress;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'التقدم نحو الهدف',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                if (status.hasGoal)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: status.achievedGoal
                          ? AppColors.successLight
                          : AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.achievedGoal ? 'تم الإنجاز 🎉' : 'قيد التقدم',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 11,
                        fontWeight: FontWeight.w600,
                        color: status.achievedGoal
                            ? AppColors.success
                            : AppColors.accent,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (status.hasGoal) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStat(
                        'الوزن الحالي',
                        status.formattedCurrentWeight,
                        Icons.monitor_weight,
                        isTablet,
                        context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStat(
                        'الوزن المستهدف',
                        status.formattedTargetWeight,
                        Icons.local_fire_department_sharp,
                        isTablet,
                        context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStat('المتبقي', status.formattedRemaining,
                        Icons.trending_down, isTablet, context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'نسبة التقدم',
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      Text(
                        status.formattedProgress,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor:
                          isDark ? Colors.grey[700] : Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation(Colors.teal),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.teal,
                      size: isTablet ? 28 : 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'لم يتم تحديد هدف بعد. قم بتعيين هدف وزنك لبدء تتبع تقدمك.',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? Colors.grey[800] : Colors.grey[100]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: isTablet ? 20 : 18,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      status.message,
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
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

  Widget _buildStat(String label, String value, IconData icon, bool isTablet,
      BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isTablet ? 12 : 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: isTablet ? 22 : 20, color: Colors.teal),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 11 : 10,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
