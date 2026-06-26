// lib/features/auth/data/datasources/auth_local_ds.dart

import 'package:joy_of_change_v3/new_app/core/constant/storage_keys.dart';

import '../../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Local data source for authentication
/// Handles all local storage operations for auth data
class AuthLocalDataSource {
  final SecureStorageService _secureStorage;
  final Box? _userBox;

  static const String _profileCompletedKey = 'profile_completed';

  AuthLocalDataSource({
    required SecureStorageService secureStorage,
    Box? userBox,
  })  : _secureStorage = secureStorage,
        _userBox = userBox ?? Hive.box('user_box');
// أضف هذه الثوابت في أعلى الكلاس
  static const String _pendingStateKey = 'pending_auth_state';
  static const String _pendingEmailKey = 'pending_auth_email';
  static const String _pendingUserIdKey = 'pending_user_id';
  static const String _pendingPasswordKey = 'pending_password';
  static const String _pendingDeviceIdKey = 'pending_device_id';

  /// حفظ حالة الانتظار (subscription أو device)
  Future<void> savePendingState({
    required String state, // 'PENDING_SUBSCRIPTION' أو 'PENDING_DEVICE'
    required String email,
    int? userId,
    String? password,
    String? deviceId,
  }) async {
    await _secureStorage.write(key: _pendingStateKey, value: state);
    await _secureStorage.write(key: _pendingEmailKey, value: email);
    if (userId != null) {
      await _secureStorage.write(
          key: _pendingUserIdKey, value: userId.toString());
    }
    if (password != null && password.isNotEmpty) {
      await _secureStorage.write(key: _pendingPasswordKey, value: password);
    }
    if (deviceId != null) {
      await _secureStorage.write(key: _pendingDeviceIdKey, value: deviceId);
    }
    print('💾 Pending state saved: $state for $email');
  }

  /// استرجاع حالة الانتظار
  Future<Map<String, String?>?> getPendingState() async {
    final state = await _secureStorage.read(key: _pendingStateKey);
    if (state == null || state.isEmpty) return null;

    return {
      'state': state,
      'email': await _secureStorage.read(key: _pendingEmailKey),
      'userId': await _secureStorage.read(key: _pendingUserIdKey),
      'password': await _secureStorage.read(key: _pendingPasswordKey),
      'deviceId': await _secureStorage.read(key: _pendingDeviceIdKey),
    };
  }

  /// مسح حالة الانتظار (عند تسجيل الدخول الناجح)
  Future<void> clearPendingState() async {
    await _secureStorage.delete(key: _pendingStateKey);
    await _secureStorage.delete(key: _pendingEmailKey);
    await _secureStorage.delete(key: _pendingUserIdKey);
    await _secureStorage.delete(key: _pendingPasswordKey);
    await _secureStorage.delete(key: _pendingDeviceIdKey);
    print('🗑️ Pending state cleared');
  }

  /// ✅ Helper لتقطيع النص بأمان
  String _safeSubstring(String text, int start, int end) {
    if (text.length <= end) {
      return text;
    }
    return text.substring(start, end);
  }
// lib/features/auth/data/datasources/auth_local_ds.dart

  /// Save authentication token - نسخة آمنة
  Future<void> saveToken(String token) async {
    print('💾 Saving token to secure storage...');
    await _secureStorage.write(key: StorageKeys.accessToken, value: token);
    print('✅ Token saved successfully');

    // ✅ تحقق آمن
    try {
      final saved = await _secureStorage.read(key: StorageKeys.accessToken);
      if (saved != null && saved.isNotEmpty) {
        // ✅ تجنب substring على نصوص قصيرة
        final preview =
            saved.length > 20 ? '${saved.substring(0, 20)}...' : saved;
        print('🔍 Verification - Token saved: Yes ($preview)');
      } else {
        print('🔍 Verification - Token saved: No');
      }
    } catch (e) {
      print('⚠️ Could not verify token: $e');
    }
  }

