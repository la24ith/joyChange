import 'package:equatable/equatable.dart';

import '../../data/models/notification_hive_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationLoaded extends NotificationState {
  final List<NotificationHiveModel> notifications;

  const NotificationLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class NotificationLoading extends NotificationState {}

// ✅ إصلاح: تصحيح الأخطاء الإملائية في أسماء الـ states
class MarkAllReadLoading extends NotificationState {}

class MarkAllReadSuccessfully extends NotificationState {}

class NotificationInitial extends NotificationState {}
