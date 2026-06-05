// lib/features/daily_commitment/data/models/daily_answer_model.dart

import '../../domain/entities/daily_answer.dart';

class DailyAnswerModel extends DailyAnswer {
  const DailyAnswerModel({
    required super.id,
    required super.userId,
    required super.date,
    required super.answer,
    required super.answeredAt,
    super.notes,
  });

  factory DailyAnswerModel.fromJson(Map<String, dynamic> json) {
    return DailyAnswerModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      date: DateTime.parse(json['date'] as String),
      answer: AnswerTypeExtension.fromString(json['answer'] as String),
      answeredAt: DateTime.parse(json['answered_at'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer.value,
      'notes': notes,
      'date': date.toIso8601String().split('T')[0],
    };
  }
}