  /// Get token - نسخة آمنة
  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: StorageKeys.accessToken);
      if (token != null && token.isNotEmpty) {
        // ✅ تجنب substring على نصوص قصيرة
        final preview =
            token.length > 20 ? '${token.substring(0, 20)}...' : token;
        print('🔍 Reading token: Yes ($preview)');
      } else {
        print('🔍 Reading token: No');
      }
      return token;
    } catch (e) {
      print('❌ Error reading token: $e');
      return null;
    }
  }

  /// Save device ID
  Future<void> saveDeviceId(String deviceId) async {
    await _secureStorage.write(key: StorageKeys.deviceId, value: deviceId);
    print('💾 Device ID saved to secure storage');
  }

  /// Get device ID
  Future<String?> getDeviceId() async {
    return await _secureStorage.read(key: StorageKeys.deviceId);
  }

  /// Delete authentication token
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
  }

  Future<UserModel?> getCachedUser() async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔍 getCachedUser called');
    print('📦 Hive box: ${_userBox?.name}, isOpen: ${_userBox?.isOpen}');

    final userJson = _userBox?.get('current_user');
    print(
        '📦 User JSON from Hive: ${userJson != null ? "Found" : "Not found"}');

    if (userJson != null) {
      print('📦 JSON type: ${userJson.runtimeType}');

      // ✅ تحويل _Map<dynamic, dynamic> إلى Map<String, dynamic>
      Map<String, dynamic> convertedJson;

      if (userJson is Map<String, dynamic>) {
        convertedJson = userJson;
      } else if (userJson is Map<dynamic, dynamic>) {
        // ✅ تحويل المفتاح إلى String
        convertedJson =
            userJson.map((key, value) => MapEntry(key.toString(), value));
        print('✅ Converted _Map to Map<String, dynamic>');
      } else {
        print('❌ JSON is not a Map at all!');
        return null;
      }

      try {
        final user = UserModel.fromJson(convertedJson);
        print('✅ User parsed successfully: ${user.email}');
        return user;
      } catch (e) {
        print('❌ Error parsing user: $e');
      }
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    return null;
  }

  /// Save user data locally
  Future<void> saveUser(UserModel user) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('💾 saveUser called');
    print('📧 User email: ${user.email}');

    final json = user.toJson();
    print('📦 User to JSON type: ${json.runtimeType}');

    // ✅ تأكد من أن JSON هو Map<String, dynamic>
    if (json is Map<String, dynamic>) {
      await _userBox?.put('current_user', json);
      print('✅ User saved to Hive box: ${_userBox?.name}');
    } else {
      print('❌ JSON is not Map<String, dynamic>!');
    }

    // ✅ تحقق فوري
    final saved = _userBox?.get('current_user');
    print('🔍 Verification - User in Hive: ${saved != null ? "Yes" : "No"}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// Delete cached user data
  Future<void> deleteCachedUser() async {
    await _userBox?.delete('current_user');
  }

  /// Save user email (for quick login form)
  Future<void> saveUserEmail(String email) async {
    await _secureStorage.write(key: StorageKeys.userEmail, value: email);
  }

  /// Get saved user email
  Future<String?> getUserEmail() async {
    return await _secureStorage.read(key: StorageKeys.userEmail);
  }

  // ============================================================
  // ✅ ✅ ✅ دوال حالة إكمال البروفايل
  // ============================================================

  /// ✅ Save profile completion status
  Future<void> saveProfileCompleted(bool completed) async {
    try {
      final value = completed ? 'true' : 'false';
      print('💾 Saving profile completion: $completed');

      await _secureStorage.write(
        key: _profileCompletedKey,
        value: value,
      );

      print('✅ Profile completion saved: $completed');

      // ✅ تحقق بسيط
      try {
        final saved = await _secureStorage.read(key: _profileCompletedKey);
        print('🔍 Verification: "$saved"');
      } catch (e) {
        print('⚠️ Could not verify: $e');
      }
    } catch (e) {
      print('❌ Error saving profile completion: $e');
      // ✅ لا نرمي الخطأ
    }
  }

  /// ✅ Get profile completion status
  Future<bool> getProfileCompleted() async {
    try {
      final value = await _secureStorage.read(key: _profileCompletedKey);
      print('🔍 Reading profile completion: "$value"');
      return value == 'true';
    } catch (e) {
      print('❌ Error reading profile completion: $e');
      return false;
    }
  }

  /// ✅ Get profile completion status without logging
  Future<bool> getProfileCompletedSilent() async {
    try {
      final value = await _secureStorage.read(key: _profileCompletedKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// ✅ Reset profile completion status
  Future<void> resetProfileCompleted() async {
    try {
      await _secureStorage.delete(key: _profileCompletedKey);
      print('✅ Profile completion status reset');
    } catch (e) {
      print('❌ Error resetting: $e');
    }
  }

  /// ✅ Force set profile completion status
  Future<void> forceSetProfileCompleted(bool completed) async {
    try {
      final value = completed ? 'true' : 'false';
      await _secureStorage.write(key: _profileCompletedKey, value: value);
      print('✅ Force set to: $completed');
    } catch (e) {
      print('❌ Error force setting: $e');
    }
  }

  // ============================================================
  // ✅ دوال إدارة البيانات العامة
  // ============================================================

  /// Clear all local auth data (logout)
  Future<void> clearAllAuthData() async {
    await deleteToken();
    await deleteCachedUser();
    print('✅ Auth data cleared (profile status kept)');
  }

  /// Clear all data including profile status
  Future<void> clearAllData() async {
    await deleteToken();
    await deleteCachedUser();
    await _secureStorage.delete(key: _profileCompletedKey);
    print('✅ All data cleared');
  }

  /// Save last login time
  Future<void> saveLastLoginTime(DateTime time) async {
    await _secureStorage.write(
      key: StorageKeys.lastLoginTime,
      value: time.toIso8601String(),
    );
  }

  /// Get last login time
  Future<DateTime?> getLastLoginTime() async {
    final timeStr = await _secureStorage.read(key: StorageKeys.lastLoginTime);
    if (timeStr != null) {
      return DateTime.tryParse(timeStr);
    }
    return null;
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if user has complete profile data
  bool hasCompleteProfileData(UserModel user) {
    return user.currentWeight != null &&
        user.targetWeight != null &&
        user.height != null &&
        user.patientSegment.isNotEmpty &&
        user.patientSegment != 'general' &&
        user.phone != null &&
        user.phone!.isNotEmpty;
  }

  /// Check if user is fully set up
  Future<bool> isUserFullySetUp(UserModel user) async {
    final hasData = hasCompleteProfileData(user);
    if (!hasData) return false;
    return await getProfileCompleted();
  }
}
