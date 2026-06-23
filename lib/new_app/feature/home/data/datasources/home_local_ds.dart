// lib/features/home/data/datasources/home_local_ds.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';
import '../models/post_model.dart';

class HomeLocalDataSource {
  final Box _postsBox;

  HomeLocalDataSource({Box? postsBox})
      : _postsBox = postsBox ?? Hive.box(StorageKeys.postsBox);

  /// حفظ المنشورات
  Future<void> savePosts(List<PostModel> posts) async {
    try {
      // ✅ Validate posts before saving
      final validPosts = posts.where((p) => p.id > 0).toList();

      if (validPosts.isEmpty) {
        print('⚠️ No valid posts to cache');
        return;
      }

      final postsJson = validPosts.map((p) => p.toJson()).toList();
      await _postsBox.put('cached_posts', postsJson);
      await _postsBox.put('last_updated', DateTime.now().toIso8601String());
      print('✅ Cached ${validPosts.length} posts');
    } catch (e) {
      print('❌ Error saving posts: $e');
      // Don't rethrow - caching failure shouldn't break the app
    }
  }

  /// جلب المنشورات المخزنة
  List<PostModel> getCachedPosts() {
    try {
      final cached = _postsBox.get('cached_posts');
      if (cached == null) return [];

      if (cached is List) {
        final List<PostModel> posts = [];
        for (var item in cached) {
          try {
            if (item is Map) {
              // تحويل Map إلى Map<String, dynamic>
              final Map<String, dynamic> json = {};
              item.forEach((key, value) {
                json[key.toString()] = value;
              });
              posts.add(PostModel.fromJson(json));
            }
          } catch (e) {
            print('Error parsing post: $e');
          }
        }
        return posts;
      }
      return [];
    } catch (e) {
      print('Error getting cached posts: $e');
      return [];
    }
  }

  /// حفظ منشور فردي
  Future<void> savePost(PostModel post) async {
    await _postsBox.put('post_${post.id}', post.toJson());
  }

  /// جلب منشور فردي
  PostModel? getCachedPost(int id) {
    final cached = _postsBox.get('post_$id');
    if (cached == null) return null;

    if (cached is Map) {
      final Map<String, dynamic> json = {};
      cached.forEach((key, value) {
        json[key.toString()] = value;
      });
      return PostModel.fromJson(json);
    }
    return null;
  }

  bool hasCachedPosts() {
    return _postsBox.containsKey('cached_posts');
  }

  DateTime? getLastUpdateTime() {
    final lastUpdated = _postsBox.get('last_updated');
    if (lastUpdated != null && lastUpdated is String) {
      return DateTime.tryParse(lastUpdated);
    }
    return null;
  }

  Future<void> clearCache() async {
    await _postsBox.delete('cached_posts');
    await _postsBox.delete('last_updated');
  }
}
