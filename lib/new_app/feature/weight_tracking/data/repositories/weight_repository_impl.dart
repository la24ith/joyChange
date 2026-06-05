// lib/features/weight_tracking/data/repositories/weight_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/weight_entry.dart';
import '../../domain/entities/weight_stats.dart';
import '../../domain/entities/weight_goal_status.dart';
import '../../domain/repositories/weight_repository.dart';
import '../datasources/weight_remote_ds.dart';

class WeightRepositoryImpl implements WeightRepository {
  final WeightRemoteDataSource remoteDataSource;

  WeightRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<WeightEntry>>> getWeights() async {
    try {
      final entries = await remoteDataSource.getWeights();
      return Right(entries.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
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

  @override
  Future<Either<Failure, WeightStats>> getWeightStats() async {
    try {
      final stats = await remoteDataSource.getWeightStats();
      return Right(stats);
    } on ServerException catch (e) {
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

  @override
  Future<Either<Failure, List<double>>> getWeightChart() async {
    try {
      final chart = await remoteDataSource.getWeightChart();
      return Right(chart.series);
    } on ServerException catch (e) {
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

  @override
  Future<Either<Failure, WeightGoalStatus>> getIdealWeightStatus() async {
    try {
      final status = await remoteDataSource.getIdealWeightStatus();
      return Right(status);
    } on ServerException catch (e) {
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

  @override
  Future<Either<Failure, void>> addWeightEntry({
    required double weight,
    required DateTime date,
    String? notes,
  }) async {
    try {
      await remoteDataSource.addWeightEntry(weight, date, notes: notes);
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
}
