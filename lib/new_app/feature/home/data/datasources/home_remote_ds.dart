// lib/features/home/data/datasources/home_remote_ds.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constant/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/post_model.dart';

class HomeRemoteDataSource {
  final DioClient _dioClient;

  HomeRemoteDataSource({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient.instance;

  /// Get all posts with pagination and optional segment filter
  Future<List<PostModel>> getPosts({
    int page = 1,
    int limit = 10,
    String? patientSegment, // ✅ تصفية حسب نوع المريض
  }) async {
    try {
      // ✅ بناء query parameters
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      // ✅ إضافة patient_segment فقط إذا كان موجوداً
      if (patientSegment != null && patientSegment.isNotEmpty) {
        queryParams['patient_segment'] = patientSegment;
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 GET POSTS REQUEST');
      print('📍 URL: ${ApiEndpoints.posts}');
      print('🔍 Params: $queryParams');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _dioClient.get(
        ApiEndpoints.posts,
        queryParameters: queryParams,
      );

      print('📥 GET POSTS RESPONSE');
      print('📊 Status: ${response.statusCode}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        print('✅ Loaded ${data.length} posts for segment: $patientSegment');
        return data.map((json) => PostModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load posts',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.error is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Get single post by ID
  Future<PostModel> getPostById(int id) async {
    try {
      final response = await _dioClient.get('${ApiEndpoints.posts}/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return PostModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load post',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.error is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Get single post by slug
  Future<PostModel> getPostBySlug(String slug) async {
    try {
      final response = await _dioClient.get('${ApiEndpoints.posts}/$slug/slug');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return PostModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load post',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.error is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Get featured posts
  Future<List<PostModel>> getFeaturedPosts() async {
    try {
      final response = await _dioClient.get('${ApiEndpoints.posts}/featured');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PostModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load featured posts',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.error is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Get posts by category
  Future<List<PostModel>> getPostsByCategory(int categoryId,
      {int page = 1}) async {
    try {
      final response = await _dioClient.get(
        '${ApiEndpoints.posts}/category/$categoryId',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PostModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load posts',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.error is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<String?> _getStoredToken() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'access_token');
  }
}
