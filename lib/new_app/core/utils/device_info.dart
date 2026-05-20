// lib/core/utils/device_info.dart

import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constant/storage_keys.dart';

class DeviceInfoUtil {
  final FlutterSecureStorage _secureStorage;
  final DeviceInfoPlugin _deviceInfo;
  final Uuid _uuid;

  DeviceInfoUtil({
    required FlutterSecureStorage secureStorage,
    DeviceInfoPlugin? deviceInfo,
    Uuid? uuid,
  })  : _secureStorage = secureStorage,
        _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
        _uuid = uuid ?? const Uuid();

  /// Get unique device ID (persistent across app reinstalls on same device)
  /// This ID is generated once and stored securely
  Future<String> getDeviceId() async {
    try {
      // Check if we already have a stored device ID
      final storedDeviceId =
          await _secureStorage.read(key: StorageKeys.deviceId);

      if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
        return storedDeviceId;
      }

      // Generate new device ID based on platform-specific identifiers
      final deviceId = await _generateUniqueDeviceId();

      // Store it securely
      await _secureStorage.write(key: StorageKeys.deviceId, value: deviceId);

      return deviceId;
    } catch (e) {
      // Fallback: generate random UUID if anything fails
      return _uuid.v4();
    }
  }

  /// Generate unique ID using platform-specific identifiers
  Future<String> _generateUniqueDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Use 'id' which is the unique Android ID
        // For Android 8.0+, this is unique per app installation + device combination
        final androidId = androidInfo.id;

        // If androidId is available, use it with UUID v5 for consistent output
        if (androidId != null && androidId.isNotEmpty) {
          return _uuid.v5(
            Uuid.NAMESPACE_DNS,
            'android_$androidId',
          );
        } else {
          // Fallback: generate random UUID for this device
          final fallbackId = _uuid.v4();
          return _uuid.v5(
            Uuid.NAMESPACE_DNS,
            'android_fallback_$fallbackId',
          );
        }
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        // identifierForVendor is unique per vendor, persists across app reinstalls
        final iosId = iosInfo.identifierForVendor;

        if (iosId != null && iosId.isNotEmpty) {
          return _uuid.v5(
            Uuid.NAMESPACE_DNS,
            'ios_$iosId',
          );
        } else {
          // Fallback for iOS if identifierForVendor is null
          final fallbackId = _uuid.v4();
          return _uuid.v5(
            Uuid.NAMESPACE_DNS,
            'ios_fallback_$fallbackId',
          );
        }
      } else {
        // Fallback for web, desktop, etc.
        final fallbackId = _uuid.v4();
        return _uuid.v5(
          Uuid.NAMESPACE_DNS,
          'generic_fallback_$fallbackId',
        );
      }
    } catch (e) {
      // Fallback: random UUID if anything fails
      return _uuid.v4();
    }
  }

  /// Get device info for analytics/debugging
  Future<Map<String, String>> getDeviceMetadata() async {
    final metadata = <String, String>{};

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        metadata['platform'] = 'android';
        metadata['model'] = androidInfo.model;
        metadata['manufacturer'] = androidInfo.manufacturer;
        metadata['os_version'] = androidInfo.version.release;
        metadata['sdk_int'] = androidInfo.version.sdkInt.toString();
        metadata['device_id'] = androidInfo.id ?? 'unknown';
        metadata['brand'] = androidInfo.brand;
        metadata['product'] = androidInfo.product;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        metadata['platform'] = 'ios';
        metadata['model'] = iosInfo.model;
        metadata['os_version'] = iosInfo.systemVersion;
        metadata['name'] = iosInfo.name;
        metadata['identifier_for_vendor'] =
            iosInfo.identifierForVendor ?? 'unknown';
        metadata['localized_model'] = iosInfo.localizedModel;
      }
    } catch (e) {
      metadata['error'] = 'Failed to get device info: ${e.toString()}';
    }

    return metadata;
  }

  /// Reset device ID (useful for testing or if user wants to reset)
  Future<void> resetDeviceId() async {
    await _secureStorage.delete(key: StorageKeys.deviceId);
  }
}
