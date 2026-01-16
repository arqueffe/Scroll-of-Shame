# Scroll-of-Shame

A Flutter app that helps you stay productive by shaming you for using time-wasting apps. Monitor your app usage and get notifications when you open apps like Reddit, Instagram, TikTok, YouTube, and more!

## Features

- 📱 Monitor your app usage in real-time
- 🔔 Get shame notifications when using time-wasting apps
- 🌙 Set shame-free hours (no notifications during specified times)
- 📋 Pre-populated list of popular time-wasting apps
- ➕ Add custom apps to your shame list
- 🎨 Modern, dark-themed UI
- ⚙️ Easy enable/disable for individual apps

## Installation

1. Download the latest APK from the [Releases](https://github.com/arqueffe/Scroll-of-Shame/releases) page
2. Install the APK on your Android device
3. Grant the required permissions (Usage Access)
4. Enable monitoring from the home screen

## Building from Source

```bash
# Clone the repository
git clone https://github.com/arqueffe/Scroll-of-Shame.git
cd Scroll-of-Shame

# Install dependencies
flutter pub get

# Build APK
flutter build apk --release --target-platform android-arm64
```

## How It Works

This app uses Android's UsageStatsManager API to monitor which apps are currently in the foreground. When you open an app on your shame list during active hours, you'll receive a notification with a custom shame message.

## Technical Details - How to Detect Current Foreground App in Flutter (Android)

Creating a Flutter Android app that monitors which application the user is currently using requires native Android platform integration, as Flutter doesn't provide this capability out of the box. This guide explores the most effective approaches, required permissions, implementation strategies, and available packages.

### Understanding the Challenge

Since Android Lollipop (API 21), Google deprecated the traditional `getRunningTasks()` method that developers previously used to detect the foreground app[1][2]. This change was intentional—Google wanted to limit third-party access to user activity data for privacy reasons. However, Android still provides legitimate mechanisms for apps that have valid use cases, primarily through **UsageStatsManager** and **AccessibilityService**.

### Two Main Approaches

#### **Approach 1: UsageStatsManager (Recommended)**

The UsageStatsManager API is the primary recommended method for detecting which app is currently in the foreground. This approach requires special permissions but is less invasive than accessibility services and generally more acceptable to users and app stores.

**How It Works**

UsageStatsManager provides access to device usage history, including which apps have been in the foreground and when[3][4]. By querying recent usage events, you can determine the currently active application. The API has been available since Android 5.0 (API level 21)[5].

**Required Permission**

You must declare the `PACKAGE_USAGE_STATS` permission in your AndroidManifest.xml:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    
    <uses-permission 
        android:name="android.permission.PACKAGE_USAGE_STATS"
        tools:ignore="ProtectedPermissions" />
    
    <application>
        <!-- Your app configuration -->
    </application>
</manifest>
```

This is a **system-level permission**, meaning it cannot be requested at runtime like camera or location permissions. Instead, users must manually grant access through the device Settings app[3][5].

**Requesting Permission**

To direct users to the settings page where they can grant usage access:

```kotlin
// In your Android native code (MainActivity.kt or plugin)
val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
startActivity(intent)
```

From Flutter, you would trigger this via a method channel[6][7].

**Implementation via Method Channel**

Flutter communicates with native Android code through platform channels[6]. Here's a complete implementation:

**Flutter Side (Dart):**

```dart
import 'package:flutter/services.dart';

class ForegroundAppDetector {
  static const platform = MethodChannel('com.yourapp/foreground_detector');
  
  // Check if permission is granted
  Future<bool> hasUsagePermission() async {
    try {
      final bool hasPermission = await platform.invokeMethod('hasUsagePermission');
      return hasPermission;
    } on PlatformException catch (e) {
      print("Failed to check permission: ${e.message}");
      return false;
    }
  }
  
  // Request usage access permission (opens Settings)
  Future<void> requestUsagePermission() async {
    try {
      await platform.invokeMethod('requestUsagePermission');
    } on PlatformException catch (e) {
      print("Failed to request permission: ${e.message}");
    }
  }
  
  // Get the current foreground app package name
  Future<String?> getForegroundApp() async {
    try {
      final String? packageName = await platform.invokeMethod('getForegroundApp');
      return packageName;
    } on PlatformException catch (e) {
      print("Failed to get foreground app: ${e.message}");
      return null;
    }
  }
}
```

**Android Side (Kotlin):**

In your `MainActivity.kt` or plugin class:

```kotlin
package com.yourapp

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.yourapp/foreground_detector"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasUsagePermission" -> {
                        result.success(hasUsageStatsPermission())
                    }
                    "requestUsagePermission" -> {
                        requestUsageStatsPermission()
                        result.success(null)
                    }
                    "getForegroundApp" -> {
                        val packageName = getForegroundPackageName()
                        result.success(packageName)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
    
    private fun hasUsageStatsPermission(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val mode = appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
            return mode == AppOpsManager.MODE_ALLOWED
        }
        return false
    }
    
    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        startActivity(intent)
    }
    
    private fun getForegroundPackageName(): String? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) 
                as UsageStatsManager
            
            var packageName: String? = null
            
            // Try multiple time intervals for reliability
            val intervals = listOf(
                1000L,           // 1 second
                60000L,          // 1 minute  
                3600000L,        // 1 hour
                43200000L        // 12 hours
            )
            
            for (interval in intervals) {
                val end = System.currentTimeMillis()
                val begin = end - interval
                
                val usageEvents = usageStatsManager.queryEvents(begin, end)
                val event = UsageEvents.Event()
                
                while (usageEvents.hasNextEvent()) {
                    usageEvents.getNextEvent(event)
                    if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                        packageName = event.packageName
                    }
                }
                
                // If we found a package, return it
                if (packageName != null) {
                    return packageName
                }
            }
        }
        return null
    }
}
```

This implementation checks multiple time intervals (1 second, 1 minute, 1 hour, 12 hours) to improve reliability, as recommended by developers who have worked extensively with UsageStatsManager[8]. The API only updates when apps move to the foreground, so if the current app has been in the foreground for a while, you need to look further back in time.

**Continuous Background Monitoring**

To continuously monitor app usage in the background, combine UsageStatsManager with a background service. Flutter offers several options:

1. **flutter_background_service** package[9] - for long-running services
2. **flutter_foreground_task** package[10] - shows persistent notification
3. **workmanager** package[11][12] - for periodic tasks (minimum 15-minute intervals)

For continuous monitoring, `flutter_background_service` is most appropriate. Add it to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_background_service: ^5.0.0
```

