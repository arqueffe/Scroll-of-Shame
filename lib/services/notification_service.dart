import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static const String channelId = 'shame_notifications';
  static const String channelName = 'Shame Notifications';
  static const String channelDescription = 'Notifications to shame you for using time-wasting apps';

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _notifications.initialize(initSettings);
    
    // Create notification channel
    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<void> showShameNotification(
      String appName, String message) async {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      '🔔 Caught you!',
      message,
      details,
    );
  }
}
