// lib/features/weight_tracking/presentation/bloc/weight_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/entities/weight_entry.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/entities/weight_goal_status.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/entities/weight_stats.dart';
import '../../domain/usecases/get_weights_usecase.dart';
import '../../domain/usecases/get_weight_stats_usecase.dart';
import '../../domain/usecases/get_weight_chart_usecase.dart';
import '../../domain/usecases/get_ideal_weight_status_usecase.dart';
import '../../domain/usecases/add_weight_usecase.dart';
import 'weight_event.dart';
import 'weight_state.dart';

class WeightBloc extends Bloc<WeightEvent, WeightState> {
  final GetWeightsUseCase _getWeightsUseCase;
  final GetWeightStatsUseCase _getWeightStatsUseCase;
  final GetWeightChartUseCase _getWeightChartUseCase;
  final GetIdealWeightStatusUseCase _getIdealWeightStatusUseCase;
  final AddWeightUseCase _addWeightUseCase;

  WeightBloc({
    required GetWeightsUseCase getWeightsUseCase,
    required GetWeightStatsUseCase getWeightStatsUseCase,
    required GetWeightChartUseCase getWeightChartUseCase,
    required GetIdealWeightStatusUseCase getIdealWeightStatusUseCase,
    required AddWeightUseCase addWeightUseCase,
  })  : _getWeightsUseCase = getWeightsUseCase,
        _getWeightStatsUseCase = getWeightStatsUseCase,
        _getWeightChartUseCase = getWeightChartUseCase,
        _getIdealWeightStatusUseCase = getIdealWeightStatusUseCase,
        _addWeightUseCase = addWeightUseCase,
        super(WeightInitial()) {
    on<LoadWeightsEvent>(_onLoadWeights);
    on<RefreshWeightsEvent>(_onRefreshWeights);
    on<AddWeightEvent>(_onAddWeight);
  }

  Future<void> _onLoadWeights(
    LoadWeightsEvent event,
    Emitter<WeightState> emit,
  ) async {
    emit(WeightLoading());

    // ✅ جلب البيانات بشكل متسلسل لتجنب مشاكل الأنواع
    final entriesResult = await _getWeightsUseCase();
    if (entriesResult.isLeft()) {
      emit(WeightError(message: 'فشل تحميل سجل الوزن'));
      return;
    }

    final statsResult = await _getWeightStatsUseCase();
    if (statsResult.isLeft()) {
      emit(WeightError(message: 'فشل تحميل إحصائيات الوزن'));
      return;
    }

    final chartResult = await _getWeightChartUseCase();
    if (chartResult.isLeft()) {
      emit(WeightError(message: 'فشل تحميل الرسم البياني'));
      return;
    }

    final statusResult = await _getIdealWeightStatusUseCase();
    if (statusResult.isLeft()) {
      emit(WeightError(message: 'فشل تحميل حالة الهدف'));
      return;
    }

    // ✅ استخراج القيم باستخدام getOrElse
    final entries = entriesResult.getOrElse(() => <WeightEntry>[]);
    final stats = statsResult.getOrElse(() => const WeightStats(entries: 0));
    final chartData = chartResult.getOrElse(() => <double>[]);
    final goalStatus = statusResult.getOrElse(() => const WeightGoalStatus(
          achievedGoal: false,
          reached: false,
          message: '',
        ));

    // ✅ التحقق من وجود بيانات
    if (entries.isEmpty) {
      emit(WeightEmpty());
    } else {
      emit(WeightLoaded(
        entries: entries,
        stats: stats,
        goalStatus: goalStatus,
        chartData: chartData,
      ));
    }
  }

  Future<void> _onRefreshWeights(
    RefreshWeightsEvent event,
    Emitter<WeightState> emit,
  ) async {
    add(LoadWeightsEvent());
  }

  Future<void> _onAddWeight(
    AddWeightEvent event,
    Emitter<WeightState> emit,
  ) async {
    final result = await _addWeightUseCase(AddWeightParams(
      weight: event.weight,
      date: event.date,
      notes: event.notes,
    ));

    result.fold(
      (failure) => emit(WeightError(message: failure.message)),
      (_) => add(LoadWeightsEvent()),
    );
  }
}
