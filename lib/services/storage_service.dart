import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shame_app.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Initialize with default apps if first run
    final apps = await getIntendApps();
    if (apps.isEmpty) {
      await _initializeDefaultApps();
    }
  }

  static Future<void> _initializeDefaultApps() async {
    final defaultApps = [
      IntendApp(
        packageName: 'com.reddit.frontpage',
        appName: 'Reddit',
        intentionPrompt: '💭 Opening Reddit with intention? Set a time limit for yourself.',
      ),
      IntendApp(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        intentionPrompt: '📸 Before scrolling, what are you looking for?',
      ),
      IntendApp(
        packageName: 'com.zhiliaoapp.musically',
        appName: 'TikTok',
        intentionPrompt: '⏰ Ready for TikTok? Consider a 10-minute timer.',
      ),
      IntendApp(
        packageName: 'com.google.android.youtube',
        appName: 'YouTube',
        intentionPrompt: '🎥 What do you want to watch? Being specific helps.',
      ),
      IntendApp(
        packageName: 'com.twitter.android',
        appName: 'Twitter/X',
        intentionPrompt: '🐦 Checking in on Twitter? Set an intention for this session.',
      ),
      IntendApp(
        packageName: 'com.facebook.katana',
        appName: 'Facebook',
        intentionPrompt: '👋 Opening Facebook - what are you hoping to find?',
      ),
      IntendApp(
        packageName: 'com.snapchat.android',
        appName: 'Snapchat',
        intentionPrompt: '👻 Time for Snapchat? Quick check-in or longer session?',
      ),
      IntendApp(
        packageName: 'com.netflix.mediaclient',
        appName: 'Netflix',
        intentionPrompt: '📺 Netflix time - what are you in the mood for?',
      ),
      IntendApp(
        packageName: 'com.pinterest',
        appName: 'Pinterest',
        intentionPrompt: '📌 Browsing Pinterest? Try setting a specific search goal.',
      ),
      IntendApp(
        packageName: 'com.tumblr',
        appName: 'Tumblr',
        intentionPrompt: '🌀 Opening Tumblr - consider what you want to accomplish.',
      ),
    ];

    for (final app in defaultApps) {
      await addIntendApp(app);
    }
  }

  static Future<List<IntendApp>> getIntendApps() async {
    final jsonList = _prefs.getStringList('intend_apps') ?? 
                     _prefs.getStringList('shame_apps') ?? [];
    return jsonList
        .map((json) => IntendApp.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addIntendApp(IntendApp app) async {
    final apps = await getIntendApps();
    
    // Check if app already exists
    if (apps.any((a) => a.packageName == app.packageName)) {
      return;
    }
    
    apps.add(app);
    await _saveIntendApps(apps);
  }

  static Future<void> updateIntendApp(IntendApp app) async {
    final apps = await getIntendApps();
    final index = apps.indexWhere((a) => a.packageName == app.packageName);
    
    if (index != -1) {
      apps[index] = app;
      await _saveIntendApps(apps);
    }
  }

  static Future<void> removeIntendApp(String packageName) async {
    final apps = await getIntendApps();
    apps.removeWhere((app) => app.packageName == packageName);
    await _saveIntendApps(apps);
  }

  static Future<void> _saveIntendApps(List<IntendApp> apps) async {
    final jsonList = apps.map((app) => jsonEncode(app.toJson())).toList();
    await _prefs.setStringList('intend_apps', jsonList);
  }

  static Future<FocusTimeSettings> getFocusTimeSettings() async {
    final json = _prefs.getString('focus_time_settings') ?? 
                 _prefs.getString('shame_free_settings');
    if (json == null) {
      return FocusTimeSettings();
    }
    return FocusTimeSettings.fromJson(
        jsonDecode(json) as Map<String, dynamic>);
  }

  static Future<void> saveFocusTimeSettings(FocusTimeSettings settings) async {
    await _prefs.setString(
        'focus_time_settings', jsonEncode(settings.toJson()));
  }
}
