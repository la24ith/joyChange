// lib/features/weight_tracking/presentation/bloc/weight_bloc.dart
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/entities/weight_entry.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/entities/weight_goal_status.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/entities/weight_stats.dart';
import '../../domain/repositories/weight_repository.dart';
import '../../domain/usecases/get_weights_usecase.dart';
import '../../domain/usecases/get_weight_stats_usecase.dart';
import '../../domain/usecases/get_weight_chart_usecase.dart';
import '../../domain/usecases/get_ideal_weight_status_usecase.dart';
import '../../domain/usecases/add_weight_usecase.dart';
import '../../domain/usecases/clear_cache_usecase.dart';
import 'weight_event.dart';
import 'weight_state.dart';

class WeightBloc extends Bloc<WeightEvent, WeightState> {
  final GetWeightsUseCase _getWeightsUseCase;
  final GetWeightStatsUseCase _getWeightStatsUseCase;
  final GetWeightChartUseCase _getWeightChartUseCase;
  final GetIdealWeightStatusUseCase _getIdealWeightStatusUseCase;
  final AddWeightUseCase _addWeightUseCase;
  final ClearCacheUseCase _clearCacheUseCase;
  // ✅ إصلاح: نحتاج الوصول المباشر لدالة إعادة تصفير علم الاحتفال
  // بالوزن المثالي عند فقدان المستخدم لهدفه (حتى يُحتفى به مجدداً لاحقاً).
  final WeightRepository _repository;

  Timer? _autoRefreshTimer;
  bool _isLoading = false;
  WeightLoaded? _lastLoadedState;
  DateTime? _lastRefreshTime;
  WeightGoalStatus? _previousGoalStatus;

  static const int _cacheDurationMinutes = 30;
  static const int _autoRefreshIntervalMinutes = 60;

  WeightBloc({
    required GetWeightsUseCase getWeightsUseCase,
    required GetWeightStatsUseCase getWeightStatsUseCase,
    required GetWeightChartUseCase getWeightChartUseCase,
    required GetIdealWeightStatusUseCase getIdealWeightStatusUseCase,
    required AddWeightUseCase addWeightUseCase,
    required ClearCacheUseCase clearCacheUseCase,
    required WeightRepository repository,
  })  : _getWeightsUseCase = getWeightsUseCase,
        _getWeightStatsUseCase = getWeightStatsUseCase,
        _getWeightChartUseCase = getWeightChartUseCase,
        _getIdealWeightStatusUseCase = getIdealWeightStatusUseCase,
        _addWeightUseCase = addWeightUseCase,
        _clearCacheUseCase = clearCacheUseCase,
        _repository = repository,
        super(WeightInitial()) {
    on<LoadWeightsEvent>(_onLoadWeights);
    on<RefreshWeightsEvent>(_onRefreshWeights);
    on<AddWeightEvent>(_onAddWeight);
    on<ClearCacheEvent>(_onClearCache);
    // ✅ إصلاح: تمت إزالة GetCacheInfoEvent — كان جسمه فارغاً بالكامل ولا
    // يفعل شيئاً. معلومات الكاش الآن تُقرأ مباشرة عبر GetCacheInfoUseCase
    // من الشاشة نفسها (انظر weight_screen.dart) لأنها بيانات عرضية فقط
    // ولا تحتاج المرور عبر دورة حياة الـ Bloc/State.
  }

  // ==================== LOAD WEIGHTS ====================
  Future<void> _onLoadWeights(
    LoadWeightsEvent event,
    Emitter<WeightState> emit,
  ) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      // عرض الكاش فوراً إذا كان موجوداً
      if (_lastLoadedState != null && !event.forceRefresh) {
        emit(_lastLoadedState!);
      } else if (_lastLoadedState == null) {
        emit(WeightLoading());
      }

      final results = await Future.wait([
        _getWeightsUseCase(forceRefresh: event.forceRefresh),
        _getWeightStatsUseCase(forceRefresh: event.forceRefresh),
        _getWeightChartUseCase(forceRefresh: event.forceRefresh),
        _getIdealWeightStatusUseCase(forceRefresh: event.forceRefresh),
      ]);

      final entriesResult = results[0] as Either<Failure, List<WeightEntry>>;
      final statsResult = results[1] as Either<Failure, WeightStats>;
      final chartResult = results[2] as Either<Failure, List<double>>;
      final statusResult = results[3] as Either<Failure, WeightGoalStatus>;

