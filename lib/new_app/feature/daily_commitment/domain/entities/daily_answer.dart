// lib/features/daily_commitment/domain/entities/daily_answer.dart

import 'package:equatable/equatable.dart';

enum AnswerType { yes, no }

extension AnswerTypeExtension on AnswerType {
  String get value {
    switch (this) {
      case AnswerType.yes:
        return 'yes';
      case AnswerType.no:
        return 'no';
    }
  }

  static AnswerType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'yes':
        return AnswerType.yes;
      case 'no':
        return AnswerType.no;
      default:
        return AnswerType.yes;
    }
  }
}

class DailyAnswer extends Equatable {
  final int id;
  final int userId;
  final DateTime date;
  final AnswerType answer;
  final DateTime answeredAt;
  final String? notes;

  const DailyAnswer({
    required this.id,
    required this.userId,
    required this.date,
    required this.answer,
    required this.answeredAt,
    this.notes,
  });

  @override
  List<Object?> get props => [id, userId, date, answer, answeredAt, notes];
}
