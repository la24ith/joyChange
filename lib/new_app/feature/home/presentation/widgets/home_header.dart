// lib/features/home/presentation/widgets/home_header.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_colors.dart';
import 'package:joy_of_change_v3/new_app/core/constant/hive_boxes.dart';
import 'package:joy_of_change_v3/new_app/core/widgets/animation_button.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/notification_hive_model.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/presentation/screens/notifications_screen.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final double? screenWidth;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const HomeHeader({
    super.key,
    required this.userName,
    this.screenWidth,
    required this.scaffoldKey,
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
          AnimatedMenuButton(
            onTap: () {
              scaffoldKey.currentState?.openDrawer();
            },
          ),
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
              buildNotificationButton(),
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

  Widget buildNotificationButton() {
    final box = Hive.box<NotificationHiveModel>(
      notificationsBox,
    );

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<NotificationHiveModel> box, _) {
        final unreadCount =
            box.values.where((notification) => !notification.isRead).length;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                size: 28,
              ),
              onPressed: () {
                Get.to(() => const NotificationsPage());
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
