// lib/features/weight_tracking/domain/entities/weight_stats.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class WeightStats extends Equatable {
  final int entries;
  final double? firstWeight;
  final double? latestWeight;
  final double? change;

  const WeightStats({
    required this.entries,
    this.firstWeight,
    this.latestWeight,
    this.change,
  });

  // ==================== FROM JSON ====================
  factory WeightStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return WeightStats(
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

  // ==================== GETTERS ====================
  bool get hasData => entries > 0;

  String get formattedChange {
    if (change == null) return '--';
    final prefix = change! > 0 ? '+' : '';
    return '$prefix${change!.toStringAsFixed(1)} كجم';
  }

  Color get changeColor {
    if (change == null) return Colors.grey;
    return change! > 0 ? Colors.red : Colors.green;
  }

  String get changeEmoji {
    if (change == null) return '➖';
    if (change! > 1) return '📈';
    if (change! > 0) return '↗️';
    if (change! < -1) return '📉';
    if (change! < 0) return '↘️';
    return '➖';
  }

  String get formattedFirstWeight =>
      firstWeight != null ? '${firstWeight!.toStringAsFixed(1)} كجم' : '--';

  String get formattedLatestWeight =>
      latestWeight != null ? '${latestWeight!.toStringAsFixed(1)} كجم' : '--';

  @override
  List<Object?> get props => [entries, firstWeight, latestWeight, change];
}
