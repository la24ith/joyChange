// lib/features/home/data/datasources/home_local_ds.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';
import '../models/post_model.dart';

class HomeLocalDataSource {
  final Box _postsBox;

  HomeLocalDataSource({Box? postsBox})
      : _postsBox = postsBox ?? Hive.box(StorageKeys.postsBox);

  // ✅ مفتاح الكاش حسب الـ segment
  String _cacheKey(String? segment) {
    final s = (segment == null || segment.isEmpty) ? 'general' : segment;
    return 'cached_posts_$s';
  }

  String _lastUpdatedKey(String? segment) {
    final s = (segment == null || segment.isEmpty) ? 'general' : segment;
    return 'last_updated_$s';
  }

  /// تحويل عميق لأي Map إلى Map<String, dynamic>
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

  /// حفظ المنشورات حسب الـ segment
  Future<void> savePosts(List<PostModel> posts, {String? segment}) async {
    try {
      final postsJson = posts.map((p) => p.toJson()).toList();
      await _postsBox.put(_cacheKey(segment), postsJson);
      await _postsBox.put(
          _lastUpdatedKey(segment), DateTime.now().toIso8601String());
      print('💾 Saved ${posts.length} posts for segment: $segment');
    } catch (e) {
      print('Error saving posts: $e');
    }
  }

  /// جلب المنشورات المخزنة حسب الـ segment
  List<PostModel> getCachedPosts({String? segment}) {
    try {
      final cached = _postsBox.get(_cacheKey(segment));
      if (cached == null) return [];

      if (cached is List) {
        final List<PostModel> posts = [];
        for (var item in cached) {
          try {
            if (item is Map) {
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

  /// التحقق من وجود كاش لـ segment معين
  bool hasCachedPosts({String? segment}) {
    return _postsBox.containsKey(_cacheKey(segment));
  }

  DateTime? getLastUpdateTime({String? segment}) {
    final lastUpdated = _postsBox.get(_lastUpdatedKey(segment));
    if (lastUpdated != null && lastUpdated is String) {
      return DateTime.tryParse(lastUpdated);
    }
    return null;
  }

  /// مسح كاش segment معين
  Future<void> clearCache({String? segment}) async {
    await _postsBox.delete(_cacheKey(segment));
    await _postsBox.delete(_lastUpdatedKey(segment));
  }

  /// مسح كاش كل الـ segments
  Future<void> clearAllCache() async {
    final keys = _postsBox.keys
        .where((k) =>
            k.toString().startsWith('cached_posts_') ||
            k.toString().startsWith('last_updated_'))
        .toList();
    for (final key in keys) {
      await _postsBox.delete(key);
    }
  }
}
