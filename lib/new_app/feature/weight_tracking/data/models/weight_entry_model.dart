// lib/features/weight_tracking/data/models/weight_entry_model.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/weight_entry.dart';

class WeightEntryModel extends Equatable {
  final int id;
  final double weight;
  final DateTime recordedDate;
  final int recordedBy;
  final String? notes;
  final double? bmi;
  final DateTime createdAt;

  const WeightEntryModel({
    required this.id,
    required this.weight,
    required this.recordedDate,
    required this.recordedBy,
    this.notes,
    this.bmi,
    required this.createdAt,
  });

  // ==================== FROM JSON (single item) ====================
  factory WeightEntryModel.fromJson(Map<String, dynamic> json) {
    return WeightEntryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      // ✅ إصلاح: دعم num و String للـ weight
      weight: json['weight'] is num
          ? (json['weight'] as num).toDouble()
          : double.tryParse(json['weight']?.toString() ?? '0') ?? 0.0,
      // ✅ إصلاح: الـ API يرجع ISO timestamp كامل
      recordedDate: json['recorded_date'] != null
          ? DateTime.parse(json['recorded_date'] as String)
          : DateTime.now(),
      recordedBy: (json['recorded_by'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
      // ✅ إصلاح: دعم num و String للـ bmi
      bmi: json['bmi'] is num
          ? (json['bmi'] as num).toDouble()
          : double.tryParse(json['bmi']?.toString() ?? ''),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  // ==================== FROM JSON LIST (with pagination) ====================
  /// يدعم: { "data": [...], "meta": {...} }  أو  { "data": [...] }  أو  [...]
  static List<WeightEntryModel> fromJsonList(dynamic response) {
    List<dynamic> list;

    if (response is List) {
      list = response;
    } else if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) {
        list = data;
      } else {
        list = [];
      }
    } else {
      list = [];
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map((json) => WeightEntryModel.fromJson(json))
        .toList();
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

  // ==================== TO ENTITY ====================
  WeightEntry toEntity() {
    return WeightEntry(
      id: id,
      weight: weight,
      recordedDate: recordedDate,
      recordedBy: recordedBy,
      notes: notes,
      bmi: bmi,
      createdAt: createdAt,
    );
  }

  // ==================== FROM ENTITY ====================
  factory WeightEntryModel.fromEntity(WeightEntry entity) {
    return WeightEntryModel(
      id: entity.id,
      weight: entity.weight,
      recordedDate: entity.recordedDate,
      recordedBy: entity.recordedBy,
      notes: entity.notes,
      bmi: entity.bmi,
      createdAt: entity.createdAt,
    );
  }

  // ==================== COPY WITH ====================
  WeightEntryModel copyWith({
    int? id,
    double? weight,
    DateTime? recordedDate,
    int? recordedBy,
    String? notes,
    double? bmi,
    DateTime? createdAt,
  }) {
    return WeightEntryModel(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      recordedDate: recordedDate ?? this.recordedDate,
      recordedBy: recordedBy ?? this.recordedBy,
      notes: notes ?? this.notes,
      bmi: bmi ?? this.bmi,
      createdAt: createdAt ?? this.createdAt,
    );
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
      case 1: return 'الإثنين';
      case 2: return 'الثلاثاء';
      case 3: return 'الأربعاء';
      case 4: return 'الخميس';
      case 5: return 'الجمعة';
      case 6: return 'السبت';
      case 7: return 'الأحد';
      default: return '';
    }
  }

  @override
  List<Object?> get props => [id, weight, recordedDate, recordedBy, notes, bmi, createdAt];
}
