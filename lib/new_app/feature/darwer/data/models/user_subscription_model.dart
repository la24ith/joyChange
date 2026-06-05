// lib/features/drawer/data/models/user_subscription_model.dart

import '../../domain/entities/user_subscription.dart';

class UserSubscriptionModel extends UserSubscription {
  const UserSubscriptionModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
    required super.isActive,
    required super.endDate,
    required super.status,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;
    final subscriptionData = json['data'] ?? json;

    return UserSubscriptionModel(
      id: userData['id'] as int,
      name: userData['name'] as String,
      email: userData['email'] as String,
      avatarUrl: userData['avatar_url'] as String?,
      isActive: subscriptionData['active'] as bool,
      endDate: DateTime.parse(subscriptionData['end_date'] as String),
      status: subscriptionData['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'end_date': endDate.toIso8601String().split('T')[0],
      'status': status,
    };
  }

  UserSubscription toEntity() => this;
}
