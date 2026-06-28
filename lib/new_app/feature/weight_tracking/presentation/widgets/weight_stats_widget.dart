// lib/features/weight_tracking/presentation/widgets/weight_stats_widget.dart

import 'package:flutter/material.dart';
import '../../domain/entities/weight_stats.dart';

class WeightStatsWidget extends StatelessWidget {
  final WeightStats stats;

  const WeightStatsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final crossAxisCount = isTablet ? 4 : 2;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _StatCard(
          title: 'عدد القياسات',
          value: stats.entries.toString(),
          icon: Icons.history,
          color: Colors.blue,
          isTablet: isTablet,
        ),
        _StatCard(
          title: 'أول قياس',
          value: stats.firstWeight != null
              ? '${stats.firstWeight!.toStringAsFixed(1)} كغ'
              : '--',
          icon: Icons.arrow_back,
          color: Colors.orange,
          isTablet: isTablet,
        ),
        _StatCard(
          title: 'آخر قياس',
          value: stats.latestWeight != null
              ? '${stats.latestWeight!.toStringAsFixed(1)} كغ'
              : '--',
          icon: Icons.arrow_forward,
          color: Colors.green,
          isTablet: isTablet,
        ),
        _StatCard(
          title: 'التغير',
          value: stats.formattedChange,
          icon: Icons.trending_up,
          color: stats.changeColor,
          isTablet: isTablet,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isTablet;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 10 : 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: isTablet ? 26 : 22, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 12 : 11,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
