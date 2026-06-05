// lib/features/weight/data/models/ideal_status_model.dart
import 'package:equatable/equatable.dart';

class IdealStatusModel extends Equatable {
  final double currentWeight;
  final double targetWeight;
  final double idealWeight;
  final bool achievedGoal;
  final bool reached;
  final double? latestWeight;
  final double? firstWeight;
  final double remainingToGoal;
  final double? progressPercent;
  final String message;

  const IdealStatusModel({
    required this.currentWeight,
    required this.targetWeight,
    required this.idealWeight,
    required this.achievedGoal,
    required this.reached,
    this.latestWeight,
    this.firstWeight,
    required this.remainingToGoal,
    this.progressPercent,
    required this.message,
  });

  factory IdealStatusModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return IdealStatusModel(
      currentWeight: (data['current_weight'] as num?)?.toDouble() ?? 0,
      targetWeight: (data['target_weight'] as num?)?.toDouble() ?? 0,
      idealWeight: (data['ideal_weight'] as num?)?.toDouble() ?? 0,
      achievedGoal: data['achieved_goal'] as bool? ?? false,
      reached: data['reached'] as bool? ?? false,
      latestWeight: (data['latest_weight'] as num?)?.toDouble(),
      firstWeight: (data['first_weight'] as num?)?.toDouble(),
      remainingToGoal: (data['remaining_to_goal'] as num?)?.toDouble() ?? 0,
      progressPercent: (data['progress_percent'] as num?)?.toDouble(),
      message: data['message'] as String? ?? '',
    );
  }

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
