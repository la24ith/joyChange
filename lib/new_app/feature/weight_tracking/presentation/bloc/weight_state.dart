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
  final DateTime? lastUpdate;
  final bool isFromCache;

  const WeightLoaded({
    required this.entries,
    required this.stats,
    required this.goalStatus,
    required this.chartData,
    this.lastUpdate,
    this.isFromCache = false,
  });

  String get lastUpdateText {
    if (lastUpdate == null) return 'غير معروف';
    final diff = DateTime.now().difference(lastUpdate!);
    if (diff.inSeconds < 60) return 'منذ لحظات';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  bool get isDataStale {
    if (lastUpdate == null) return true;
    final age = DateTime.now().difference(lastUpdate!);
    return age.inMinutes >= 30;
  }

  @override
  List<Object?> get props => [
        entries,
        stats,
        goalStatus,
        chartData,
        lastUpdate,
        isFromCache,
      ];
}

class WeightEmpty extends WeightState {}

class WeightError extends WeightState {
  final String message;

  const WeightError({required this.message});

  @override
  List<Object?> get props => [message];
}
