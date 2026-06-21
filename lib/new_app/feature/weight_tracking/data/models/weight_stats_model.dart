// lib/features/weight_tracking/data/models/weight_stats_model.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/weight_stats.dart';

class WeightStatsModel extends Equatable {
  final int entries;
  final double? firstWeight;
  final double? latestWeight;
  final double? change;

  const WeightStatsModel({
    required this.entries,
    this.firstWeight,
    this.latestWeight,
    this.change,
  });

  // ==================== FROM JSON ====================
  factory WeightStatsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return WeightStatsModel(
      entries: (data['entries'] as num?)?.toInt() ?? 0,
      firstWeight: (data['first_weight'] as num?)?.toDouble(),
      latestWeight: (data['latest_weight'] as num?)?.toDouble(),
      change: (data['change'] as num?)?.toDouble(),
    );
  }

  // ==================== TO JSON ====================
  Map<String, dynamic> toJson() {
    return {
      'entries': entries,
      'first_weight': firstWeight,
      'latest_weight': latestWeight,
      'change': change,
    };
  }

  // ==================== TO ENTITY ====================
  WeightStats toEntity() {
    return WeightStats(
      entries: entries,
      firstWeight: firstWeight,
      latestWeight: latestWeight,
      change: change,
    );
  }

  // ==================== FROM ENTITY ====================
  factory WeightStatsModel.fromEntity(WeightStats entity) {
    return WeightStatsModel(
      entries: entity.entries,
      firstWeight: entity.firstWeight,
      latestWeight: entity.latestWeight,
      change: entity.change,
    );
  }

  // ==================== COPY WITH ====================
  WeightStatsModel copyWith({
    int? entries,
    double? firstWeight,
    double? latestWeight,
    double? change,
  }) {
    return WeightStatsModel(
      entries: entries ?? this.entries,
      firstWeight: firstWeight ?? this.firstWeight,
      latestWeight: latestWeight ?? this.latestWeight,
      change: change ?? this.change,
    );
  }

  // ==================== FACTORY ====================
  factory WeightStatsModel.empty() {
    return const WeightStatsModel(entries: 0);
  }

  // ==================== GETTERS ====================
  bool get hasData => entries > 0;
  bool get hasFirstWeight => firstWeight != null && firstWeight! > 0;
  bool get hasLatestWeight => latestWeight != null && latestWeight! > 0;
  bool get hasChange => change != null;

  String get formattedChange {
    if (change == null) return '--';
    final prefix = change! > 0 ? '+' : '';
    return '$prefix${change!.toStringAsFixed(1)} كجم';
  }

  @override
  List<Object?> get props => [
        entries,
        firstWeight,
        latestWeight,
        change,
      ];
}
