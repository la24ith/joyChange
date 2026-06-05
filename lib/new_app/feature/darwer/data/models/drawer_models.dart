// lib/features/drawer/presentation/models/drawer_models.dart

import 'package:flutter/material.dart';

enum MenuItem {
  home,
  weights,
  diabetes,
  cubs,
  logout,
}

extension MenuItemExtension on MenuItem {
  String get title {
    switch (this) {
      case MenuItem.home:
        return 'الصفحة الرئيسية';
      case MenuItem.weights:
        return 'جميع الأوزان';
      case MenuItem.diabetes:
        return 'مرضى السكري';
      case MenuItem.cubs:
        return 'الأشبال';
      case MenuItem.logout:
        return 'تسجيل الخروج';
    }
  }

  IconData get icon {
    switch (this) {
      case MenuItem.home:
        return Icons.home_outlined;
      case MenuItem.weights:
        return Icons.monitor_weight_outlined;
      case MenuItem.diabetes:
        return Icons.medical_services_outlined;
      case MenuItem.cubs:
        return Icons.child_care_outlined;
      case MenuItem.logout:
        return Icons.logout_outlined;
    }
  }

  IconData get activeIcon {
    switch (this) {
      case MenuItem.home:
        return Icons.home_rounded;
      case MenuItem.weights:
        return Icons.monitor_weight_rounded;
      case MenuItem.diabetes:
        return Icons.medical_services_rounded;
      case MenuItem.cubs:
        return Icons.child_care_rounded;
      case MenuItem.logout:
        return Icons.logout_rounded;
    }
  }

  String get route {
    switch (this) {
      case MenuItem.home:
        return '/home';
      case MenuItem.weights:
        return '/weights';
      case MenuItem.diabetes:
        return '/diabetes';
      case MenuItem.cubs:
        return '/cubs';
      case MenuItem.logout:
        return '/login';
    }
  }
}
