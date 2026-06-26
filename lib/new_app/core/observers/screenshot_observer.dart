// lib/core/observers/screenshot_observer.dart

import 'package:flutter/material.dart';
import 'package:joy_of_change_v3/new_app/core/services/screenshot_service.dart';

class ScreenshotObserver extends RouteObserver<PageRoute<dynamic>> {
  final Future<bool> Function() fetchPermission;
  
  DateTime? _lastCheck;
  bool _cachedValue = false;

  ScreenshotObserver({required this.fetchPermission});

  Future<void> _sync() async {
    final now = DateTime.now();
    
    // اسأل السيرفر فقط كل 5 دقائق
    final shouldFetch = _lastCheck == null || 
        now.difference(_lastCheck!) > const Duration(minutes: 5);

    if (shouldFetch) {
      _cachedValue = await fetchPermission();
      _lastCheck = now;
    }

    await ScreenshotService.apply(_cachedValue);
  }
@override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) _sync();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute) _sync();
  }
}