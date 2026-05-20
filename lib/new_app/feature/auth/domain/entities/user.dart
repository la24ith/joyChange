// lib/features/auth/domain/entities/user.dart

import 'package:equatable/equatable.dart';

/// User entity representing the domain model
/// This is platform agnostic and doesn't depend on any external libraries
class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? avatarUrl;
  final String role;
  final String patientSegment;
  final bool isActive;
  final double? idealWeight;
  final double? currentWeight;
  final double? height;
  final double? targetWeight;
  final bool achievedGoal;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.avatarUrl,
    required this.role,
    required this.patientSegment,
    required this.isActive,
    this.idealWeight,
    this.currentWeight,
    this.height,
    this.targetWeight,
    required this.achievedGoal,
    required this.createdAt,
  });

  /// Helper to check if user has completed their profile
  bool get hasCompleteProfile {
    return currentWeight != null && height != null && targetWeight != null;
  }

  /// Helper to calculate BMI (if height and current weight available)
  double? get bmi {
    if (height == null || currentWeight == null) return null;
    final heightInMeters = height! / 100;
    return currentWeight! / (heightInMeters * heightInMeters);
  }

  /// Get BMI category
  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;

    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal weight';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  /// Helper to check if user achieved their target weight
  bool get hasAchievedTarget {
    if (targetWeight == null || currentWeight == null) return false;
    return currentWeight! <= targetWeight!;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatar,
        avatarUrl,
        role,
        patientSegment,
        isActive,
        idealWeight,
        currentWeight,
        height,
        targetWeight,
        achievedGoal,
        createdAt,
      ];

  /// Create a copy of user with updated fields
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? avatarUrl,
    String? role,
    String? patientSegment,
    bool? isActive,
    double? idealWeight,
    double? currentWeight,
    double? height,
    double? targetWeight,
    bool? achievedGoal,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      patientSegment: patientSegment ?? this.patientSegment,
      isActive: isActive ?? this.isActive,
      idealWeight: idealWeight ?? this.idealWeight,
      currentWeight: currentWeight ?? this.currentWeight,
      height: height ?? this.height,
      targetWeight: targetWeight ?? this.targetWeight,
      achievedGoal: achievedGoal ?? this.achievedGoal,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
