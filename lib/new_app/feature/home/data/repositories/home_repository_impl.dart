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
    String? patientSegment,
  }) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📡 Fetching posts — page=$page, segment=$patientSegment');

      // ✅ جلب المنشورات من API مع تمرير الـ segment
      final posts = await remoteDataSource.getPosts(
        page: page,
        limit: limit,
        patientSegment: patientSegment,
      );
      print('📊 Received ${posts.length} posts from API');

      // ✅ تحويل إلى Entity
      final entities = posts.map((p) => p.toEntity()).toList();

      // ✅ حفظ في الكاش للصفحة الأولى فقط — مفتاح مخصص لكل segment
      if (page == 1) {
        try {
          await cachePosts(entities, segment: patientSegment);
          print(
              '💾 Cached ${entities.length} posts for segment: $patientSegment');
        } catch (e) {
          print('⚠️ Failed to cache: $e');
        }
      }

      print('✅ Returning ${entities.length} posts');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return Right(entities);
    } on ServerException catch (e) {
      print('❌ ServerException: ${e.message}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // ✅ فشل الشبكة → جلب من الكاش الخاص بهذا الـ segment
      if (page == 1 && hasCachedPosts(segment: patientSegment)) {
        final cached = getCachedPosts(segment: patientSegment);
        if (cached.isNotEmpty) {
          print(
              '📦 Loaded ${cached.length} posts from cache (segment: $patientSegment)');
          return Right(cached);
        }
      }

      print('❌ No cache available for segment: $patientSegment');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      print('❌ Unexpected error: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (page == 1 && hasCachedPosts(segment: patientSegment)) {
        final cached = getCachedPosts(segment: patientSegment);
        if (cached.isNotEmpty) {
          print(
              '📦 Loaded ${cached.length} posts from cache (segment: $patientSegment)');
          return Right(cached);
        }
      }

      print('❌ No cache available for segment: $patientSegment');
      return Left(UnknownFailure(
        message: 'لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة',
      ));
    }
  }

  @override
  Future<Either<Failure, Post>> getPostById(int id) async {
    print('🔍 getPostById: id=$id');
    try {
      final post = await remoteDataSource.getPostById(id);
      await localDataSource.savePost(post);
      return Right(post.toEntity());
    } on ServerException catch (e) {
      final cached = localDataSource.getCachedPost(id);
      if (cached != null) return Right(cached.toEntity());
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      final cached = localDataSource.getCachedPost(id);
      if (cached != null) return Right(cached.toEntity());
      return Left(UnknownFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  List<Post> getCachedPosts({String? segment}) {
    return localDataSource
        .getCachedPosts(segment: segment)
        .map((p) => p.toEntity())
        .toList();
  }

  @override
  Future<void> cachePosts(List<Post> posts, {String? segment}) async {
    final models = posts.map((p) => PostModel.fromEntity(p)).toList();
    await localDataSource.savePosts(models, segment: segment);
  }

  @override
  bool hasCachedPosts({String? segment}) {
    return localDataSource.hasCachedPosts(segment: segment);
  }
}
