import 'package:flutter/services.dart';
import 'dart:async';
import '../models/shame_app.dart';
import 'storage_service.dart';
import 'notification_service.dart';

class AccessibilityService {
  static const platform = MethodChannel('com.scrollofshame.app/accessibility');
  
  static StreamController<String>? _appChangeController;
  static String? _lastPackageName;
  static Timer? _checkTimer;

  static Future<bool> hasPermission() async {
    try {
      final bool hasPermission = await platform.invokeMethod('hasPermission');
      return hasPermission;
    } on PlatformException catch (e) {
      print('Error checking permission: ${e.message}');
      return false;
    }
  }

  static Future<void> requestPermission() async {
    try {
      await platform.invokeMethod('requestPermission');
    } on PlatformException catch (e) {
      print('Error requesting permission: ${e.message}');
    }
  }

  static Future<String?> getCurrentApp() async {
    try {
      final String? packageName = await platform.invokeMethod('getCurrentApp');
      return packageName;
    } on PlatformException catch (e) {
      print('Error getting current app: ${e.message}');
      return null;
    }
  }

  static void startMonitoring() {
    _appChangeController = StreamController<String>.broadcast();
    
    // Check for app changes every 2 seconds
    _checkTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final packageName = await getCurrentApp();
      
      if (packageName != null && packageName != _lastPackageName) {
        _lastPackageName = packageName;
        _appChangeController?.add(packageName);
        await _handleAppChange(packageName);
      }
    });
  }

  static void stopMonitoring() {
    _checkTimer?.cancel();
    _appChangeController?.close();
    _appChangeController = null;
  }

  static Future<void> _handleAppChange(String packageName) async {
    // Check if in focus time hours
    final settings = await StorageService.getFocusTimeSettings();
    if (settings.isInFocusTime(DateTime.now())) {
      return;
    }

    // Check if app is in intention list
    final intendApps = await StorageService.getIntendApps();
    final intendApp = intendApps.firstWhere(
      (app) => app.packageName == packageName && app.isEnabled,
      orElse: () => IntendApp(
        packageName: '',
        appName: '',
        intentionPrompt: '',
        isEnabled: false,
      ),
    );

    if (intendApp.packageName.isNotEmpty) {
      await NotificationService.showIntentionPrompt(
        intendApp.appName,
        intendApp.intentionPrompt,
      );
    }
  }

  static Stream<String>? get appChangeStream => _appChangeController?.stream;
}
