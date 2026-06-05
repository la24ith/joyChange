// lib/features/home/presentation/widgets/home_header.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_colors.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/presentation/screens/notifications_screen.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final double? screenWidth;

  const HomeHeader({
    super.key,
    required this.userName,
    this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final width = screenWidth ?? MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final titleFontSize = isTablet ? 32.0 : 28.0;
    final greetingFontSize = isTablet ? 16.0 : 14.0;
    final paddingTop = isTablet ? 60.0 : 48.0;

    return Container(
      padding: EdgeInsets.fromLTRB(20, paddingTop, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً بك 👋',
                style: TextStyle(
                  fontSize: greetingFontSize,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize,
                    ),
              ),
            ],
          ),
          Row(
            children: [
              _buildIconButton(
                icon: Icons.notifications_outlined,
                onTap: () {
                  // TODO: Navigate to notifications
                  Get.to(() => NotificationsPage());
                },
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                icon: Icons.settings_outlined,
                onTap: () {
                  // TODO: Navigate to settings
                  // Get.to(()=> SettingsScreen());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 22),
        onPressed: onTap,
        splashRadius: 24,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature قريباً'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
