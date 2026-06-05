// lib/features/weight_tracking/data/models/weight_entry_model.dart

import '../../domain/entities/weight_entry.dart';

class WeightEntryModel extends WeightEntry {
  const WeightEntryModel({
    required super.id,
    required super.weight,
    required super.recordedDate,
    required super.recordedBy,
    super.notes,
    super.bmi,
    required super.createdAt,
  });

  factory WeightEntryModel.fromJson(Map<String, dynamic> json) {
    return WeightEntryModel(
      id: json['id'] as int,
      weight: double.parse(json['weight'].toString()),
      recordedDate: DateTime.parse(json['recorded_date'] as String),
      recordedBy: json['recorded_by'] as int,
      notes: json['notes'] as String?,
      bmi: json['bmi'] != null ? double.parse(json['bmi'].toString()) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight.toString(),
      'recorded_date': recordedDate.toIso8601String().split('T')[0],
      'recorded_by': recordedBy,
      'notes': notes,
      'bmi': bmi?.toString(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  WeightEntry toEntity() => this;
}
