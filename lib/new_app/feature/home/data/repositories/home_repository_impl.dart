// lib/features/home/data/repositories/home_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_ds.dart';
import '../datasources/home_local_ds.dart';
import '../models/post_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Post>>> getPosts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // ✅ حاول جلب البيانات من الشبكة
      final posts = await remoteDataSource.getPosts(page: page, limit: limit);
      final entities = posts.map((p) => p.toEntity()).toList();

      // ✅ خزّن الصفحة الأولى فقط محلياً (الأكثر أهمية)
      if (page == 1) {
        await cachePosts(entities);
      }

      return Right(entities);
    } on ServerException catch (e) {
      // ✅ عند فشل الشبكة لأي صفحة، ارجع بيانات الـ Cache
      if (hasCachedPosts()) {
        final cached = getCachedPosts();
        if (cached.isNotEmpty) {
          // للصفحة الأولى: أرجع كل الـ Cache
          // لباقي الصفحات: أرجع قائمة فارغة حتى لا يستمر في التحميل
          if (page == 1) {
            return Right(cached);
          } else {
            // أرجع قائمة فارغة = hasReachedMax سيصبح true ويوقف التحميل
            return const Right([]);
          }
        }
      }
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      // ✅ أي خطأ آخر (SocketException, TimeoutException...) = لا إنترنت
      if (hasCachedPosts()) {
        final cached = getCachedPosts();
        if (cached.isNotEmpty) {
          if (page == 1) {
            return Right(cached);
          } else {
            return const Right([]);
          }
        }
      }
      return Left(UnknownFailure(
        message: 'لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة',
      ));
    }
  }

  @override
  Future<Either<Failure, Post>> getPostById(int id) async {
    try {
      final post = await remoteDataSource.getPostById(id);
      await localDataSource.savePost(post);
      return Right(post.toEntity());
    } on ServerException catch (e) {
      final cached = localDataSource.getCachedPost(id);
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      final cached = localDataSource.getCachedPost(id);
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return Left(UnknownFailure(
        message: 'لا يوجد اتصال بالإنترنت',
      ));
    }
  }

  @override
  List<Post> getCachedPosts() {
    return localDataSource.getCachedPosts().map((p) => p.toEntity()).toList();
  }

  @override
  Future<void> cachePosts(List<Post> posts) async {
    final models = posts.map((p) => PostModel.fromEntity(p)).toList();
    await localDataSource.savePosts(models);
  }

  @override
  bool hasCachedPosts() {
    return localDataSource.hasCachedPosts();
  }
}
