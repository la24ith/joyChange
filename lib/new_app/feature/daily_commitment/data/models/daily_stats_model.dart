// lib/features/daily_commitment/data/models/daily_stats_model.dart

import '../../domain/entities/daily_stats.dart';

class DailyStatsModel extends DailyStats {
  const DailyStatsModel({
    required super.total,
    required super.yes,
    required super.no,
    required super.skipped,
    required super.adherenceRate,
  });

  factory DailyStatsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return DailyStatsModel(
      total: data['total'] as int,
      yes: data['yes'] as int,
      no: data['no'] as int,
      skipped: data['skipped'] as int,
      adherenceRate: data['adherence_rate'] as int,
    );
  }
}
