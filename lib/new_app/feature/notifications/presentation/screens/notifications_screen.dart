import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/core/di/service_locator.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/presentation/bloc/notifications_event.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/presentation/bloc/notifications_state.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/presentation/screens/NotificationsView.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return BlocProvider(
      create: (_) => getIt<NotificationBloc>()
        ..add(
          LoadNotifications(),
        ),
      child: NotificationsView(),
    );
  }
}
