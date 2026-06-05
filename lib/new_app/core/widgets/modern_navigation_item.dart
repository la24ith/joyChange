// lib/core/widgets/modern_navigation_item.dart

import 'package:flutter/material.dart';

class ModernNavigationItem {
  final String label;
  final IconData icon;
  final Widget screen;

  const ModernNavigationItem({
    required this.label,
    required this.icon,
    required this.screen,
  });
}
