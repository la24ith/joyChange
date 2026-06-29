// lib/new_app/core/services/fcm_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FcmService {
  final Dio dio;

  FcmService(this.dio);

  /// استدعِ هذه عند نجاح الـ session أو تسجيل الدخول
  Future<void> initAndRegister() async {
    try {
      // طلب الصلاحية — iOS يحتاجها، Android 13+ يحتاجها
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('📵 FCM: Permission denied by user');
        return;
      }

      // جلب الـ token وإرساله للـ server
      await _registerToken();

      // استمع لتجديد الـ token تلقائياً عند انتهاء صلاحيته
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        debugPrint('🔄 FCM: Token refreshed');
        await _sendTokenToServer(newToken);
      });
    } catch (e) {
      debugPrint('❌ FCM initAndRegister error: $e');
    }
  }

  Future<void> _registerToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        debugPrint('⚠️ FCM: Token is null');
        return;
      }
      debugPrint('📱 FCM Token: $token');
      await _sendTokenToServer(token);
    } catch (e) {
      debugPrint('❌ FCM: Failed to get token: $e');
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

      // احفظ الـ token محلياً لاستخدامه عند logout
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);

      debugPrint('✅ FCM: Token registered on server');
    } on DioException catch (e) {
      // لا نرمي exception — فشل تسجيل الـ token لا يجب أن يوقف التطبيق
      debugPrint('⚠️ FCM: Failed to send token to server: ${e.message}');
    } catch (e) {
      debugPrint('⚠️ FCM: Unexpected error sending token: $e');
    }
  }

  /// استدعِ هذه عند logout لإيقاف الإشعارات على هذا الجهاز
  Future<void> unregisterToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcm_token');

      if (token == null) {
        debugPrint('⚠️ FCM: No saved token to unregister');
        return;
      }

      await dio.delete(
        '/api/user/fcm-token',
        data: {'token': token},
      );

      await prefs.remove('fcm_token');
      debugPrint('✅ FCM: Token unregistered from server');
    } on DioException catch (e) {
      debugPrint('⚠️ FCM: Failed to unregister token: ${e.message}');
    } catch (e) {
      debugPrint('⚠️ FCM: Unexpected error unregistering token: $e');
    }
  }
}
