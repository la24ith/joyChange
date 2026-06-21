// lib/features/daily_commitment/presentation/bloc/daily_commitment_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/entities/daily_answer.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/entities/daily_stats.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/usecases/save_pending_answer_usecase.dart';

import '../../domain/usecases/get_today_question_usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/usecases/get_answer_history_usecase.dart';
import '../../domain/usecases/submit_answer_usecase.dart';
import '../../domain/usecases/get_local_data_usecase.dart';
import '../../domain/usecases/save_local_data_usecase.dart';
import '../../domain/usecases/sync_pending_answers_usecase.dart';
import '../../data/models/local_commitment_data.dart';
import 'daily_commitment_state.dart';
import 'daily_commitment_event.dart';

class DailyCommitmentBloc
    extends Bloc<DailyCommitmentEvent, DailyCommitmentState> {
  final GetStatsUseCase _getStatsUseCase;
  final GetAnswerHistoryUseCase _getAnswerHistoryUseCase;
  final SubmitAnswerUseCase _submitAnswerUseCase;
  final GetLocalDataUseCase _getLocalDataUseCase;
  final SaveLocalDataUseCase _saveLocalDataUseCase;
  final SavePendingAnswerUseCase _savePendingAnswerUseCase;
  final SyncPendingAnswersUseCase _syncPendingAnswersUseCase;

  DailyCommitmentBloc({
    required GetStatsUseCase getStatsUseCase,
    required GetAnswerHistoryUseCase getAnswerHistoryUseCase,
    required SubmitAnswerUseCase submitAnswerUseCase,
    required GetLocalDataUseCase getLocalDataUseCase,
    required SaveLocalDataUseCase saveLocalDataUseCase,
    required SavePendingAnswerUseCase savePendingAnswerUseCase,
    required SyncPendingAnswersUseCase syncPendingAnswersUseCase,
  })  : _getStatsUseCase = getStatsUseCase,
        _getAnswerHistoryUseCase = getAnswerHistoryUseCase,
        _submitAnswerUseCase = submitAnswerUseCase,
        _getLocalDataUseCase = getLocalDataUseCase,
        _saveLocalDataUseCase = saveLocalDataUseCase,
        _savePendingAnswerUseCase = savePendingAnswerUseCase,
        _syncPendingAnswersUseCase = syncPendingAnswersUseCase,
        super(DailyCommitmentInitial()) {
    on<LoadDailyCommitmentEvent>(_onLoadData);
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<RefreshDailyCommitmentEvent>(_onRefresh);
  }

  // ============================================================================
  // 🔄 Load Data
  // ============================================================================

  Future<void> _onLoadData(
    LoadDailyCommitmentEvent event,
    Emitter<DailyCommitmentState> emit,
  ) async {
    try {
      // ⚡ Step 1: Load local data immediately (0ms)
      final localData = await _getLocalDataUseCase();

      emit(DailyCommitmentLoaded(
        question: localData.question,
        stats: DailyStats(
          total: localData.totalDays,
          yes: localData.yesCount,
          no: localData.noCount,
          skipped: localData.skippedCount,
          adherenceRate: localData.adherenceRate,
        ),
        history: const [],
        answeredToday: localData.answeredToday,
        todayAnswer: localData.todayAnswer,
        isFromCache: true,
        isSynced: localData.isSynced,
      ));

      // 🔄 Step 2: Sync in background
      _syncDataInBackground();
    } catch (e) {
      emit(DailyCommitmentError(
          message: 'Failed to load data: ${e.toString()}'));
    }
  }

  // ============================================================================
  // 📤 Submit Answer
  // ============================================================================

  Future<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<DailyCommitmentState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! DailyCommitmentLoaded) {
        emit(DailyCommitmentError(message: 'Please wait for data to load'));
        return;
      }

      // ⚡ Step 1: Update locally immediately
      final localData = await _getLocalDataUseCase();
      final updatedData = localData.updateWithAnswer(event.answer);
      await _saveLocalDataUseCase(updatedData);

      // 📝 Save for later sync
      await _savePendingAnswerUseCase(
        answer: event.answer,
        date: event.date,
        notes: event.notes,
      );

      // ✅ Show immediate success
      emit(DailyCommitmentLoaded(
        question: updatedData.question,
        stats: DailyStats(
          total: updatedData.totalDays,
          yes: updatedData.yesCount,
          no: updatedData.noCount,
          skipped: updatedData.skippedCount,
          adherenceRate: updatedData.adherenceRate,
        ),
        history: const [],
        answeredToday: true,
        todayAnswer: event.answer,
        isFromCache: true,
        isSynced: false,
      ));

      emit(DailyCommitmentSubmitted(
        message: event.answer == 'yes'
            ? '🎉 ممتاز! تم تسجيل التزامك'
            : '💪 تم تسجيل إجابتك، غداً يوم جديد',
      ));

      // 🔄 Step 2: Submit to server in background
      _submitToServerAndSync(event);
    } catch (e) {
      emit(DailyCommitmentError(
          message: 'Failed to submit answer: ${e.toString()}'));
    }
  }

  // ============================================================================
  // 🔄 Refresh
  // ============================================================================

  Future<void> _onRefresh(
    RefreshDailyCommitmentEvent event,
    Emitter<DailyCommitmentState> emit,
  ) async {
    add(LoadDailyCommitmentEvent());
  }

  // ============================================================================
  // 🔧 Private Methods
  // ============================================================================

  Future<void> _syncDataInBackground() async {
    try {
      // 1. Sync pending answers
      await _syncPendingAnswersUseCase();

      // 2. Fetch fresh data from server
      final statsResult = await _getStatsUseCase();
      final historyResult = await _getAnswerHistoryUseCase();

      if (statsResult.isRight() && historyResult.isRight()) {
        final stats = statsResult.getOrElse(() => throw Exception());
        final history = historyResult.getOrElse(() => []);

        // Check if answered today
        final today = DateTime.now();
        final answeredToday = history.any((item) {
          return item.date.year == today.year &&
              item.date.month == today.month &&
              item.date.day == today.day;
        });

        final todayAnswer = answeredToday
            ? history
                .firstWhere((item) {
                  return item.date.year == today.year &&
                      item.date.month == today.month &&
                      item.date.day == today.day;
                })
                .answer
                .value
            : null;

        // Update local data
        final localData = await _getLocalDataUseCase();
        final updatedData = localData.updateFromServer(
          total: stats.total,
          yes: stats.yes,
          no: stats.no,
          skipped: stats.skipped,
          adherenceRate: stats.adherenceRate,
          answeredToday: answeredToday,
          todayAnswer: todayAnswer,
        );
        await _saveLocalDataUseCase(updatedData);

        // Update UI if still open
        if (!isClosed) {
          add(RefreshDailyCommitmentEvent());
        }
      }
    } catch (e) {
      print('⚠️ Background sync failed: $e');
    }
  }

  Future<void> _submitToServerAndSync(SubmitAnswerEvent event) async {
    try {
      final result = await _submitAnswerUseCase(SubmitAnswerParams(
        answer: event.answer,
        date: event.date,
        notes: event.notes,
      ));

      result.fold(
        (failure) {
          print('❌ Server submission failed: ${failure.message}');
          // Will retry via sync pending answers
        },
        (answer) async {
          print('✅ Server submission successful');
          // Mark as synced
          final localData = await _getLocalDataUseCase();
          await _saveLocalDataUseCase(localData.markAsSynced());

          if (!isClosed) {
            add(RefreshDailyCommitmentEvent());
          }
        },
      );
    } catch (e) {
      print('❌ Background submission error: $e');
    }
  }
}
