// lib/features/weight_tracking/data/models/weight_stats_model.dart

import '../../domain/entities/weight_stats.dart';

class WeightStatsModel extends WeightStats {
  const WeightStatsModel({
    required super.entries,
    super.firstWeight,
    super.latestWeight,
    super.change,
  });

  factory WeightStatsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return WeightStatsModel(
      entries: data['entries'] as int,
      firstWeight: data['first_weight'] != null
          ? double.parse(data['first_weight'].toString())
          : null,
      latestWeight: data['latest_weight'] != null
          ? double.parse(data['latest_weight'].toString())
          : null,
      change: data['change'] != null
          ? double.parse(data['change'].toString())
          : null,
    );
  }
}
