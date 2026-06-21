// lib/features/daily_commitment/presentation/bloc/daily_commitment_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/daily_question.dart';
import '../../domain/entities/daily_answer.dart';
import '../../domain/entities/daily_stats.dart';

sealed class DailyCommitmentState extends Equatable {
  const DailyCommitmentState();

  @override
  List<Object?> get props => [];
}

final class DailyCommitmentInitial extends DailyCommitmentState {}

final class DailyCommitmentLoading extends DailyCommitmentState {}

final class DailyCommitmentSubmitting extends DailyCommitmentState {}

final class DailyCommitmentSubmitted extends DailyCommitmentState {
  final String message;

  const DailyCommitmentSubmitted({required this.message});

  @override
  List<Object?> get props => [message];
}

final class DailyCommitmentError extends DailyCommitmentState {
  final String message;

  const DailyCommitmentError({required this.message});

  @override
  List<Object?> get props => [message];
}

final class DailyCommitmentLoaded extends DailyCommitmentState {
  final String question;
  final DailyStats stats;
  final List<DailyAnswer> history;
  final bool answeredToday;
  final String? todayAnswer;
  final bool isFromCache;
  final bool isSynced;

  const DailyCommitmentLoaded({
    required this.question,
    required this.stats,
    required this.history,
    required this.answeredToday,
    this.todayAnswer,
    this.isFromCache = false,
    this.isSynced = true,
  });

  @override
  List<Object?> get props => [
        question,
        stats,
        history,
        answeredToday,
        todayAnswer,
        isFromCache,
        isSynced,
      ];
}
