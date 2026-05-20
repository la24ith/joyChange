// lib/features/home/data/datasources/home_local_ds.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constant/storage_keys.dart';
import '../models/post_model.dart';

class HomeLocalDataSource {
  final Box _postsBox;

  HomeLocalDataSource({Box? postsBox})
      : _postsBox = postsBox ?? Hive.box(StorageKeys.postsBox);

  /// Save posts to local cache
  Future<void> savePosts(List<PostModel> posts) async {
    await _postsBox.put('cached_posts', posts.map((p) => p.toJson()).toList());
    await _postsBox.put('last_updated', DateTime.now().toIso8601String());
  }

  /// Get cached posts
  List<PostModel> getCachedPosts() {
    final cached = _postsBox.get('cached_posts');
    if (cached != null && cached is List) {
      return cached
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Save single post
  Future<void> savePost(PostModel post) async {
    await _postsBox.put('post_${post.id}', post.toJson());
  }

  /// Get single cached post
  PostModel? getCachedPost(int id) {
    final cached = _postsBox.get('post_$id');
    if (cached != null && cached is Map<String, dynamic>) {
      return PostModel.fromJson(cached);
    }
    return null;
  }

  /// Check if cache is available
  bool hasCachedPosts() {
    return _postsBox.containsKey('cached_posts');
  }

  /// Get last update time
  DateTime? getLastUpdateTime() {
    final lastUpdated = _postsBox.get('last_updated');
    if (lastUpdated != null && lastUpdated is String) {
      return DateTime.tryParse(lastUpdated);
    }
    return null;
  }

  /// Clear all cached posts
  Future<void> clearCache() async {
    await _postsBox.delete('cached_posts');
    await _postsBox.delete('last_updated');
  }
}
