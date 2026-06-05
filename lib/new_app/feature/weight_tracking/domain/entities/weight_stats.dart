// lib/features/weight_tracking/domain/entities/weight_stats.dart

import 'dart:ui';

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

  @override
  List<Object?> get props => [entries, firstWeight, latestWeight, change];
}
