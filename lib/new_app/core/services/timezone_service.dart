// core/services/timezone_service.dart
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter/material.dart';

class TimezoneService {
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    try {
      // ✅ استخدام المنطقة الزمنية الحقيقية للجهاز
      final String timeZoneName =
          await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('✅ Timezone set to: $timeZoneName');
    } catch (e) {
      debugPrint('⚠️ Failed to get native timezone, using system default: $e');
      // استخدام المنطقة الزمنية للنظام كـ fallback
      tz.setLocalLocation(tz.local);
    }
  }
}
