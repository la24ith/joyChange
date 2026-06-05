// lib/features/weight/presentation/widgets/achievement_badge.dart
import 'package:flutter/material.dart';

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade400,
            Colors.orange.shade600,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.emoji_events,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }
}
