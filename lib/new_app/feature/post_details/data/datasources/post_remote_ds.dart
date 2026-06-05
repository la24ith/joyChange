// lib/features/post_details/data/datasources/post_remote_ds.dart

import 'package:dio/dio.dart';
import 'package:joy_of_change_v3/new_app/core/constant/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/media_model.dart';

class PostRemoteDataSource {
  final DioClient _dioClient;

  PostRemoteDataSource({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient.instance;

  /// Get post media by post ID
  Future<List<MediaModel>> getPostMedia(int postId) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 GET POST MEDIA REQUEST');
      print('📍 URL: ${ApiEndpoints.posts}/$postId/media');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response =
          await _dioClient.get('${ApiEndpoints.posts}/$postId/media');

      print('📥 GET POST MEDIA RESPONSE');
      print('📊 Status: ${response.statusCode}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final mediaData = response.data['data']['media'] as List<dynamic>;
        return mediaData.map((json) => MediaModel.fromJson(json)).toList();
      } else {
        return []; // No media found
      }
    } on DioException catch (e) {
      if (e.error is AppException) {
        rethrow;
      }
      print('❌ Error fetching media: ${e.message}');
      return []; // Return empty list on error
    }
  }
}
