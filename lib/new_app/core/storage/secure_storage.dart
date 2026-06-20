// lib/core/storage/secure_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(aOptions: _androidOptions);

  Future<void> write({required String key, required String value}) async {
    // ✅ إصلاح: التحقق من طول القيمة قبل عرضها
    final displayValue =
        value.length > 20 ? '${value.substring(0, 20)}...' : value;
    print('💾 SecureStorage write: key=$key, value=$displayValue');
    await _storage.write(key: key, value: value);
    print('✅ SecureStorage write completed');
  }

  Future<String?> read({required String key}) async {
    final value = await _storage.read(key: key);
    print('🔍 SecureStorage read: key=$key, found=${value != null}');
    if (value != null) {
      // ✅ إصلاح: التحقق من طول القيمة قبل عرضها
      final displayValue =
          value.length > 20 ? '${value.substring(0, 20)}...' : value;
      print('🔍 Value: $displayValue');
    }
    return value;
  }

  Future<void> delete({required String key}) async {
    print('🗑️ SecureStorage delete: key=$key');
    await _storage.delete(key: key);
  }

  Future<void> clearAll() async {
    print('🗑️ SecureStorage clear all');
    await _storage.deleteAll();
  }
}
