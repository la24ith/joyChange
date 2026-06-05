// lib/features/daily_commitment/domain/entities/daily_stats.dart

import 'package:equatable/equatable.dart';

class DailyStats extends Equatable {
  final int total;
  final int yes;
  final int no;
  final int skipped;
  final int adherenceRate;

  const DailyStats({
    required this.total,
    required this.yes,
    required this.no,
    required this.skipped,
    required this.adherenceRate,
  });

  double get adherencePercentage => adherenceRate.toDouble();

  @override
  List<Object?> get props => [total, yes, no, skipped, adherenceRate];
}
