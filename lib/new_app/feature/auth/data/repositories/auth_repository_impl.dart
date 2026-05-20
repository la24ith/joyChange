// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_ds.dart';
import '../datasources/auth_local_ds.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, LoginResponseModel>> login({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    try {
      final response = await remoteDataSource.login(
        email: email,
        password: password,
        deviceId: deviceId,
      );

      // If login successful, save token and user
      if (response.success && response.token != null && response.user != null) {
        await localDataSource.saveToken(response.token!);
        await localDataSource.saveUser(response.user!);
        await localDataSource.saveUserEmail(email);
      }

      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, RegisterResponse>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
  }) async {
    try {
      final result = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
      );

      return Right(RegisterResponse(
        message: result.message,
        userId: result.userId,
        email: result.email,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(
        message: e.message,
        errors: e.errors,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> checkSubscriptionStatus(String email) async {
    try {
      final isActive = await remoteDataSource.checkSubscriptionStatus(email);
      return Right(isActive);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to check subscription status',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> isSessionValid() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token != null && token.isNotEmpty);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAllAuthData();
      return const Right(null);
    } catch (e) {
      await localDataSource.clearAllAuthData();
      return const Right(null);
    }
  }

  @override
  Future<void> clearLocalAuthData() async {
    await localDataSource.clearAllAuthData();
  }

  @override
  Future<void> saveToken(String token) async {
    await localDataSource.saveToken(token);
  }

  @override
  Future<void> saveUser(User user) async {
    await localDataSource.saveUser(UserModel.fromEntity(user));
  }

  @override
  Future<String?> getStoredToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<User?> getStoredUser() async {
    final userModel = await localDataSource.getCachedUser();
    return userModel?.toEntity();
  }
}
