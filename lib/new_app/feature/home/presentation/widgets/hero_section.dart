// lib/features/home/presentation/widgets/hero_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        double currentWeight = 0;
        double targetWeight = 0;

        if (state is Authenticated) {
          currentWeight = state.user.currentWeight ?? 0;
          targetWeight = state.user.targetWeight ?? 0;
        }

        final progress = targetWeight > 0 ? currentWeight / targetWeight : 0;
        final remainingWeight = targetWeight - currentWeight;

        return Container(
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
                color: Colors.teal.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Motivational Message
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getMotivationalMessage(progress),
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ✅ Progress Section
              if (currentWeight > 0 && targetWeight > 0) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'الوزن الحالي',
                        '${currentWeight.toStringAsFixed(1)} kg',
                        Icons.monitor_weight,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'الوزن المستهدف',
                        '${targetWeight.toStringAsFixed(1)} kg',
                        Icons.target,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ✅ Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'نسبة التقدم',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 10,
                      ),
                    ),
                    if (remainingWeight > 0) ...[
                      const SizedBox(height: 12),
                      Text(
                        '${remainingWeight.toStringAsFixed(1)} kg متبقي للهدف',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ] else ...[
                // ✅ No weight data state
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'أضف وزنك الحالي والمستهدف لمتابعة تقدمك',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage(double progress) {
    if (progress >= 1.0) {
      return '🎉 مبروك! لقد حققت وزنك المثالي!';
    } else if (progress >= 0.75) {
      return '💪 أنت قريب جداً من هدفك! استمر بهذا التقدم الرائع';
    } else if (progress >= 0.5) {
      return '🌟 ممتاز! أنت في منتصف الطريق، استمر بنفس الوتيرة';
    } else if (progress >= 0.25) {
      return '🚀 بداية قوية! استمر في الالتزام وستصل إلى هدفك';
    } else if (progress > 0) {
      return '✨ كل خطوة تقربك من هدفك، استمر في التقدم';
    } else {
      return '🌟 ابدأ رحلتك نحو الوزن المثالي اليوم!';
    }
  }
}