**Background Service Setup:**

```dart
import 'package:flutter_background_service/flutter_background_service.dart';
import 'dart:async';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'foreground_app_detector',
      initialNotificationTitle: 'App Monitor',
      initialNotificationContent: 'Monitoring app usage',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
    ),
  );
  
  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Periodic check every 2 seconds
  Timer.periodic(const Duration(seconds: 2), (timer) async {
    if (service is AndroidServiceInstance) {
      // Call your method channel to get foreground app
      final detector = ForegroundAppDetector();
      final packageName = await detector.getForegroundApp();
      
      if (packageName != null) {
        print('Current foreground app: $packageName');
        // Store in database, send to server, etc.
      }
    }
  });
}
```

Don't forget to add the required permissions for foreground services:

```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

#### **Approach 2: AccessibilityService (Real-time Detection)**

AccessibilityService provides true real-time detection of foreground app changes through an event-driven model[13][14]. This is more powerful than UsageStatsManager but requires more invasive permissions.

**How It Works**

AccessibilityService was designed to help users with disabilities interact with their devices. When enabled, it receives events about UI changes, including when apps come to the foreground[13][15].

**Flutter Package**

The `flutter_accessibility_service` package provides Flutter integration[14][15]:

```yaml
dependencies:
  flutter_accessibility_service: ^1.0.0
```

**Implementation:**

```dart
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';

class AccessibilityAppDetector {
  StreamSubscription<AccessibilityEvent>? _subscription;
  
  // Check if permission is enabled
  Future<bool> hasPermission() async {
    return await FlutterAccessibilityService.isAccessibilityPermissionEnabled();
  }
  
  // Request permission (opens accessibility settings)
  Future<void> requestPermission() async {
    await FlutterAccessibilityService.requestAccessibilityPermission();
  }
  
