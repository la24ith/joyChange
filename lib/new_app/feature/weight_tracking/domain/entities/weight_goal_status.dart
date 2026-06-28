// lib/features/weight_tracking/domain/entities/weight_goal_status.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class WeightGoalStatus extends Equatable {
  final double? currentWeight;
  final double? targetWeight;
  final double? idealWeight;
  final bool achievedGoal;
  final bool reached;
  final double? latestWeight;
  final double? firstWeight;
  final double? remainingToGoal;
  final double? progressPercent;
  final String message;

  const WeightGoalStatus({
    this.currentWeight,
    this.targetWeight,
    this.idealWeight,
    required this.achievedGoal,
    required this.reached,
    this.latestWeight,
    this.firstWeight,
    this.remainingToGoal,
    this.progressPercent,
    required this.message,
  });

  // ==================== FROM JSON ====================
  factory WeightGoalStatus.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      try {
        return (value as num).toDouble();
      } catch (e) {
        return null;
      }
    }

    bool parseBool(dynamic value, {bool defaultValue = false}) {
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is num) return value != 0;
      return defaultValue;
    }

    String parseString(dynamic value, {String defaultValue = ''}) {
      if (value == null) return defaultValue;
      return value.toString();
    }

    return WeightGoalStatus(
      currentWeight: parseDouble(data['current_weight']),
      targetWeight: parseDouble(data['target_weight']),
      idealWeight: parseDouble(data['ideal_weight']),
      achievedGoal: parseBool(data['achieved_goal']),
      reached: parseBool(data['reached']),
      latestWeight: parseDouble(data['latest_weight']),
      firstWeight: parseDouble(data['first_weight']),
      remainingToGoal: parseDouble(data['remaining_to_goal']),
      progressPercent: parseDouble(data['progress_percent']),
      message: parseString(data['message']),
    );
  }

  // ==================== TO JSON ====================
  Map<String, dynamic> toJson() {
    return {
      'current_weight': currentWeight,
      'target_weight': targetWeight,
      'ideal_weight': idealWeight,
      'achieved_goal': achievedGoal,
      'reached': reached,
      'latest_weight': latestWeight,
      'first_weight': firstWeight,
      'remaining_to_goal': remainingToGoal,
      'progress_percent': progressPercent,
      'message': message,
    };
  }

  // ==================== COPY WITH ====================
  WeightGoalStatus copyWith({
    double? currentWeight,
    double? targetWeight,
    double? idealWeight,
    bool? achievedGoal,
    bool? reached,
    double? latestWeight,
    double? firstWeight,
    double? remainingToGoal,
    double? progressPercent,
    String? message,
  }) {
    return WeightGoalStatus(
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      idealWeight: idealWeight ?? this.idealWeight,
      achievedGoal: achievedGoal ?? this.achievedGoal,
      reached: reached ?? this.reached,
      latestWeight: latestWeight ?? this.latestWeight,
      firstWeight: firstWeight ?? this.firstWeight,
      remainingToGoal: remainingToGoal ?? this.remainingToGoal,
      progressPercent: progressPercent ?? this.progressPercent,
      message: message ?? this.message,
    );
  }

  // ==================== FACTORY ====================
  factory WeightGoalStatus.empty() {
    return const WeightGoalStatus(
      achievedGoal: false,
      reached: false,
      message: '',
    );
  }

  // ==================== GETTERS ====================
  double get progress {
    if (progressPercent != null) {
      return (progressPercent! / 100).clamp(0.0, 1.0);
    }
    if (hasGoal && firstWeight != null && targetWeight != null) {
      final startWeight = firstWeight!;
      final target = targetWeight!;
      final current = latestWeight ?? currentWeight ?? startWeight;

      if (target < startWeight) {
        final lost = startWeight - current;
        final total = startWeight - target;
        if (total <= 0) return 1.0;
        return (lost / total).clamp(0.0, 1.0);
      } else if (target > startWeight) {
        final gained = current - startWeight;
        final total = target - startWeight;
        if (total <= 0) return 1.0;
        return (gained / total).clamp(0.0, 1.0);
      }
    }
    return 0.0;
  }

  bool get hasGoal => targetWeight != null && targetWeight! > 0;
  bool get hasIdealWeight => idealWeight != null && idealWeight! > 0;

  String get formattedCurrentWeight =>
      currentWeight != null ? '${currentWeight!.toStringAsFixed(1)} كغ' : '--';

  String get formattedTargetWeight =>
      targetWeight != null ? '${targetWeight!.toStringAsFixed(1)} كغ' : '--';

  String get formattedRemaining => remainingToGoal != null
      ? '${remainingToGoal!.toStringAsFixed(1)} كغ'
      : '--';

  String get formattedProgress => '${(progress * 100).toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [
        currentWeight,
        targetWeight,
        idealWeight,
        achievedGoal,
        reached,
        latestWeight,
        firstWeight,
        remainingToGoal,
        progressPercent,
        message,
      ];
}
