// lib/features/daily_commitment/data/models/daily_question_model.dart

import '../../domain/entities/daily_question.dart';

class DailyQuestionModel extends DailyQuestion {
  const DailyQuestionModel({
    required super.question,
    super.entry,
  });

  factory DailyQuestionModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return DailyQuestionModel(
      question: data['question'] as String,
      entry: data['entry'] != null
          ? DailyEntryModel.fromJson(data['entry'])
          : null,
    );
  }
}

class DailyEntryModel extends DailyEntry {
  const DailyEntryModel({
    super.id,
    required super.userId,
    required super.date,
    super.answer,
    super.answeredAt,
    super.notes,
  });

  factory DailyEntryModel.fromJson(Map<String, dynamic> json) {
    return DailyEntryModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      date: DateTime.parse(json['date'] as String),
      answer: json['answer'] as String?,
      answeredAt: json['answered_at'] != null
          ? DateTime.parse(json['answered_at'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'answer': answer,
      'answered_at': answeredAt?.toIso8601String(),
      'notes': notes,
    };
  }
}
