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
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔍 HomeRepositoryImpl.getPosts called');
    print('📄 Page: $page, Limit: $limit');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      // ✅ 1. جلب البيانات من API
      print('📡 Fetching posts from remote data source...');
      final posts = await remoteDataSource.getPosts(page: page, limit: limit);
      print('📊 Received ${posts.length} posts from API');

      // ✅ 2. تحويل إلى Entity
      print('🔄 Converting posts to entities...');
      final entities = posts.map((p) {
        print('  📝 Converting: ID=${p.id}, Title=${p.title}');
        return p.toEntity();
      }).toList();
      print('✅ Converted ${entities.length} posts to entities');

      // ✅ 3. حفظ في الكاش (للصفحة الأولى فقط)
      if (page == 1) {
        print('💾 Page 1 - Saving to cache...');
        try {
          await cachePosts(entities);
          print('✅ Cache save completed');

          // ✅ التحقق من الحفظ
          final cached = localDataSource.getCachedPosts();
          print('📦 Cache now has ${cached.length} posts');
          if (cached.isNotEmpty) {
            print('📝 First cached post: ${cached.first.title}');
          }
        } catch (e) {
          print('⚠️ Failed to save to cache: $e');
        }
      } else {
        print('⏭️ Page $page - Skipping cache (only page 1 is cached)');
      }

      // ✅ 4. إرجاع البيانات
      print('✅ Returning ${entities.length} posts to UseCase');
      if (entities.isNotEmpty) {
        print('📝 First entity: ${entities.first.title}');
      }
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return Right(entities);
    } on ServerException catch (e) {
      print('❌ ServerException: ${e.message}, StatusCode: ${e.statusCode}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // ✅ عند فشل الشبكة، حاول استخدام الكاش
      if (hasCachedPosts()) {
        print('📦 Cache available, loading from cache...');
        final cached = getCachedPosts();
        if (cached.isNotEmpty) {
          print('✅ Loaded ${cached.length} posts from cache');
          if (page == 1) {
            return Right(cached);
          } else {
            print(
                '⏭️ Page $page - Returning empty list (cache only has page 1)');
            return const Right([]);
          }
        }
      }

      print('❌ No cache available');
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      print('❌ Unexpected error: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // ✅ أي خطأ آخر، حاول استخدام الكاش
      if (hasCachedPosts()) {
        print('📦 Cache available, loading from cache...');
        final cached = getCachedPosts();
        if (cached.isNotEmpty) {
          print('✅ Loaded ${cached.length} posts from cache');
          if (page == 1) {
            return Right(cached);
          } else {
            print('⏭️ Page $page - Returning empty list');
            return const Right([]);
          }
        }
      }

      print('❌ No cache available');
      return Left(UnknownFailure(
        message: 'لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة',
      ));
    }
  }

  @override
  Future<Either<Failure, Post>> getPostById(int id) async {
    print('🔍 HomeRepositoryImpl.getPostById: id=$id');

    try {
      final post = await remoteDataSource.getPostById(id);
      print('✅ Post found: ${post.title}');
      await localDataSource.savePost(post);
      print('💾 Post saved to cache');
      return Right(post.toEntity());
    } on ServerException catch (e) {
      print('❌ ServerException: ${e.message}');
      final cached = localDataSource.getCachedPost(id);
      if (cached != null) {
        print('📦 Returning cached post: ${cached.title}');
        return Right(cached.toEntity());
      }
      print('❌ No cached post found');
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      print('❌ Error: $e');
      final cached = localDataSource.getCachedPost(id);
      if (cached != null) {
        print('📦 Returning cached post: ${cached.title}');
        return Right(cached.toEntity());
      }
      return Left(UnknownFailure(
        message: 'لا يوجد اتصال بالإنترنت',
      ));
    }
  }

  @override
  List<Post> getCachedPosts() {
    print('🔍 HomeRepositoryImpl.getCachedPosts called');
    final posts =
        localDataSource.getCachedPosts().map((p) => p.toEntity()).toList();
    print('📦 Cache has ${posts.length} posts');
    return posts;
  }

  @override
  Future<void> cachePosts(List<Post> posts) async {
    print('💾 HomeRepositoryImpl.cachePosts called with ${posts.length} posts');
    final models = posts.map((p) {
      print('  🔄 Converting: ${p.title}');
      return PostModel.fromEntity(p);
    }).toList();
    await localDataSource.savePosts(models);
    print('✅ cachePosts completed');
  }

  @override
  bool hasCachedPosts() {
    final has = localDataSource.hasCachedPosts();
    print('🔍 HomeRepositoryImpl.hasCachedPosts: $has');
    return has;
  }
}
