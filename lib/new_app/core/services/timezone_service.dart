// core/services/timezone_service.dart
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class TimezoneService {
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    try {
      // ✅ إصلاح: إزالة .toString() الخاطئة — await يُرجع String مباشرة
      final String timeZoneName =
          await FlutterTimezone.getLocalTimezone().toString();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
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
