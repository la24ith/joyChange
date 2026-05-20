// lib/core/storage/secure_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true, // More secure on Android
  );

  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(aOptions: _androidOptions);

  // Write operations
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  // Read operations
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  // Delete operations
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Check if key exists
  Future<bool> containsKey({required String key}) async {
    final value = await _storage.read(key: key);
    return value != null;
  }

  // Read all keys and values (for debugging)
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
}
