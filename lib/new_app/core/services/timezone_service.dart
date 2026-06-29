// lib/new_app/core/services/timezone_service.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class TimezoneService {
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    try {
      // flutter_timezone ^5.x يُرجع TimezoneInfo وليس String
      // نستخدم .name للحصول على اسم المنطقة كـ String
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timezoneInfo.toString();

      tz.setLocalLocation(tz.getLocation(timeZoneName));

      // احفظ اسم الـ timezone لاستخدامه في WorkManager background
      // WorkManager ينشئ process جديد لا يرث أي state من التطبيق
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_timezone', timeZoneName);

      debugPrint('✅ Timezone set to: $timeZoneName');
    } catch (e) {
      debugPrint('⚠️ Failed to get native timezone: $e');
      debugPrint('📍 Using system local timezone as fallback');
      tz.setLocalLocation(tz.local);
    }
  }

  static String getCurrentTimezone() {
    return tz.local.name;
  }

  static DateTime convertToTimezone(DateTime dateTime, String timezone) {
    final location = tz.getLocation(timezone);
    return tz.TZDateTime.from(dateTime, location);
  }
}
