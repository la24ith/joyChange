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

  bool _isSyncing = false;

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

      _syncDataInBackground();
    } catch (e) {
      emit(DailyCommitmentError(message: 'Failed to load data: ${e.toString()}'));
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

      // ⚡ Step 1: Optimistic local update
      final localData = await _getLocalDataUseCase();
      final updatedData = localData.updateWithAnswer(event.answer);
      await _saveLocalDataUseCase(updatedData);

      // ✅ Immediate UI feedback — before any network call
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

      // 🌐 Step 2: Try server directly — only save to pending queue if it fails
      _submitToServerOrQueue(event);
    } catch (e) {
      emit(DailyCommitmentError(message: 'Failed to submit answer: ${e.toString()}'));
    }
  }

  // ============================================================================
  // 🔄 Refresh (reads local only — no sync)
  // ============================================================================

  Future<void> _onRefresh(
    RefreshDailyCommitmentEvent event,
    Emitter<DailyCommitmentState> emit,
  ) async {
    try {
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
        isFromCache: false,
        isSynced: localData.isSynced,
      ));
    } catch (e) {
      emit(DailyCommitmentError(message: 'Failed to refresh: ${e.toString()}'));
    }
  }

  // ============================================================================
  // 🔧 Private Methods
  // ============================================================================

  /// Background sync: runs once at a time.
  /// Syncs any pending answers first, then pulls fresh server data.
  Future<void> _syncDataInBackground() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // Sync any answers that were queued while offline
      await _syncPendingAnswersUseCase();

      // Pull fresh stats + history from server
      final statsResult = await _getStatsUseCase();
      final historyResult = await _getAnswerHistoryUseCase();

      if (statsResult.isRight() && historyResult.isRight()) {
        final stats = statsResult.getOrElse(() => throw Exception());
        final history = historyResult.getOrElse(() => []);

        final today = DateTime.now();
        final answeredToday = history.any((item) =>
            item.date.year == today.year &&
            item.date.month == today.month &&
            item.date.day == today.day);

        final todayAnswer = answeredToday
            ? history
                .firstWhere((item) =>
                    item.date.year == today.year &&
                    item.date.month == today.month &&
                    item.date.day == today.day)
                .answer
                .value
            : null;

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

        // One Refresh to update UI — _onRefresh does NOT trigger another sync
        if (!isClosed) {
          add(RefreshDailyCommitmentEvent());
        }
      }
    } catch (e) {
      print('⚠️ Background sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Tries to submit directly to server.
  /// On success  → marks local data as synced (no pending queue used).
  /// On failure  → saves to pending queue so syncPendingAnswers retries later.
  Future<void> _submitToServerOrQueue(SubmitAnswerEvent event) async {
    try {
      final result = await _submitAnswerUseCase(SubmitAnswerParams(
        answer: event.answer,
        date: event.date,
        notes: event.notes,
      ));

      result.fold(
        (failure) async {
          // Network / server error → queue for later retry
          print('❌ Server submission failed: ${failure.message} — queuing for retry');
          await _savePendingAnswerUseCase(
            answer: event.answer,
            date: event.date,
            notes: event.notes,
          );
        },
        (answer) async {
          // Success → mark synced, no need to queue anything
          print('✅ Server submission successful');
          final localData = await _getLocalDataUseCase();
          await _saveLocalDataUseCase(localData.markAsSynced());
        },
      );
    } catch (e) {
      // Unexpected error → queue for later retry
      print('❌ Background submission error: $e — queuing for retry');
      await _savePendingAnswerUseCase(
        answer: event.answer,
        date: event.date,
        notes: event.notes,
      );
    }
  }
}