  // Start listening to accessibility events
  void startListening(Function(String packageName) onAppChanged) {
    _subscription = FlutterAccessibilityService.accessStream.listen((event) {
      if (event.packageName != null) {
        onAppChanged(event.packageName!);
        print('Foreground app changed to: ${event.packageName}');
      }
    });
  }
  
  // Stop listening
  void stopListening() {
    _subscription?.cancel();
  }
}

// Usage example
void main() {
  final detector = AccessibilityAppDetector();
  
  // Check permission
  detector.hasPermission().then((hasPermission) {
    if (!hasPermission) {
      // Request permission
      detector.requestPermission();
    } else {
      // Start monitoring
      detector.startListening((packageName) {
        print('Current app: $packageName');
      });
    }
  });
}
```

The accessibility service must be declared in your AndroidManifest.xml and requires a corresponding service implementation on the native side. The `flutter_accessibility_service` package handles this for you[15].

**Pros and Cons:**

**Pros:**
- True real-time, event-driven detection
- No polling required
- Can access detailed UI information beyond package names

**Cons:**
- Very invasive permission that many users distrust
- May be flagged during Google Play Store review
- Typically only appropriate for apps with legitimate accessibility features
- Requires users to navigate to Settings > Accessibility and manually enable

### Comparison of Approaches

| Feature | UsageStatsManager | AccessibilityService |
|---------|-------------------|---------------------|
| **Real-time** | Polling-based (near real-time) | Event-driven (true real-time) |
| **Permission invasiveness** | Moderate | High |
| **User acceptance** | Generally acceptable | Often distrusted |
| **Play Store approval** | Usually approved[3][5] | May require justification[16][13] |
| **Battery impact** | Low to moderate (with polling) | Low (event-driven) |
| **Reliability** | High with proper intervals[8] | Very high |
| **Information provided** | Package name[1] | Package name + UI details[15] |
| **Minimum Android version** | API 21 (Lollipop)[5] | API 14+ |

### Available Flutter Packages

Several packages are available on pub.dev, though most have limitations:

1. **app_usage** (^4.0.1)[17]
   - Retrieves historical app usage statistics
   - Android only
   - Uses UsageStatsManager
   - **Not suitable for real-time continuous monitoring**[18]
   - Good for showing usage reports/analytics

2. **current_app_detector** (^1.0.4)[19][20]
   - Provides `getCurrentApp()` and `goHome()` methods
   - Android only
   - Limited documentation and maintenance
   - May work but less battle-tested

3. **usage_stats** (pub.dev)[21]
   - Similar to app_usage
   - Requires minimum API level 22
   - Historical data focus

4. **flutter_accessibility_service** (^1.0.0)[14][15]
   - Real-time foreground app detection
   - Streams accessibility events
   - Requires accessibility permission
   - Well-documented with examples

### Best Practices and Recommendations

**For Most Use Cases: UsageStatsManager + Background Service**

This combination provides the best balance of functionality, user acceptance, and reliability:

1. Implement UsageStatsManager via method channel[3][6][7]
2. Use `flutter_background_service` for continuous monitoring[9]
3. Poll every 1-2 seconds for near real-time detection[22]
4. Check multiple time intervals for reliability[8]
5. Show clear notification explaining why the service is running[23][9]

**For Accessibility Apps: AccessibilityService**

If your app has a legitimate accessibility purpose:

1. Use `flutter_accessibility_service` package[14][15]
2. Provide clear explanation of why accessibility permission is needed
3. Prepare justification for Play Store review[13]

**Permission Handling Best Practices**

- Explain clearly why you need usage access before requesting[24]
- Show in-app instructions with screenshots of Settings flow[5]
- Check permission status before attempting operations[3]
- Gracefully handle permission denial
- For background services, show persistent notification on Android 8+[23][9]

**Battery Optimization**

- Use reasonable polling intervals (2-5 seconds, not milliseconds)[22]
- Consider using `workmanager` if less frequent checks are acceptable (15+ min)[11][12]
- Stop monitoring when not needed
- Respect Android Doze mode and App Standby[23][25]

### Complete Example Implementation

Here's a minimal but complete example combining UsageStatsManager with periodic checking:

```dart
// lib/foreground_detector.dart
import 'package:flutter/services.dart';
import 'dart:async';

