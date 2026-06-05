// lib/features/drawer/presentation/widgets/app_drawer.dart

import 'package:flutter/material.dart' hide DrawerHeader;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:joy_of_change_v3/new_app/core/di/service_locator.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/presentation/bloc/auth_event.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/data/models/drawer_models.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/domain/repositories/subscription_repository.dart';
import '../bloc/drawer_bloc.dart';
import '../bloc/drawer_event.dart';
import '../bloc/drawer_state.dart';
import 'drawer_header.dart';
import 'drawer_menu_item.dart';
import 'subscription_card.dart';
import 'logout_dialog.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DrawerBloc(
        subscriptionRepository: getIt<SubscriptionRepository>(),
      )..add(LoadUserSubscriptionEvent()),
      child: const _DrawerContent(),
    );
  }
}

class _DrawerContent extends StatelessWidget {
  const _DrawerContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return BlocListener<DrawerBloc, DrawerState>(
      listener: (context, state) {
        if (state is DrawerLogoutSuccess) {
          context.go('/login');
        }
        if (state is DrawerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Drawer(
        width: isTablet ? 320 : 280,
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const DrawerHeader(),
              const SizedBox(height: 8),
              const SubscriptionCard(),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<DrawerBloc, DrawerState>(
                  builder: (context, state) {
                    if (state is DrawerLoaded) {
                      return ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          DrawerMenuItem(
                            item: MenuItem.home,
                            isSelected: state.selectedItem == MenuItem.home,
                            onTap: () =>
                                _navigateToPage(context, MenuItem.home),
                          ),
                          DrawerMenuItem(
                            item: MenuItem.weights,
                            isSelected: state.selectedItem == MenuItem.weights,
                            onTap: () =>
                                _navigateToPage(context, MenuItem.weights),
                          ),
                          const Divider(height: 24, thickness: 1),
                          DrawerMenuItem(
                            item: MenuItem.diabetes,
                            isSelected: state.selectedItem == MenuItem.diabetes,
                            onTap: () =>
                                _navigateToPage(context, MenuItem.diabetes),
                          ),
                          DrawerMenuItem(
                            item: MenuItem.cubs,
                            isSelected: state.selectedItem == MenuItem.cubs,
                            onTap: () =>
                                _navigateToPage(context, MenuItem.cubs),
                          ),
                          const Divider(height: 24, thickness: 1),
                          DrawerMenuItem(
                            item: MenuItem.logout,
                            isSelected: false,
                            onTap: () => _showLogoutDialog(context),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, MenuItem item) {
    if (item == MenuItem.logout) return;

    //   context.read<DrawerBloc>().add(SelectMenuItemEvent(selectedItem: item));
    // context.push(item.route);
    //if (context.mounted) {
    //Navigator.pop(context);
    //}
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => const LogoutDialog(),
    ).then((shouldLogout) {
      if (shouldLogout == true && context.mounted) {
        context.read<AuthBloc>().add(LogoutEvent());
      }
    },);
  }
}
