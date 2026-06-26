// lib/features/home/domain/repositories/home_repository.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/post.dart';

abstract class HomeRepository {
  /// Get all posts with pagination and optional segment filter
  Future<Either<Failure, List<Post>>> getPosts({
    int page = 1,
    int limit = 10,
    String? patientSegment,
  });

  /// Get single post by ID
  Future<Either<Failure, Post>> getPostById(int id);

  /// Get cached posts for a specific segment
  List<Post> getCachedPosts({String? segment});

  /// Save posts to cache for a specific segment
  Future<void> cachePosts(List<Post> posts, {String? segment});

  /// Check if cache is available for a specific segment
  bool hasCachedPosts({String? segment});
}
