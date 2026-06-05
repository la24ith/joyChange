// lib/features/weight_tracking/presentation/bloc/weight_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/weight_entry.dart';
import '../../domain/entities/weight_stats.dart';
import '../../domain/entities/weight_goal_status.dart';

abstract class WeightState extends Equatable {
  const WeightState();

  @override
  List<Object?> get props => [];
}

class WeightInitial extends WeightState {}

class WeightLoading extends WeightState {}

class WeightLoaded extends WeightState {
  final List<WeightEntry> entries;
  final WeightStats stats;
  final WeightGoalStatus goalStatus;
  final List<double> chartData;

  const WeightLoaded({
    required this.entries,
    required this.stats,
    required this.goalStatus,
    required this.chartData,
  });

  @override
  List<Object?> get props => [entries, stats, goalStatus, chartData];
}

class WeightEmpty extends WeightState {}

class WeightError extends WeightState {
  final String message;

  const WeightError({required this.message});

  @override
  List<Object?> get props => [message];
}
