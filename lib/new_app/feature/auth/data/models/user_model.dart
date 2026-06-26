// lib/features/auth/data/models/user_model.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// User model for data layer operations
/// Extends the domain entity and adds JSON serialization capabilities
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.avatar,
    super.avatarUrl,
    required super.role,
    required super.patientSegment,
    required super.isActive,
    required super.canScreenshot,
    super.idealWeight,
    super.currentWeight,
    super.height,
    super.targetWeight,
    required super.achievedGoal,
    required super.createdAt,
  });

  /// Factory method to create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String,
      patientSegment: json['patient_segment'] as String,
      isActive: json['is_active'] as bool,
      canScreenshot: json['can_screenshot'] as bool? ?? false,
      idealWeight: _parseDouble(json['ideal_weight']),
      currentWeight: _parseDouble(json['current_weight']),
      height: _parseDouble(json['height']),
      targetWeight: _parseDouble(json['target_weight']),
      achievedGoal: json['achieved_goal'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'avatar_url': avatarUrl,
      'role': role,
      'patient_segment': patientSegment,
      'is_active': isActive,
      'can_screenshot': canScreenshot,
      'ideal_weight': idealWeight,
      'current_weight': currentWeight,
      'height': height,
      'target_weight': targetWeight,
      'achieved_goal': achievedGoal,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Helper to parse double values that might be strings or null
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Create UserModel from domain User entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      avatar: user.avatar,
      avatarUrl: user.avatarUrl,
      role: user.role,
      patientSegment: user.patientSegment,
      isActive: user.isActive,
      canScreenshot: user.canScreenshot,
      idealWeight: user.idealWeight,
      currentWeight: user.currentWeight,
      height: user.height,
      targetWeight: user.targetWeight,
      achievedGoal: user.achievedGoal,
      createdAt: user.createdAt,
    );
  }

  /// Convert to domain entity
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      avatar: avatar,
      avatarUrl: avatarUrl,
      role: role,
      patientSegment: patientSegment,
      isActive: isActive,
      canScreenshot: canScreenshot,
      idealWeight: idealWeight,
      currentWeight: currentWeight,
      height: height,
      targetWeight: targetWeight,
      achievedGoal: achievedGoal,
      createdAt: createdAt,
    );
  }
}
