// lib/features/ads/data/datasources/ads_remote_ds.dart

import 'package:dio/dio.dart';
import 'package:joy_of_change_v3/new_app/core/constant/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/ad_model.dart';

class AdsRemoteDataSource {
  final DioClient _dioClient;

  AdsRemoteDataSource({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient.instance;

  Future<List<AdModel>> getActiveAds() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.activeAds);

      // الرد قد لا يكون Map إذا أرجع السيرفر خطأ غير متوقع (صفحة HTML
      // من nginx/Apache، أو نص فاضي عند انقطاع الاتصال بمنتصف الطلب).
      // الفهرسة المباشرة response.data['success'] في هذه الحالة ترمي
      // TypeError وليس DioException، فلا تُمسك بمعالج DioException أدناه.
      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw ServerException(
          message: 'استجابة غير متوقعة من السيرفر',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode == 200 && responseData['success'] == true) {
        final rawData = responseData['data'];
        if (rawData is! List) {
          throw ServerException(
            message: 'تنسيق بيانات الإعلانات غير صحيح',
            statusCode: response.statusCode,
          );
        }

        final List<AdModel> ads = [];

        // نحلّل كل إعلان بشكل منفصل: إذا فشل عنصر واحد (بيانات ناقصة
        // أو غير متوقعة من السيرفر)، نتجاهله فقط بدل رمي استثناء يُفقد
        // كل الإعلانات الأخرى الصالحة في نفس الرد.
        for (final json in rawData) {
          try {
            ads.add(AdModel.fromJson(json as Map<String, dynamic>));
          } catch (_) {
            continue;
          }
        }
        return ads;
      } else {
        throw ServerException(
          message: responseData['message'] ?? 'Failed to load ads',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> registerClick(int adId) async {
    try {
      final response =
          await _dioClient.post('${ApiEndpoints.activeAds}/$adId/click');

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw ServerException(
          message: 'استجابة غير متوقعة من السيرفر',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode != 200 || responseData['success'] != true) {
        throw ServerException(
          message: responseData['message'] ?? 'Failed to register click',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
