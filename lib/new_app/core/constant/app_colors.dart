import 'package:flutter/material.dart';

class AppColors {
  // ========== ألوان العميل الجديدة ==========
  static const Color clientYellow = Color(0xFFFCD943); // #fcd943
  static const Color clientOrange = Color(0xFFF5A841); // #f5a841
  static const Color clientTeal = Color(0xFF239CA9); // #239ca9

  // ========== الألوان الأساسية المعاد تعيينها ==========
  // Primary (باستخدام اللون الفيروزي)
  static const Color primary = Color(0xFF239CA9); // clientTeal
  static const Color primaryLight = Color(0xFF4FB3C2); // أفتح قليلاً
  static const Color primaryDark = Color(0xFF1A7A85); // أغمق قليلاً

  // Secondary (باستخدام اللون البرتقالي)
  static const Color secondary = Color(0xFFF5A841); // clientOrange
  static const Color accent = Color(0xFFFCD943); // clientYellow

  // Gradient (تدرج لوني يجمع ألوان العميل)
  static const Color gradientStart = Color(0xFFFCD943); // أصفر
  static const Color gradientMiddle = Color(0xFFF5A841); // برتقالي
  static const Color gradientEnd = Color(0xFF239CA9); // فيروزي

  // ========== الألوان المساعدة (تبقى كما هي أو تعدل قليلاً) ==========
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
  static const Color info =
      Color(0xFF239CA9); // تعديل info ليتوافق مع اللون الأساسي

  // Light versions للاستخدام في الخلفيات
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color accentWarm = Color(0xFFF5A841);

  // ========== الظلال (تبقى كما هي) ==========
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
