// lib/features/home/domain/repositories/home_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/post.dart';

abstract class HomeRepository {
  /// Get all posts with pagination
  Future<Either<Failure, List<Post>>> getPosts({int page = 1});

  /// Get single post by ID
  Future<Either<Failure, Post>> getPostById(int id);

  /// Get single post by slug
  Future<Either<Failure, Post>> getPostBySlug(String slug);

  /// Get featured posts
  Future<Either<Failure, List<Post>>> getFeaturedPosts();

  /// Get cached posts (offline)
  List<Post> getCachedPosts();

  /// Save posts to cache
  Future<void> cachePosts(List<Post> posts);

  /// Check if cache is available
  bool hasCachedPosts();
}
