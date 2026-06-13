// lib/features/auth/data/models/auth_state_model.dart

import 'package:equatable/equatable.dart';

/// Model for auth state response from /api/auth/state
class AuthStateModel extends Equatable {
  final bool success;
  final String message;
  final AuthStateDataModel data;

  const AuthStateModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AuthStateModel.fromJson(Map<String, dynamic> json) {
    return AuthStateModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: AuthStateDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}

/// Data model for auth state
class AuthStateDataModel extends Equatable {
  final bool canAccess;
  final String state;
  final String code;
  final String message;
  final SubscriptionDataModel? subscription;
  final DeviceDataModel? device;

  const AuthStateDataModel({
    required this.canAccess,
    required this.state,
    required this.code,
    required this.message,
    this.subscription,
    this.device,
  });

  factory AuthStateDataModel.fromJson(Map<String, dynamic> json) {
    return AuthStateDataModel(
      canAccess: json['can_access'] == true,
      state: json['state'] as String? ?? 'UNKNOWN',
      code: json['code'] as String? ?? 'UNKNOWN',
      message: json['message'] as String? ?? '',
      subscription: json['subscription'] != null
          ? SubscriptionDataModel.fromJson(
              json['subscription'] as Map<String, dynamic>)
          : null,
      device: json['device'] != null
          ? DeviceDataModel.fromJson(json['device'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props =>
      [canAccess, state, code, message, subscription, device];
}

/// Subscription data model
class SubscriptionDataModel extends Equatable {
  final int id;
  final bool active;
  final String status;
  final String planType;
  final String startDate;
  final String endDate;
  final int maxDevices;

  const SubscriptionDataModel({
    required this.id,
    required this.active,
    required this.status,
    required this.planType,
    required this.startDate,
    required this.endDate,
    required this.maxDevices,
  });

  factory SubscriptionDataModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionDataModel(
      id: json['id'] as int,
      active: json['active'] == true,
      status: json['status'] as String? ?? '',
      planType: json['plan_type'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      maxDevices: json['max_devices'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [id, active, status, planType, startDate, endDate, maxDevices];
}

/// Device data model
class DeviceDataModel extends Equatable {
  final int id;
  final String deviceId;
  final String? deviceName;
  final String? deviceType;
  final bool isApproved;
  final String status;

  const DeviceDataModel({
    required this.id,
    required this.deviceId,
    this.deviceName,
    this.deviceType,
    required this.isApproved,
    required this.status,
  });

  factory DeviceDataModel.fromJson(Map<String, dynamic> json) {
    return DeviceDataModel(
      id: json['id'] as int,
      deviceId: json['device_id'] as String? ?? '',
      deviceName: json['device_name'] as String?,
      deviceType: json['device_type'] as String?,
      isApproved: json['is_approved'] == true,
      status: json['status'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props =>
      [id, deviceId, deviceName, deviceType, isApproved, status];
}
