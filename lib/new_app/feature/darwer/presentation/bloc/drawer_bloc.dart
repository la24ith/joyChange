// lib/features/drawer/presentation/bloc/drawer_bloc.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/data/models/drawer_models.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/domain/entities/user_subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'drawer_event.dart';
import 'drawer_state.dart';

class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  final SubscriptionRepository _subscriptionRepository;
  late final StreamSubscription<UserSubscription> _subscriptionStream;

  DrawerBloc({required SubscriptionRepository subscriptionRepository})
      : _subscriptionRepository = subscriptionRepository,
        super(DrawerInitial()) {
    on<LoadUserSubscriptionEvent>(_onLoadUserSubscription);
    on<SelectMenuItemEvent>(_onSelectMenuItem);
    on<LogoutRequestedEvent>(_onLogoutRequested);
    on<SubscriptionUpdatedEvent>(_onSubscriptionUpdated);

    _initSubscriptionStream();
  }

  void _initSubscriptionStream() {
    _subscriptionStream =
        _subscriptionRepository.watchUserSubscription().listen(
      (subscription) {
        add(SubscriptionUpdatedEvent(subscription: subscription));
      },
      onError: (error) {
        add(LoadUserSubscriptionEvent());
      },
    );
  }

  Future<void> _onLoadUserSubscription(
    LoadUserSubscriptionEvent event,
    Emitter<DrawerState> emit,
  ) async {
    emit(DrawerLoading());

    final result = await _subscriptionRepository.getUserSubscription();

    result.fold(
      (failure) => emit(DrawerError(message: failure.message)),
      (subscription) => emit(DrawerLoaded(
        subscription: subscription,
        selectedItem: MenuItem.home,
      )),
    );
  }

  Future<void> _onSelectMenuItem(
    SelectMenuItemEvent event,
    Emitter<DrawerState> emit,
  ) async {
    final currentState = state;
    if (currentState is DrawerLoaded) {
      emit(DrawerLoaded(
        subscription: currentState.subscription,
        selectedItem: event.selectedItem,
      ));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<DrawerState> emit,
  ) async {
    final result = await _subscriptionRepository.logout();

    result.fold(
      (failure) => emit(DrawerError(message: failure.message)),
      (_) => emit(DrawerLogoutSuccess()),
    );
  }

  Future<void> _onSubscriptionUpdated(
    SubscriptionUpdatedEvent event,
    Emitter<DrawerState> emit,
  ) async {
    final currentState = state;
    if (currentState is DrawerLoaded) {
      emit(DrawerLoaded(
        subscription: event.subscription,
        selectedItem: currentState.selectedItem,
      ));
    }
  }

  @override
  Future<void> close() {
    _subscriptionStream.cancel();
    return super.close();
  }
}
