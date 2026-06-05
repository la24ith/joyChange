// lib/features/home/data/repositories/home_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_ds.dart';
import '../datasources/home_local_ds.dart';
import '../models/post_model.dart';

// ✅ Class Cache للـ Prefetch
class _PrefetchCache {
  final Map<int, List<Post>> _pages = {};

  void addPage(int page, List<Post> posts) {
    _pages[page] = posts;
    print('📦 Cached page $page with ${posts.length} posts');
  }

  List<Post>? getPage(int page) {
    return _pages[page];
  }

  void clear() {
    _pages.clear();
  }
}

final _prefetchCache = _PrefetchCache();

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
    final posts = await remoteDataSource.getPosts(page: page, limit: limit);
    final entities = posts.map((p) => p.toEntity()).toList();
    
    if (page == 1) {
      await cachePosts(entities);
    }
    
    return Right(entities);
  } on ServerException catch (e) {
    if (page == 1 && hasCachedPosts()) {
      final cached = getCachedPosts();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
    }
    return Left(ServerFailure(
      message: e.message,
      statusCode: e.statusCode,
    ));
  } catch (e) {
    return Left(UnknownFailure(
      message: 'Failed to load posts: ${e.toString()}',
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
      // Try to return cached post
      final cached = localDataSource.getCachedPost(id);
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to load post: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, Post>> getPostBySlug(String slug) async {
    try {
      final post = await remoteDataSource.getPostBySlug(slug);
      await localDataSource.savePost(post);
      return Right(post.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to load post: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getFeaturedPosts() async {
    try {
      final posts = await remoteDataSource.getFeaturedPosts();
      return Right(posts.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to load featured posts: ${e.toString()}',
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

  // ✅ دالة لمسح Cache الـ Prefetch (للـ Refresh)
  void clearPrefetchCache() {
    _prefetchCache.clear();
  }
}
