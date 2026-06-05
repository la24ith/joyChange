// lib/features/drawer/presentation/bloc/drawer_state.dart
import 'package:joy_of_change_v3/new_app/feature/darwer/data/models/drawer_models.dart';

import 'package:equatable/equatable.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/domain/entities/user_subscription.dart';

abstract class DrawerState extends Equatable {
  const DrawerState();

  @override
  List<Object?> get props => [];
}

class DrawerInitial extends DrawerState {}

class DrawerLoading extends DrawerState {}

class DrawerLoaded extends DrawerState {
  final UserSubscription subscription;
  final MenuItem selectedItem;

  const DrawerLoaded({
    required this.subscription,
    required this.selectedItem,
  });

  @override
  List<Object?> get props => [subscription, selectedItem];
}

class DrawerError extends DrawerState {
  final String message;

  const DrawerError({required this.message});

  @override
  List<Object?> get props => [message];
}

class DrawerLogoutSuccess extends DrawerState {}
