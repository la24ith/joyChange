// lib/new_app/core/services/fcm_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FcmService {
  final Dio dio;
  final FlutterLocalNotificationsPlugin localNotifications;

  FcmService(this.dio, this.localNotifications);

  /// استدعِ هذه عند نجاح الـ session أو تسجيل الدخول
  Future<void> initAndRegister() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('FCM: Permission denied by user');
        return;
      }

      await _registerToken();

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        debugPrint('FCM: Token refreshed');
        await _sendTokenToServer(newToken);
      });

      // Foreground handler — الباك يرسل data-only payload (متعمد)
      // لذلك Android لا يعرضه تلقائياً — يجب عرضه يدوياً هنا
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // عند الضغط على الإشعار والتطبيق في الخلفية
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // عند فتح التطبيق من إشعار وهو كان مغلقاً تماماً
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      debugPrint('FCM initAndRegister error: $e');
    }
  }

  /// يُستدعى عندما يصل إشعار FCM والتطبيق مفتوح (foreground)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('FCM Foreground message: ${message.data}');

    // ✅ إصلاح: نقرأ العنوان والجسم كنص "خام" أولاً بدون قيمة افتراضية،
    //    حتى نقدر نميّز فعلياً بين "موجود وفاضي" و"غير موجود إطلاقاً"
    final rawTitle = (message.notification?.title ?? message.data['title'])
        ?.toString()
        .trim();
    final rawBody = (message.notification?.body ?? message.data['message'])
        ?.toString()
        .trim();

    // ✅ إصلاح: لو العنوان والجسم كلاهما فاضي/غير موجود، تجاهل الرسالة تماماً
    //    بدل عرض إشعار فاضٍ للمستخدم بعنوان افتراضي "إشعار جديد"
    final hasContent =
        (rawTitle != null && rawTitle.isNotEmpty) ||
            (rawBody != null && rawBody.isNotEmpty);

    if (!hasContent) {
      debugPrint(
        '⚠️ Ignored empty FCM foreground payload (no title/message): '
        '${message.data}',
      );
      return;
    }

    final title = (rawTitle != null && rawTitle.isNotEmpty)
        ? rawTitle
        : 'إشعار جديد';
    final body = rawBody ?? '';

    // ✅ إصلاح: تنبيه واضح لو وصل الإشعار بدون notification_id
    //    (كان يولّد id عشوائي من الوقت، ما يعرّض الإشعارات لتصادم صامت)
    final rawId = message.data['notification_id']?.toString();
    if (rawId == null || rawId.isEmpty) {
      debugPrint(
        '⚠️ FCM payload missing notification_id, generating fallback id. '
        'data: ${message.data}',
      );
    }

    final notificationId =
        int.tryParse(rawId ?? '') ??
            DateTime.now().millisecondsSinceEpoch.remainder(100000);

    try {
      await localNotifications.show(
        notificationId,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'notifications_v2', // ← نفس الـ channel المُنشأ في LocalNotificationInitializer
            'App Notifications',
            channelDescription: 'إشعارات التطبيق',
            icon: 'ic_notification',
            sound: RawResourceAndroidNotificationSound('notification_sound'),
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['notification_id']?.toString(),
      );
      debugPrint('Foreground notification displayed: $notificationId');
    } catch (e) {
      debugPrint('Failed to show foreground notification: $e');
    }
  }

  /// يُستدعى عند الضغط على الإشعار (من الخلفية أو من حالة الإغلاق)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.data}');
    // حالياً يكفي فتح التطبيق — لا حاجة لتنقل خاص
  }

  Future<void> _registerToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        debugPrint('FCM: Token is null');
        return;
      }
      debugPrint('FCM: Token obtained successfully');
      await _sendTokenToServer(token);
    } catch (e) {
      debugPrint('FCM: Failed to get token: $e');
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      await dio.post(
        '/api/user/fcm-token',
        data: {
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
        },
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);

      debugPrint('FCM: Token registered on server');
    } on DioException catch (e) {
      debugPrint('FCM: Failed to send token to server: ${e.message}');
    } catch (e) {
      debugPrint('FCM: Unexpected error sending token: $e');
    }
  }

  /// استدعِ هذه عند logout
  Future<void> unregisterToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcm_token');

      if (token == null) {
        debugPrint('FCM: No saved token to unregister');
        return;
      }

      await dio.delete(
        '/api/user/fcm-token',
        data: {'token': token},
      );

      await prefs.remove('fcm_token');
      debugPrint('FCM: Token unregistered from server');
    } on DioException catch (e) {
      debugPrint('FCM: Failed to unregister token: ${e.message}');
    } catch (e) {
      debugPrint('FCM: Unexpected error unregistering token: $e');
    }
  }
}
