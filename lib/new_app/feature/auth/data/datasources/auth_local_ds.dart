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

  AuthLocalDataSource({
    required SecureStorageService secureStorage,
    Box? userBox,
  })  : _secureStorage = secureStorage,
        _userBox = userBox ?? Hive.box('user_box');

  /// Save authentication token
  Future<void> saveToken(String token) async {
    print('💾 Saving token to secure storage...');
    await _secureStorage.write(key: StorageKeys.accessToken, value: token);
    print('✅ Token saved successfully');

    // ✅ تحقق فوري
    final saved = await _secureStorage.read(key: StorageKeys.accessToken);
    print(
        '🔍 Verification - Token saved: ${saved != null ? "Yes (${saved.substring(0, 20)}...)" : "No"}');
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

  Future<String?> getToken() async {
    final token = await _secureStorage.read(key: StorageKeys.accessToken);
    print(
        '🔍 Reading token from secure storage: ${token != null ? "Yes (${token.substring(0, 20)}...)" : "No"}');
    return token;
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

  /// Save device ID

  /// Save user email (for quick login form)
  Future<void> saveUserEmail(String email) async {
    await _secureStorage.write(key: StorageKeys.userEmail, value: email);
  }

  /// Get saved user email
  Future<String?> getUserEmail() async {
    return await _secureStorage.read(key: StorageKeys.userEmail);
  }

  /// Clear all local auth data (logout)
  Future<void> clearAllAuthData() async {
    await deleteToken();
    await deleteCachedUser();
    // Don't delete device ID as it's persistent
    // Don't delete user email as it's helpful for next login
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

  /// Check if user is logged in (has token)
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
