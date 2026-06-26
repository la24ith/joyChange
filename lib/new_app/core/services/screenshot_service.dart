// lib/core/services/screenshot_service.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenshotService {
  static const _channel = MethodChannel(
    'com.example.joy_of_change_v3/screenshot',
  );

  static Future<void> apply(bool canScreenshot) async {
    try {
      await _channel.invokeMethod('updateScreenshotPermission', {
        'canScreenshot': canScreenshot,
      });
    } catch (e) {
      // لا توقف التطبيق إذا فشل
      debugPrint('ScreenshotService error: $e');
    }
  }
}
