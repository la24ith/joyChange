// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import 'package:joy_of_change_v3/new_app/feature/auth/data/models/auth_state_model.dart';
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

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📝 Login Response received');
      print('✅ Success: ${response.success}');
      print('🔑 Token present: ${response.token != null}');
      if (response.token != null) {
        print('🔑 Token: ${response.token!.substring(0, 20)}...');
      }
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // ✅ تأكد من حفظ token
      if (response.success &&
          response.token != null &&
          response.token!.isNotEmpty) {
        await localDataSource.saveToken(response.token!);
        print('✅ Token saved to local storage');

        // ✅ تحقق من أن token تم حفظه فعلاً
        final savedToken = await localDataSource.getToken();
        print(
            '🔑 Retrieved saved token: ${savedToken != null ? "Yes (${savedToken.substring(0, 20)}...)" : "No"}');
      } else {
        print('❌ No token to save!');
      }

      if (response.user != null) {
        await localDataSource.saveUser(response.user!);
        print('✅ User saved to local storage');
      }
      await localDataSource.saveDeviceId(deviceId);
      return Right(response);
    } catch (e) {
      print('❌ Login error: $e');
      return Left(ServerFailure(message: e.toString()));
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
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📝 Register API call');
      print('📧 Email: $email');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final result = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
      );

      print('✅ Register API success');
      print('📧 User email: ${result.email}');
      print('🆔 User ID: ${result.userId}');
      print('💬 Message: ${result.message}');

      return Right(RegisterResponse(
        message: result.message,
        userId: result.userId,
        email: result.email,
      ));
    } on ServerException catch (e) {
      print('❌ Server exception: ${e.message}');
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on BadRequestException catch (e) {
      print('❌ Bad request: ${e.message}');
      return Left(ValidationFailure(
        message: e.message,
        errors: e.errors,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      print('❌ Unknown error: $e');
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

  @override
  Future<Either<Failure, AuthStateModel>> checkAuthState({
    required String email,
    required String deviceId,
    String? password,
  }) async {
    try {
      final response = await remoteDataSource.checkAuthState(
        email: email,
        deviceId: deviceId,
        password: password,
      );
      return Right(response);
    } catch (e) {
      print('❌ Check auth state error: $e');
      return Left(ServerFailure(
        message: 'Failed to check authentication state: ${e.toString()}',
      ));
    }
  }
}
