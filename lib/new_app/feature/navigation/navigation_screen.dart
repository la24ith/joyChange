// تعديل NavigationScreen لاستخدام الشاشة الجديدة

// lib/features/navigation/navigation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/core/services/notification_scheduler_service.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/presentation/screens/daily_commitment_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/presentation/bloc/drawer_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/presentation/bloc/drawer_event.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/notification_hive_model.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/presentation/bloc/notifications_event.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/presentation/bloc/weight_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/presentation/bloc/weight_event.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/presentation/screen/weight_screen.dart';
import '../../core/widgets/modern_bottom_navigation.dart';
import '../../core/widgets/modern_navigation_item.dart';
import '../../core/di/service_locator.dart';
import '../home/presentation/screens/home_screen.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WeightBloc>.value(
          value: getIt<WeightBloc>()..add(LoadWeightsEvent()),
        ),
        BlocProvider<DrawerBloc>.value(
          value: getIt<DrawerBloc>()..add(LoadUserSubscriptionEvent()),
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => getIt<NotificationBloc>()..add(SyncNotifications()),
        ),
      ],
      child: const _NavigationView(),
    );
  }
}

class _NavigationView extends StatelessWidget {
  const _NavigationView();

  @override
  Widget build(BuildContext context) {
    final List<ModernNavigationItem> navItems = [
      const ModernNavigationItem(
        label: 'الرئيسية',
        icon: Icons.home_outlined,
        screen: HomeScreen(),
      ),
      const ModernNavigationItem(
        label: 'الوزن',
        icon: Icons.monitor_weight_outlined,
        screen: WeightScreen(),
      ),
      const ModernNavigationItem(
        label: 'السؤال اليومي',
        icon: Icons.question_mark,
        screen: DailyCommitmentScreen(),
      ),
    ];

    return ModernBottomNavigation(
      items: navItems,
      initialIndex: 0,
      onTap: (index) {},
    );
  }
}
