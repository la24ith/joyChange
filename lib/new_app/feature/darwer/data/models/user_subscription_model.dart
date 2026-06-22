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

  // ✅ من الشبكة (المفاتيح كما يرسلها الـ API)
  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;
    final subscriptionData = json['data'] ?? json;

    return UserSubscriptionModel(
      id: userData['id'] as int,
      name: userData['name'] as String,
      email: userData['email'] as String,
      avatarUrl: userData['avatar_url'] as String?,
      isActive: subscriptionData['active'] as bool? ??
          subscriptionData['is_active'] as bool? ??
          false,
      endDate: DateTime.parse(subscriptionData['end_date'] as String),
      status: subscriptionData['status'] as String,
    );
  }

  // ✅ من الـ Cache المحلي (مفاتيح ثابتة ومتسقة مع fromCache)
  factory UserSubscriptionModel.fromCache(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? false,
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String,
    );
  }

  // ✅ للحفظ في Hive (مفاتيح ثابتة تتوافق مع fromCache)
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

  factory UserSubscriptionModel.fromEntity(UserSubscription entity) {
    return UserSubscriptionModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatarUrl: entity.avatarUrl,
      isActive: entity.isActive,
      endDate: entity.endDate,
      status: entity.status,
    );
  }

  UserSubscription toEntity() => this;
}
