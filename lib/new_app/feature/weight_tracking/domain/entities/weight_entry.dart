// lib/features/weight_tracking/domain/entities/weight_entry.dart
import 'package:equatable/equatable.dart';

class WeightEntry extends Equatable {
  final int id;
  final double weight;
  final DateTime recordedDate;
  final int recordedBy;
  final String? notes;
  final double? bmi;
  final DateTime createdAt;

  const WeightEntry({
    required this.id,
    required this.weight,
    required this.recordedDate,
    required this.recordedBy,
    this.notes,
    this.bmi,
    required this.createdAt,
  });

  // ==================== FROM JSON ====================
  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: (json['id'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      recordedDate: json['recorded_date'] != null
          ? DateTime.parse(json['recorded_date'] as String)
          : DateTime.now(),
      recordedBy: (json['recorded_by'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
      bmi: (json['bmi'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  // ==================== TO JSON ====================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight,
      'recorded_date': recordedDate.toIso8601String().split('T')[0],
      'recorded_by': recordedBy,
      'notes': notes,
      'bmi': bmi,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ==================== GETTERS ====================
  String get formattedDate {
    return '${recordedDate.day}/${recordedDate.month}/${recordedDate.year}';
  }

  String get formattedWeight {
    return '${weight.toStringAsFixed(1)} كجم';
  }

  String get dayName {
    switch (recordedDate.weekday) {
      case 1:
        return 'الإثنين';
      case 2:
        return 'الثلاثاء';
      case 3:
        return 'الأربعاء';
      case 4:
        return 'الخميس';
      case 5:
        return 'الجمعة';
      case 6:
        return 'السبت';
      case 7:
        return 'الأحد';
      default:
        return '';
    }
  }

  @override
  List<Object?> get props => [
        id,
        weight,
        recordedDate,
        recordedBy,
        notes,
        bmi,
        createdAt,
      ];
}
