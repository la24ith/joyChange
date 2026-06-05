// lib/core/widgets/responsive_builder.dart

import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveInfo info) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    final isLandscape = screenWidth > screenHeight;

    final info = ResponsiveInfo(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      isMobile: isMobile,
      isTablet: isTablet,
      isDesktop: isDesktop,
      isLandscape: isLandscape,
      isPortrait: !isLandscape,
    );

    return builder(context, info);
  }
}

class ResponsiveInfo {
  final double screenWidth;
  final double screenHeight;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final bool isLandscape;
  final bool isPortrait;

  const ResponsiveInfo({
    required this.screenWidth,
    required this.screenHeight,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isLandscape,
    required this.isPortrait,
  });
}
