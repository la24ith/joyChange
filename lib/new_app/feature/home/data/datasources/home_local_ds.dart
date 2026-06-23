// lib/features/home/data/datasources/home_local_ds.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';
import '../models/post_model.dart';

class HomeLocalDataSource {
  final Box _postsBox;

  HomeLocalDataSource({Box? postsBox})
      : _postsBox = postsBox ?? Hive.box(StorageKeys.postsBox);

  /// ✅ تحويل عميق لأي Map إلى Map<String, dynamic> بما فيها الـ nested maps
  Map<String, dynamic> _deepConvert(dynamic map) {
    final result = <String, dynamic>{};
    (map as Map).forEach((key, value) {
      if (value is Map) {
        result[key.toString()] = _deepConvert(value);
      } else if (value is List) {
        result[key.toString()] =
            value.map((e) => e is Map ? _deepConvert(e) : e).toList();
      } else {
        result[key.toString()] = value;
      }
    });
    return result;
  }

  /// حفظ المنشورات
  Future<void> savePosts(List<PostModel> posts) async {
    try {
      final postsJson = posts.map((p) => p.toJson()).toList();
      await _postsBox.put('cached_posts', postsJson);
      await _postsBox.put('last_updated', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving posts: $e');
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
              // ✅ تحويل عميق يشمل author وكل الـ nested maps
              final Map<String, dynamic> json = _deepConvert(item);
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
      return PostModel.fromJson(_deepConvert(cached));
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
