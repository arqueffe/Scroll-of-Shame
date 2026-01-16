import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shame_app.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Initialize with default shame apps if first run
    final apps = await getShameApps();
    if (apps.isEmpty) {
      await _initializeDefaultApps();
    }
  }

  static Future<void> _initializeDefaultApps() async {
    final defaultApps = [
      ShameApp(
        packageName: 'com.reddit.frontpage',
        appName: 'Reddit',
        shameMessage: '🛑 Really? Reddit again? Your productivity is crying!',
      ),
      ShameApp(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        shameMessage: '📸 Stop comparing your life to others! Get back to work!',
      ),
      ShameApp(
        packageName: 'com.zhiliaoapp.musically',
        appName: 'TikTok',
        shameMessage: '⏰ Those 15-second videos are stealing your life!',
      ),
      ShameApp(
        packageName: 'com.google.android.youtube',
        appName: 'YouTube',
        shameMessage: '🎥 "Just one more video" - famous last words!',
      ),
      ShameApp(
        packageName: 'com.twitter.android',
        appName: 'Twitter/X',
        shameMessage: '🐦 The timeline will still be there later. Promise!',
      ),
      ShameApp(
        packageName: 'com.facebook.katana',
        appName: 'Facebook',
        shameMessage: '👎 Facebook stalking won\'t make you successful!',
      ),
      ShameApp(
        packageName: 'com.snapchat.android',
        appName: 'Snapchat',
        shameMessage: '👻 Snap out of it! Time to be productive!',
      ),
      ShameApp(
        packageName: 'com.netflix.mediaclient',
        appName: 'Netflix',
        shameMessage: '📺 Netflix and chill? More like Netflix and kill your goals!',
      ),
      ShameApp(
        packageName: 'com.pinterest',
        appName: 'Pinterest',
        shameMessage: '📌 Pinning things won\'t accomplish them!',
      ),
      ShameApp(
        packageName: 'com.tumblr',
        appName: 'Tumblr',
        shameMessage: '🌀 Endless scrolling is not a hobby!',
      ),
    ];

    for (final app in defaultApps) {
      await addShameApp(app);
    }
  }

  static Future<List<ShameApp>> getShameApps() async {
    final jsonList = _prefs.getStringList('shame_apps') ?? [];
    return jsonList
        .map((json) => ShameApp.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addShameApp(ShameApp app) async {
    final apps = await getShameApps();
    
    // Check if app already exists
    if (apps.any((a) => a.packageName == app.packageName)) {
      return;
    }
    
    apps.add(app);
    await _saveShameApps(apps);
  }

  static Future<void> updateShameApp(ShameApp app) async {
    final apps = await getShameApps();
    final index = apps.indexWhere((a) => a.packageName == app.packageName);
    
    if (index != -1) {
      apps[index] = app;
      await _saveShameApps(apps);
    }
  }

  static Future<void> removeShameApp(String packageName) async {
    final apps = await getShameApps();
    apps.removeWhere((app) => app.packageName == packageName);
    await _saveShameApps(apps);
  }

  static Future<void> _saveShameApps(List<ShameApp> apps) async {
    final jsonList = apps.map((app) => jsonEncode(app.toJson())).toList();
    await _prefs.setStringList('shame_apps', jsonList);
  }

  static Future<ShameFreeSettings> getShameFreeSettings() async {
    final json = _prefs.getString('shame_free_settings');
    if (json == null) {
      return ShameFreeSettings();
    }
    return ShameFreeSettings.fromJson(
        jsonDecode(json) as Map<String, dynamic>);
  }

  static Future<void> saveShameFreeSettings(ShameFreeSettings settings) async {
    await _prefs.setString(
        'shame_free_settings', jsonEncode(settings.toJson()));
  }
}
