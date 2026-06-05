// lib/features/daily_commitment/domain/entities/daily_question.dart

import 'package:equatable/equatable.dart';

class DailyQuestion extends Equatable {
  final String question;
  final DailyEntry? entry;

  const DailyQuestion({
    required this.question,
    this.entry,
  });

  bool get isAnswered => entry?.answer != null;

  @override
  List<Object?> get props => [question, entry];
}

class DailyEntry extends Equatable {
  final int? id;
  final int userId;
  final DateTime date;
  final String? answer;
  final DateTime? answeredAt;
  final String? notes;

  const DailyEntry({
    this.id,
    required this.userId,
    required this.date,
    this.answer,
    this.answeredAt,
    this.notes,
  });

  @override
  List<Object?> get props => [id, userId, date, answer, answeredAt, notes];
}
