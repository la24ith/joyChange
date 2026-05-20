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
    await _secureStorage.write(key: StorageKeys.accessToken, value: token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: StorageKeys.accessToken);
  }

  /// Delete authentication token
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
  }

  /// Save user data locally
  Future<void> saveUser(UserModel user) async {
    await _userBox?.put('current_user', user.toJson());
  }

  /// Get cached user data
  Future<UserModel?> getCachedUser() async {
    final userJson = _userBox?.get('current_user');
    if (userJson != null && userJson is Map<String, dynamic>) {
      return UserModel.fromJson(userJson);
    }
    return null;
  }

  /// Delete cached user data
  Future<void> deleteCachedUser() async {
    await _userBox?.delete('current_user');
  }

  /// Save device ID
  Future<void> saveDeviceId(String deviceId) async {
    await _secureStorage.write(key: StorageKeys.deviceId, value: deviceId);
  }

  /// Get device ID
  Future<String?> getDeviceId() async {
    return await _secureStorage.read(key: StorageKeys.deviceId);
  }

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
