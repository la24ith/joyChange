// lib/features/drawer/presentation/bloc/drawer_event.dart

import 'package:equatable/equatable.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/data/models/drawer_models.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/domain/entities/user_subscription.dart';

abstract class DrawerEvent extends Equatable {
  const DrawerEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserSubscriptionEvent extends DrawerEvent {}

class SelectMenuItemEvent extends DrawerEvent {
  final MenuItem selectedItem;

  const SelectMenuItemEvent({required this.selectedItem});

  @override
  List<Object?> get props => [selectedItem];
}

class LogoutRequestedEvent extends DrawerEvent {}

class SubscriptionUpdatedEvent extends DrawerEvent {
  final UserSubscription subscription;

  const SubscriptionUpdatedEvent({required this.subscription});

  @override
  List<Object?> get props => [subscription];
}
