// lib/features/daily_commitment/presentation/bloc/daily_commitment_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/entities/daily_answer.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/entities/daily_question.dart';
import '../../domain/usecases/get_today_question_usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/usecases/get_answer_history_usecase.dart';
import '../../domain/usecases/submit_answer_usecase.dart';
import 'daily_commitment_state.dart';
import 'daily_commitment_event.dart';

class DailyCommitmentBloc
    extends Bloc<DailyCommitmentEvent, DailyCommitmentState> {
  final GetStatsUseCase _getStatsUseCase;
  final GetAnswerHistoryUseCase _getAnswerHistoryUseCase;
  final SubmitAnswerUseCase _submitAnswerUseCase;

  DailyCommitmentBloc({
    required GetStatsUseCase getStatsUseCase,
    required GetAnswerHistoryUseCase getAnswerHistoryUseCase,
    required SubmitAnswerUseCase submitAnswerUseCase,
  })  : _getStatsUseCase = getStatsUseCase,
        _getAnswerHistoryUseCase = getAnswerHistoryUseCase,
        _submitAnswerUseCase = submitAnswerUseCase,
        super(DailyCommitmentInitial()) {
    on<LoadDailyCommitmentEvent>(_onLoadData);
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<RefreshDailyCommitmentEvent>(_onRefresh);
  }

  Future<void> _onLoadData(
    LoadDailyCommitmentEvent event,
    Emitter<DailyCommitmentState> emit,
  ) async {
    emit(DailyCommitmentLoading());

    final statsResult = await _getStatsUseCase();
    if (statsResult.isLeft()) {
      emit(DailyCommitmentError(message: 'فشل تحميل الإحصائيات'));
      return;
    }

    final historyResult = await _getAnswerHistoryUseCase();
    if (historyResult.isLeft()) {
      emit(DailyCommitmentError(message: 'فشل تحميل السجل'));
      return;
    }

    final question = const DailyQuestion(
      question: 'هل التزمت اليوم بعادتك الإيجابية؟',
      entry: null,
    );
    final stats = statsResult.getOrElse(() => throw Exception());
    final history = historyResult.getOrElse(() => []);
    final today = DateTime.now();

    final answeredToday = history.any((item) {
      return item.date.year == today.year &&
          item.date.month == today.month &&
          item.date.day == today.day;
    });

    emit(
      DailyCommitmentLoaded(
        question: question,
        stats: stats,
        history: history,
        answeredToday: answeredToday,
      ),
    );
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<DailyCommitmentState> emit,
  ) async {
    emit(DailyCommitmentSubmitting());

    final result = await _submitAnswerUseCase(SubmitAnswerParams(
      answer: event.answer,
      date: event.date,
      notes: event.notes,
    ));

    result.fold(
      (failure) => emit(DailyCommitmentError(message: failure.message)),
      (answer) {
        emit(DailyCommitmentSubmitted(
          message: answer.answer == AnswerType.yes
              ? '🎉 ممتاز! استمر بهذا الالتزام'
              : '💪 لا تقلق، غداً يوم جديد للالتزام',
        ));
        add(LoadDailyCommitmentEvent());
      },
    );
  }

  Future<void> _onRefresh(
    RefreshDailyCommitmentEvent event,
    Emitter<DailyCommitmentState> emit,
  ) async {
    add(LoadDailyCommitmentEvent());
  }
}
