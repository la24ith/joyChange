// lib/features/home/domain/repositories/home_repository.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/post.dart';

abstract class HomeRepository {
  /// Get all posts with pagination
  Future<Either<Failure, List<Post>>> getPosts({
    int page = 1,
    int limit = 10, // ✅ أضف limit
  });

  /// Get single post by ID
  Future<Either<Failure, Post>> getPostById(int id);

  /// Get cached posts (offline)
  List<Post> getCachedPosts();

  /// Save posts to cache
  Future<void> cachePosts(List<Post> posts);

  /// Check if cache is available
  bool hasCachedPosts();
}
