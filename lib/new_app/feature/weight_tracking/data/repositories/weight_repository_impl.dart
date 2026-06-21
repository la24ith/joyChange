// lib/features/weight_tracking/data/repositories/weight_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/weight_entry.dart';
import '../../domain/entities/weight_stats.dart';
import '../../domain/entities/weight_goal_status.dart';
import '../../domain/repositories/weight_repository.dart';
import '../datasources/weight_remote_ds.dart';
import '../datasources/weight_local_ds.dart';
import '../models/weight_entry_model.dart';
import '../models/weight_stats_model.dart';
import '../models/weight_chart_model.dart';

class WeightRepositoryImpl implements WeightRepository {
  final WeightRemoteDataSource remoteDataSource;
  final WeightLocalDataSource localDataSource;

  WeightRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ==================== GET WEIGHTS ====================
  @override
  Future<Either<Failure, List<WeightEntry>>> getWeights({
    bool forceRefresh = false,
  }) async {
    try {
      final hasValidCache = localDataSource.hasValidCache;
      final cachedEntries = localDataSource.getCachedWeightEntries();

      if (hasValidCache && cachedEntries != null && !forceRefresh) {
        _refreshWeightsInBackground();
        // ✅ استخدام toEntity() لتحويل القائمة
        return Right(cachedEntries.map((e) => e.toEntity()).toList());
      }

      final entries = await remoteDataSource.getWeights(
        etag: localDataSource.getETag(),
      );

      await localDataSource.cacheWeightEntries(entries);
      // ✅ استخدام toEntity() لتحويل القائمة
      return Right(entries.map((e) => e.toEntity()).toList());
    } on CacheNotModifiedException {
      final cachedEntries = localDataSource.getCachedWeightEntries();
      if (cachedEntries != null && cachedEntries.isNotEmpty) {
        return Right(cachedEntries.map((e) => e.toEntity()).toList());
      }
      return Left(UnknownFailure(
        message: 'Cache is empty but not modified',
      ));
    } on ServerException catch (e) {
      final cachedEntries = localDataSource.getCachedWeightEntries();
      if (cachedEntries != null && cachedEntries.isNotEmpty) {
        return Right(cachedEntries.map((e) => e.toEntity()).toList());
      }
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to load weights: ${e.toString()}',
      ));
    }
  }

  Future<void> _refreshWeightsInBackground() async {
    try {
      final entries = await remoteDataSource.getWeights(
        etag: localDataSource.getETag(),
      );
      await localDataSource.cacheWeightEntries(entries);
    } catch (e) {
      // تجاهل الأخطاء في التحديث الخلفي
    }
  }

  // ==================== GET WEIGHT STATS ====================
  @override
  Future<Either<Failure, WeightStats>> getWeightStats({
    bool forceRefresh = false,
  }) async {
    try {
      final hasValidCache = localDataSource.hasValidCache;
      final cachedStats = localDataSource.getCachedWeightStats();

      if (hasValidCache && cachedStats != null && !forceRefresh) {
        _refreshStatsInBackground();
        // ✅ استخدام toEntity() للتحويل
        return Right(cachedStats.toEntity());
      }

      final stats = await remoteDataSource.getWeightStats();
      await localDataSource.cacheWeightStats(stats);
      // ✅ استخدام toEntity() للتحويل
      return Right(stats.toEntity());
    } on ServerException catch (e) {
      final cachedStats = localDataSource.getCachedWeightStats();
      if (cachedStats != null) {
        return Right(cachedStats.toEntity());
      }
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to load weight stats: ${e.toString()}',
      ));
    }
  }

  Future<void> _refreshStatsInBackground() async {
    try {
      final stats = await remoteDataSource.getWeightStats();
      await localDataSource.cacheWeightStats(stats);
    } catch (e) {
      // تجاهل
    }
  }

  // ==================== GET WEIGHT CHART ====================
  @override
  Future<Either<Failure, List<double>>> getWeightChart({
    bool forceRefresh = false,
  }) async {
    try {
      final hasValidCache = localDataSource.hasValidCache;
      final cachedChart = localDataSource.getCachedWeightChart();

      if (hasValidCache && cachedChart != null && !forceRefresh) {
        _refreshChartInBackground();
        return Right(cachedChart.series);
      }

      final chart = await remoteDataSource.getWeightChart();
      await localDataSource.cacheWeightChart(chart);
      return Right(chart.series);
    } on ServerException catch (e) {
      final cachedChart = localDataSource.getCachedWeightChart();
      if (cachedChart != null) {
        return Right(cachedChart.series);
      }
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to load weight chart: ${e.toString()}',
      ));
    }
  }

  Future<void> _refreshChartInBackground() async {
    try {
      final chart = await remoteDataSource.getWeightChart();
      await localDataSource.cacheWeightChart(chart);
    } catch (e) {
      // تجاهل
    }
  }

  // ==================== GET IDEAL WEIGHT STATUS ====================
  @override
  Future<Either<Failure, WeightGoalStatus>> getIdealWeightStatus({
    bool forceRefresh = false,
  }) async {
    try {
      final hasValidCache = localDataSource.hasValidCache;
      final cachedStatus = localDataSource.getCachedWeightStatus();

      if (hasValidCache && cachedStatus != null && !forceRefresh) {
        _refreshStatusInBackground();
        return Right(cachedStatus);
      }

      final status = await remoteDataSource.getIdealWeightStatus();
      await localDataSource.cacheWeightStatus(status);
      return Right(status);
    } on ServerException catch (e) {
      final cachedStatus = localDataSource.getCachedWeightStatus();
      if (cachedStatus != null) {
        return Right(cachedStatus);
      }
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to load weight status: ${e.toString()}',
      ));
    }
  }

  Future<void> _refreshStatusInBackground() async {
    try {
      final status = await remoteDataSource.getIdealWeightStatus();
      await localDataSource.cacheWeightStatus(status);
    } catch (e) {
      // تجاهل
    }
  }

  // ==================== ADD WEIGHT ENTRY ====================
  @override
  Future<Either<Failure, void>> addWeightEntry({
    required double weight,
    required DateTime date,
    String? notes,
  }) async {
    try {
      await remoteDataSource.addWeightEntry(weight, date, notes: notes);
      await localDataSource.clearCache();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to add weight entry: ${e.toString()}',
      ));
    }
  }

  // ==================== CLEAR CACHE ====================
  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to clear cache: ${e.toString()}',
      ));
    }
  }

  // ==================== GET CACHE INFO ====================
  @override
  Future<Either<Failure, Map<String, dynamic>>> getCacheInfo() async {
    try {
      return Right(localDataSource.getCacheInfo());
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to get cache info: ${e.toString()}',
      ));
    }
  }
}