      // ✅ تحقق من وجود خطأ في الـ entries أولاً
      bool hasEntriesError = false;
      entriesResult.fold((f) => hasEntriesError = true, (_) {});

      final entries = entriesResult.fold(
        (failure) => _lastLoadedState?.entries ?? <WeightEntry>[],
        (data) => data,
      );

      final stats = statsResult.fold(
        (failure) => _lastLoadedState?.stats ?? const WeightStats(entries: 0),
        (data) => data,
      );

      final chartData = chartResult.fold(
        (failure) => _lastLoadedState?.chartData ?? <double>[],
        (data) => data,
      );

      final goalStatus = statusResult.fold(
        (failure) =>
            _lastLoadedState?.goalStatus ??
            const WeightGoalStatus(
                achievedGoal: false, reached: false, message: ''),
        (data) => data,
      );

      // ✅ إصلاح: إذا فقد المستخدم حالة "تحقيق الهدف" (مثلاً بعد زيادة وزن)
      // نعيد تصفير علم الاحتفال، حتى تظهر شاشة "🎉 مبروك" مجدداً في المرة
      // القادمة التي يحقق فيها هدفه، بدل أن تبقى مكتومة للأبد بعد أول مرة.
      if (_previousGoalStatus != null &&
          _previousGoalStatus!.reached &&
          !goalStatus.reached) {
        await _repository.resetGoalCelebrationFlag();
      }
      _previousGoalStatus = goalStatus;

      // ✅ إصلاح: WeightEmpty فقط إذا كان الـ API نجح وأرجع قائمة فارغة فعلاً
      // وليس عند وجود خطأ في الشبكة
      if (entries.isEmpty && !hasEntriesError && _lastLoadedState == null) {
        emit(WeightEmpty());
      } else {
        final newState = WeightLoaded(
          entries: entries,
          stats: stats,
          goalStatus: goalStatus,
          chartData: chartData,
          lastUpdate: DateTime.now(),
          isFromCache: !event.forceRefresh && _lastLoadedState != null,
        );
        _lastLoadedState = newState;
        _lastRefreshTime = DateTime.now();
        emit(newState);
      }

      _startAutoRefresh();
    } catch (e) {
      if (_lastLoadedState != null) {
        emit(_lastLoadedState!);
      } else {
        emit(WeightError(message: 'فشل تحميل البيانات: ${e.toString()}'));
      }
    } finally {
      _isLoading = false;
    }
  }

  // ==================== REFRESH WEIGHTS ====================
  Future<void> _onRefreshWeights(
    RefreshWeightsEvent event,
    Emitter<WeightState> emit,
  ) async {
    add(const LoadWeightsEvent(forceRefresh: true));
  }

  // ==================== ADD WEIGHT ====================
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
      (_) => add(const LoadWeightsEvent(forceRefresh: true)),
    );
  }

  // ==================== CLEAR CACHE ====================
  Future<void> _onClearCache(
    ClearCacheEvent event,
    Emitter<WeightState> emit,
  ) async {
    // ✅ إصلاح: سابقاً كان هذا الهاندلر يمسح فقط `_lastLoadedState` (الكاش
    // داخل الذاكرة)، ولا يستدعي أبداً `repository.clearCache()`، أي أن
    // الكاش الحقيقي المخزَّن في SharedPreferences لم يكن يُمسح إطلاقاً رغم
    // أن زر "مسح الكاش" في الواجهة كان يوحي بذلك.
    final result = await _clearCacheUseCase();
    await result.fold(
      (failure) async {
        emit(WeightError(message: failure.message));
      },
      (_) async {
        _lastLoadedState = null;
        _lastRefreshTime = null;
        emit(WeightLoading());
        add(const LoadWeightsEvent(forceRefresh: true));
      },
    );
  }

  // ==================== AUTO REFRESH ====================
  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      Duration(minutes: _autoRefreshIntervalMinutes),
      (_) {
        if (!isClosed && state is! WeightLoading) {
          if (_lastRefreshTime != null) {
            final age = DateTime.now().difference(_lastRefreshTime!);
            if (age.inMinutes >= _cacheDurationMinutes) {
              add(const LoadWeightsEvent(forceRefresh: true));
            } else {
              add(const LoadWeightsEvent(forceRefresh: false));
            }
          }
        }
      },
    );
  }

  // ==================== CLEANUP ====================
  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel();
    return super.close();
  }
}
