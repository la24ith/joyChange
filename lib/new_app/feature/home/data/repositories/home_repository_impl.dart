// lib/features/home/data/repositories/home_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
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
  Future<Either<Failure, List<Post>>> getPosts({int page = 1}) async {
    try {
      final posts = await remoteDataSource.getPosts(page: page);
      final entities = posts.map((p) => p.toEntity()).toList();

      // Cache first page only
      if (page == 1) {
        await cachePosts(entities);
      }

      return Right(entities);
    } on ServerException catch (e) {
      // If network fails, try to return cached data
      if (hasCachedPosts()) {
        return Right(getCachedPosts());
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
}
