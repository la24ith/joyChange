import 'package:equatable/equatable.dart';
import 'package:joy_of_change_v3/new_app/feature/notifications/data/models/notification_hive_model.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsUpdated extends NotificationEvent {
  final List<NotificationHiveModel> notifications;

  const NotificationsUpdated(
    this.notifications,
  );

  @override
  List<Object?> get props => [notifications];
}

class DeleteNotificationEvent extends NotificationEvent {
  final int notificationId;

  const DeleteNotificationEvent(
    this.notificationId,
  );

  @override
  List<Object?> get props => [notificationId];
}

class ReadNotificationEvent extends NotificationEvent {
  final int notificationId;

  const ReadNotificationEvent(
    this.notificationId,
  );

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllReadNotifications extends NotificationEvent {}

class RefreshNotifications extends NotificationEvent {}

class SyncNotifications extends NotificationEvent {}

class LoadNotifications extends NotificationEvent {}
