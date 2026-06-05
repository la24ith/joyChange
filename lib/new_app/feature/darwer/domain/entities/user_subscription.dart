// lib/features/drawer/domain/entities/user_subscription.dart

import 'dart:ui';

import 'package:equatable/equatable.dart';

class UserSubscription extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isActive;
  final DateTime endDate;
  final String status;

  const UserSubscription({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.isActive,
    required this.endDate,
    required this.status,
  });

  String get formattedEndDate {
    return '${endDate.day}/${endDate.month}/${endDate.year}';
  }

  int get remainingDays {
    final now = DateTime.now();
    final remaining = endDate.difference(now).inDays;
    return remaining > 0 ? remaining : 0;
  }

  String get statusText {
    if (!isActive) return 'الاشتراك منتهي';
    if (remainingDays <= 7) return 'ينتهي قريباً';
    return 'مشترك فعال';
  }

  String get subscriptionDisplayName {
    switch (status.toLowerCase()) {
      case 'active':
        return 'اشتراك نشط';
      case 'inactive':
        return 'اشتراك غير نشط';
      case 'expired':
        return 'اشتراك منتهي';
      default:
        return status;
    }
  }

  Color get statusColor {
    if (!isActive) return const Color(0xFFEF4444);
    if (remainingDays <= 7) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  Color get subscriptionColor {
    if (!isActive) return const Color(0xFFEF4444);
    if (remainingDays <= 7) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        avatarUrl,
        isActive,
        endDate,
        status,
      ];
}
