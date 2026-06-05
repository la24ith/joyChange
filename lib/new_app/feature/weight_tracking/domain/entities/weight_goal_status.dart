// lib/features/weight_tracking/domain/entities/weight_goal_status.dart

import 'package:equatable/equatable.dart';

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
  factory WeightGoalStatus.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return WeightGoalStatus(
      currentWeight: data['current_weight'] != null
          ? double.parse(data['current_weight'].toString())
          : null,
      targetWeight: data['target_weight'] != null
          ? double.parse(data['target_weight'].toString())
          : null,
      idealWeight: data['ideal_weight'] != null
          ? double.parse(data['ideal_weight'].toString())
          : null,
      achievedGoal: data['achieved_goal'] as bool? ?? false,
      reached: data['reached'] as bool? ?? false,
      latestWeight: data['latest_weight'] != null
          ? double.parse(data['latest_weight'].toString())
          : null,
      firstWeight: data['first_weight'] != null
          ? double.parse(data['first_weight'].toString())
          : null,
      remainingToGoal: data['remaining_to_goal'] != null
          ? double.parse(data['remaining_to_goal'].toString())
          : null,
      progressPercent: data['progress_percent'] != null
          ? double.parse(data['progress_percent'].toString())
          : null,
      message: data['message'] as String? ?? '',
    );
  }
  double get progress {
    if (progressPercent != null) return progressPercent! / 100;
    if (remainingToGoal != null && targetWeight != null && targetWeight! > 0) {
      final lost = (firstWeight ?? currentWeight ?? 0) -
          (latestWeight ?? currentWeight ?? 0);
      final total = (firstWeight ?? currentWeight ?? 0) - targetWeight!;
      if (total <= 0) return 1.0;
      return (lost / total).clamp(0.0, 1.0);
    }
    return 0;
  }

  bool get hasGoal => targetWeight != null;
  bool get hasIdealWeight => idealWeight != null;

  String get formattedCurrentWeight =>
      currentWeight != null ? '${currentWeight!.toStringAsFixed(1)} كجم' : '--';
  String get formattedTargetWeight =>
      targetWeight != null ? '${targetWeight!.toStringAsFixed(1)} كجم' : '--';
  String get formattedRemaining => remainingToGoal != null
      ? '${remainingToGoal!.toStringAsFixed(1)} كجم'
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
        message
      ];
}
