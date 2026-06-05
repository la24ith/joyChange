// lib/core/utils/url_helper.dart

import '../di/service_locator.dart';
import '../storage/secure_storage.dart';

class UrlHelper {
  // ✅ استخدم ngrok domain الخاص بك
  static const String _baseUrl = 'https://lake-oaf-reappear.ngrok-free.dev';
/*
  /// تحويل رابط signed-media إلى HTTPS مع الحفاظ على التوقيع
  static String fixSignedMediaUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    String result = url;

    // ✅ فقط استبدال 127.0.0.1 بـ ngrok domain (مع الحفاظ على باقي الرابط)
    if (result.contains('127.0.0.1:8000') ||
        result.contains('localhost:8000')) {
      result = result.replaceFirst(
        RegExp(r'http://(127\.0\.0\.1:8000|localhost:8000)'),
        _baseUrl,
      );
      print('🔗 Replaced localhost with ngrok: $result');
    }

    // ✅ لا نحول HTTP إلى HTTPS لأن التوقيع يعتمد على HTTP
    // ✅ نضيف معامل ngrok فقط إذا لم يكن موجوداً
    if (!result.contains('ngrok-skip-browser-warning')) {
      final separator = result.contains('?') ? '&' : '?';
      result = '$result${separator}ngrok-skip-browser-warning=true';
    }

    return result;
  }
*/
  /// بناء رابط مباشر من file_path (للملفات غير المحمية)
  static String buildDirectUrl(String? filePath) {
    if (filePath == null || filePath.isEmpty) return '';

    String cleanPath = filePath;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    return '$_baseUrl/storage/$cleanPath?ngrok-skip-browser-warning=true';
  }

  /// الحصول على headers مع التوكن والجهاز
  static Future<Map<String, String>> getAuthHeaders() async {
    final secureStorage = getIt<SecureStorageService>();
    final token = await secureStorage.read(key: 'access_token');
    final deviceId = await secureStorage.read(key: 'device_id');

    return {
      'Authorization': 'Bearer $token',
      'X-Device-Id': deviceId ?? '',
      'ngrok-skip-browser-warning': 'true',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      'Accept': '*/*',
    };
  }

  /// Headers الثابتة (للاستخدام السريع)
  static Map<String, String> getStaticHeaders() {
    return {
      'ngrok-skip-browser-warning': 'true',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    };
  }
}
