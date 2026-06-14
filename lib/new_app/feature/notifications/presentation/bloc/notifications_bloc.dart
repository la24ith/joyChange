// feature/notifications/presentation/bloc/notifications_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/domain/entities/repository/notification_repository.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/presentation/bloc/notifications_event.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/presentation/bloc/notifications_state.dart';
import '../../data/models/notification_hive_model.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;
  StreamSubscription? _notificationsSubscription;
  bool _isLoading = false;

  NotificationBloc(this.repository) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<SyncNotifications>(_onSyncNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<MarkAllReadNotifications>(_onMarkAllRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<NotificationsUpdated>(_onNotificationsUpdated);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    await _notificationsSubscription?.cancel();

    _notificationsSubscription = repository.watchNotifications().listen(
      (notifications) {
        if (!isClosed) {
          add(NotificationsUpdated(notifications));
        }
      },
      onError: (error) {
        if (!isClosed) {
          emit(NotificationError(error.toString()));
        }
      },
    );

    final notifications = await repository.getNotifications();

    if (!isClosed) {
      emit(NotificationLoaded(notifications));
    }
  }

  Future<void> _onSyncNotifications(
    SyncNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.syncNotifications();
    } catch (e) {
      if (!isClosed) {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    add(SyncNotifications());
  }

  Future<void> _onMarkAllRead(
    MarkAllReadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (_isLoading) return;

    _isLoading = true;
    try {
      emit(MarkAllReadloading());
      await repository.markAllRead();
      if (!isClosed) {
        emit(MarkAllReadSuccesfuly());
      }
    } catch (e) {
      if (!isClosed) {
        emit(NotificationError(e.toString()));
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.deleteNotification(event.notificationId);
    } catch (e) {
      if (!isClosed) {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _onNotificationsUpdated(
    NotificationsUpdated event,
    Emitter<NotificationState> emit,
  ) async {
    if (!isClosed) {
      emit(NotificationLoaded(event.notifications));
    }
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}
