import 'package:flutter/material.dart';

class AppColors {
  //static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color gradientStart = Color(0xFFE8F5E9);
  static const Color gradientMiddle = Color(0xFFB2DFDB);
  static const Color gradientEnd = Color(0xFF80CBC4);
  // static const Color error = Color(0xFFD32F2F);
  // static const Color success = Color(0xFF388E3C);
  // static const Color warning = Color(0xFFFFA000);
  // Primary Colors
  static const Color primary = Color(0xFF6366F1); // Soft Purple
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Secondary Colors
  static const Color secondary = Color(0xFF8B5CF6); // Purple
  static const Color accent = Color(0xFF06B6D4); // Cyan

  // Background Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFFF59E0B);

//

  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color accentWarm = Color(0xFFF59E0B);
//static const Color gradientStart = Color(0xFF6366F1);
//static const Color gradientEnd = Color(0xFF10B981);
  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
