// lib/features/weight/data/models/ideal_status_model.dart
import 'package:equatable/equatable.dart';
import '../../../weight_tracking/domain/entities/weight_goal_status.dart';

class IdealStatusModel extends Equatable {
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

  const IdealStatusModel({
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
  factory IdealStatusModel.fromJson(Map<String, dynamic> json) {
    // دعم كل من json['data'] و json المباشر
    final data = json['data'] ?? json;

    // تحويل آمن للقيم
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

    return IdealStatusModel(
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

  // ==================== TO ENTITY ====================
  WeightGoalStatus toEntity() {
    return WeightGoalStatus(
      currentWeight: currentWeight,
      targetWeight: targetWeight,
      idealWeight: idealWeight,
      achievedGoal: achievedGoal,
      reached: reached,
      latestWeight: latestWeight,
      firstWeight: firstWeight,
      remainingToGoal: remainingToGoal,
      progressPercent: progressPercent,
      message: message,
    );
  }

  // ==================== FROM ENTITY ====================
  factory IdealStatusModel.fromEntity(WeightGoalStatus entity) {
    return IdealStatusModel(
      currentWeight: entity.currentWeight,
      targetWeight: entity.targetWeight,
      idealWeight: entity.idealWeight,
      achievedGoal: entity.achievedGoal,
      reached: entity.reached,
      latestWeight: entity.latestWeight,
      firstWeight: entity.firstWeight,
      remainingToGoal: entity.remainingToGoal,
      progressPercent: entity.progressPercent,
      message: entity.message,
    );
  }

  // ==================== COPY WITH ====================
  IdealStatusModel copyWith({
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
    return IdealStatusModel(
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

  // ==================== GETTERS ====================
  bool get hasData => currentWeight != null && currentWeight! > 0;
  bool get hasGoal => targetWeight != null && targetWeight! > 0;
  bool get hasIdealWeight => idealWeight != null && idealWeight! > 0;

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

  String get formattedProgress => '${(progress * 100).toStringAsFixed(1)}%';
  String get formattedCurrentWeight =>
      currentWeight != null ? '${currentWeight!.toStringAsFixed(1)} كجم' : '--';
  String get formattedTargetWeight =>
      targetWeight != null ? '${targetWeight!.toStringAsFixed(1)} كجم' : '--';
  String get formattedIdealWeight =>
      idealWeight != null ? '${idealWeight!.toStringAsFixed(1)} كجم' : '--';
  String get formattedRemaining => remainingToGoal != null
      ? '${remainingToGoal!.toStringAsFixed(1)} كجم'
      : '--';

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

  @override
  String toString() {
    return '''
IdealStatusModel(
  currentWeight: $currentWeight,
  targetWeight: $targetWeight,
  idealWeight: $idealWeight,
  achievedGoal: $achievedGoal,
  reached: $reached,
  latestWeight: $latestWeight,
  firstWeight: $firstWeight,
  remainingToGoal: $remainingToGoal,
  progressPercent: $progressPercent,
  message: $message
)''';
  }
}
