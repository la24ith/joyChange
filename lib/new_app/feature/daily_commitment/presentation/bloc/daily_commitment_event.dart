// lib/features/daily_commitment/presentation/bloc/daily_commitment_event.dart

import 'package:equatable/equatable.dart';

sealed class DailyCommitmentEvent extends Equatable {
  const DailyCommitmentEvent();

  @override
  List<Object?> get props => [];
}

final class LoadDailyCommitmentEvent extends DailyCommitmentEvent {}

final class SubmitAnswerEvent extends DailyCommitmentEvent {
  final String answer;
  final DateTime date;
  final String? notes;

  const SubmitAnswerEvent({
    required this.answer,
    required this.date,
    this.notes,
  });

  @override
  List<Object?> get props => [answer, date, notes];
}

final class RefreshDailyCommitmentEvent extends DailyCommitmentEvent {}