class ForegroundDetector {
  static const platform = MethodChannel('com.yourapp/detector');
  Timer? _timer;
  String? _lastPackageName;
  final Function(String packageName)? onAppChanged;
  
  ForegroundDetector({this.onAppChanged});
  
  Future<bool> checkPermission() async {
    try {
      return await platform.invokeMethod('hasPermission');
    } catch (e) {
      print('Error checking permission: $e');
      return false;
    }
  }
  
  Future<void> requestPermission() async {
    await platform.invokeMethod('requestPermission');
  }
  
  Future<String?> getCurrentApp() async {
    try {
      return await platform.invokeMethod('getCurrentApp');
    } catch (e) {
      print('Error getting current app: $e');
      return null;
    }
  }
  
  void startMonitoring({Duration interval = const Duration(seconds: 2)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      final packageName = await getCurrentApp();
      if (packageName != null && packageName != _lastPackageName) {
        _lastPackageName = packageName;
        onAppChanged?.call(packageName);
      }
    });
  }
  
  void stopMonitoring() {
    _timer?.cancel();
  }
}

// Usage
void main() async {
  final detector = ForegroundDetector(
    onAppChanged: (packageName) {
      print('App changed to: $packageName');
    },
  );
  
  if (!await detector.checkPermission()) {
    await detector.requestPermission();
  } else {
    detector.startMonitoring();
  }
}
```

With the corresponding Kotlin implementation shown earlier, this provides a robust solution for detecting the current foreground app in Flutter.

### Alternative Considerations

**For Simple Use Cases**

If you only need to detect when your own app goes to background/foreground, use Flutter's built-in `WidgetsBindingObserver`[26][27]:

```dart
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print('App in foreground');
        break;
      case AppLifecycleState.paused:
        print('App in background');
        break;
      default:
        break;
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
```

This doesn't require special permissions and is sufficient if you only care about your own app's state[26][28].

**iOS Considerations**

The techniques described here are Android-specific. iOS does not provide equivalent APIs for third-party apps to detect the foreground app due to stricter privacy restrictions[16]. If you need cross-platform functionality, you'll need to implement iOS-specific workarounds or accept that this feature is Android-only.

### Conclusion

Detecting the current foreground app in Flutter requires platform-specific Android implementation using either UsageStatsManager or AccessibilityService. For most applications, **UsageStatsManager combined with method channels and a background service** provides the optimal balance of functionality, user acceptance, and maintainability. The implementation involves native Kotlin code, Flutter method channels, and careful permission handling.

While several packages exist on pub.dev, building your own implementation via method channels gives you full control and deeper understanding of the underlying mechanisms. Start with the UsageStatsManager approach, implement proper permission flows, and only consider AccessibilityService if you have a genuine accessibility use case that justifies the more invasive permissions.

Citations:
[1] Alternative to getRunningTasks in Android L https://stackoverflow.com/questions/26400469/alternative-to-getrunningtasks-in-android-l
[2] getRunningTasks doesn't work in Android L https://stackoverflow.com/questions/24625936/getrunningtasks-doesnt-work-in-android-l
[3] android - How to use UsageStatsManager? https://stackoverflow.com/questions/26431795/how-to-use-usagestatsmanager
[4] UsageStatsManager | API reference - Android Developers https://developer.android.com/reference/android/app/usage/UsageStatsManager
[5] Accessing App Usage History In Android https://www.droidcon.com/2022/02/08/accessing-app-usage-history-in-android/
[6] Writing custom platform-specific code https://docs.flutter.dev/platform-integration/platform-channels
[7] Using Flutter's MethodChannel to invoke Kotlin code for ... https://blog.logrocket.com/using-flutters-methodchannel-invoke-kotlin-code-android/
[8] Using UsageStatsManager to get the foreground app https://stackoverflow.com/questions/38971472/using-usagestatsmanager-to-get-the-foreground-app
[9] flutter_background_service | Flutter package https://pub.dev/packages/flutter_background_service
[10] flutter_foreground_task | Flutter package https://pub.dev/packages/flutter_foreground_task
[11] Implementing Background Execution with Flutter ... https://vibe-studio.ai/insights/implementing-background-execution-with-flutter-workmanager
[12] Handling Background Tasks with WorkManager in Flutter - Vibe Studio https://vibe-studio.ai/insights/handling-background-tasks-with-workmanager
[13] The Android API That Can See Everything 👀 https://www.droidcon.com/2025/09/29/the-android-api-that-can-see-everything-%F0%9F%91%80/
[14] How to use accessibility service in Flutter - Platform Specific https://stackoverflow.com/questions/71869318/how-to-use-accessibility-service-in-flutter-platform-specific
[15] flutter_accessibility_service example | Flutter package https://pub.dev/packages/flutter_accessibility_service/example
[16] Flutter App tracking https://www.reddit.com/r/FlutterDev/comments/1fowl1p/flutter_app_tracking/
[17] app_usage | Flutter package https://pub.dev/packages/app_usage
[18] Flutter app to track smartphone app activity? https://www.reddit.com/r/FlutterDev/comments/k5fvq2/flutter_app_to_track_smartphone_app_activity/
[19] current_app_detector 1.0.4 | Flutter package https://pub.dev/packages/current_app_detector/versions/1.0.4
[20] current_app_detector | Flutter package https://pub.dev/packages/current_app_detector
[21] usage_stats | Flutter package https://pub.dev/packages/usage_stats
[22] Flutter Timer: A Simple Way to Manage Background ... https://blog.stackademic.com/flutter-timer-a-simple-way-to-manage-background-process-in-your-flutter-apps-04bce279fe1b
[23] Flutter Background Service Android Keeping Your Apps ... https://blog.founders.illinois.edu/flutter-background-service-android/
[24] permission_handler | Flutter package - Pub.dev https://pub.dev/packages/permission_handler
[25] Background Tasks & Services in Flutter: Best Practices https://vibe-studio.ai/insights/background-tasks-services-in-flutter-best-practices
[26] How do I check if the Flutter application is in the foreground ... https://stackoverflow.com/questions/51835039/how-do-i-check-if-the-flutter-application-is-in-the-foreground-or-not
[27] Flutter App Security Best Practices https://talent500.com/blog/flutter-app-security-best-practices/
[28] Flutter Tutorial - Detect App Background & App Closed https://www.youtube.com/watch?v=JyapvlrmM24
[29] How to access app usage statistics in a Flutter app? https://stackoverflow.com/questions/77282752/how-to-access-app-usage-statistics-in-a-flutter-app
[30] Using Flutter Background Services: A Comprehensive Guide https://bugsee.com/flutter/flutter-background-service/
[31] How to create a Service which continuously monitors app ... https://stackoverflow.com/questions/20416610/how-to-create-a-service-which-continuously-monitors-app-usage-information
[32] Detect when app comes to foreground #4553 - flutter/flutter https://github.com/flutter/flutter/issues/4553
[33] The Ultimate Guide to flutter_background_service (with ... https://www.youtube.com/watch?v=GwnJ21LlXl0
[34] Is there any way to track user usage of my app in flutter? https://stackoverflow.com/questions/77397001/is-there-any-way-to-track-user-usage-of-my-app-in-flutter
[35] current_app_detector 1.0.4 license | Flutter package https://pub.dev/packages/current_app_detector/versions/1.0.4/license
[36] Android background service with Flutter https://plugfox.dev/android-background-service-with-flutter/
[37] Coding Session 2 - Android UsageStats API in Flutter https://www.youtube.com/watch?v=OcZoX_IZ8a0
[38] Flutter : interagir avec du code natif (avec les method channels) https://blog.ippon.fr/2025/01/08/flutter-interagir-avec-du-code-natif-avec-les-method-channels-2/
[39] Flutter Background Services and Foreground ... https://www.youtube.com/watch?v=8spWK_9BLoY
[40] Integrating Native SDKs Using Method Channels https://docs.flutterflow.io/concepts/advanced/method-channels/
[41] How to use Flutter Method Channel in background (app ... https://stackoverflow.com/questions/63228013/how-to-use-flutter-method-channel-in-background-app-minimised-closed
[42] Android Foreground Service with Flutter(2?) : r/flutterhelp https://www.reddit.com/r/flutterhelp/comments/m0u7sk/android_foreground_service_with_flutter2/
[43] current_app_detector 1.0.4 changelog | Flutter package https://pub.dev/packages/current_app_detector/versions/1.0.4/changelog
[44] Mastering Background Tasks in Flutter with Workmanager https://www.dhiwise.com/post/work-wonders-with-flutter-workmanager-ultimate-guide
[45] How to run workmanager every 15 minutes in the background in flutter IOS https://stackoverflow.com/questions/64713457/how-to-run-workmanager-every-15-minutes-in-the-background-in-flutter-ios
[46] Concurrency and isolates https://docs.flutter.dev/perf/isolates
[47] ForegroundServiceStartNotAllow... https://github.com/transistorsoft/flutter_background_geolocation/issues/703
[48] How to perform periodic background operations using work manager in flutter android https://www.youtube.com/watch?v=qmVVK7Bm5a4
[49] Background Services in Flutter Add-to-App Case https://leancode.co/blog/background-services-in-flutter-add-to-app
[50] Practical Accessibility in Flutter (and Code You'll Actually ... https://dcm.dev/blog/2025/06/30/accessibility-flutter-practical-tips-tools-code-youll-actually-use/
[51] How to open Flutter app programmatically using Package name only https://stackoverflow.com/questions/73899251/how-to-open-flutter-app-programmatically-using-package-name-only
[52] Trying to get a list of currently running applications, but the ... https://www.reddit.com/r/androiddev/comments/381pzc/trying_to_get_a_list_of_currently_running/
[53] Using Native Code with Flutter https://www.youtube.com/watch?v=CUM5OIw9zDI
[54] Using packages https://docs.flutter.dev/packages-and-plugins/using-packages
[55] How to change Flutter package name after development https://www.linkedin.com/posts/waleed-ashrf_flutter-mobiledevelopment-devtips-activity-7341359161995079680-YpQN
[56] How to Detect Accessibility Service Abuse on Android ... https://www.appdome.com/how-to/account-takeover-prevention/android-and-ios-trojans/detect-malware-privilege-escalation-to-accessibilityservice/
[57] Remove reliance on android.permission.GET_TASKS #182 https://github.com/transistorsoft/react-native-background-fetch/issues/182
[58] android - ActivityManager get topActivity package name https://stackoverflow.com/questions/47857251/activitymanager-get-topactivity-package-name
[59] Best Flutter Monitoring Tools for App Performance (2025) https://www.zipy.ai/blog/flutter-monitoring-tools
[60] how to use method channels in Flutter - Maharshi's Blog https://maharshisinha.hashnode.dev/seamless-flutter-native-integration-the-power-of-method-channels
[61] Whats your Strategy to monitor flutter app usage? https://www.reddit.com/r/FlutterDev/comments/1hcw5xt/whats_your_strategy_to_monitor_flutter_app_usage/
[62] Using Firebase Crashlytics to Monitor Flutter App ... https://technorizen.com/using-firebase-crashlytics-to-monitor-flutter-app-performance/
[63] Get started using App Check in Flutter apps - Firebase - Google https://firebase.google.com/docs/app-check/flutter/default-providers
[64] Get the foreground app in Android 6.0.1. ... https://stackoverflow.com/questions/38355149/get-the-foreground-app-in-android-6-0-1-usagestatsmanager-queryusagestats-retur
[65] A Comprehensive Guide to Developing and Distributing ... https://www.itpathsolutions.com/a-comprehensive-guide-to-developing-and-distributing-flutter-plugins-on-pub-dev
[66] How to get android app usage status app duration on ... https://www.youtube.com/watch?v=kATZSb-Zu08
[67] Create a Flutter plugin for iOS and Android step by step https://apparencekit.dev/blog/flutter-create-plugin/
[68] Binding to native Android code using dart:ffi - Flutter documentation https://docs.flutter.dev/platform-integration/android/c-interop
[69] Flutter: run code like a timer when app is running in background https://stackoverflow.com/questions/72300971/flutter-run-code-like-a-timer-when-app-is-running-in-background
[70] Flutter Plugin Development: A Comprehensive Guide: Part 2 https://www.mutuallyhuman.com/flutter-plugin-development-a-comprehensive-guide-part-2/
[71] Always Active: How to Implement Background Services in Your @FlutterFlow App https://www.youtube.com/watch?v=oJDkoYfVA1g
