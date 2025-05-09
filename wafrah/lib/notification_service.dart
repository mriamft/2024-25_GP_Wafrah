import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static late Function(String?) onNotificationResponse;

  static Future<void> init(
      Function(String?) onNotificationResponseCallback) async {
    onNotificationResponse = onNotificationResponseCallback;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@drawable/greenlogo'); 

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final String? payload = response.payload;
        onNotificationResponse(payload);
      },
    );
  }

  // Show notification
  static Future<void> showNotification(
      {required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'saving_plan_channel', 
      'Saving Plan Notifications',
      channelDescription: 'Notifications to track saving progress',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: 'greenlogo',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0, 
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x', 
    );
    await _storeNotification(title, body);
  }

  // Update this method in NotificationService to track new notifications
  static Future<void> _storeNotification(String title, String body) async {
    try {
      List<String> notifications = await getNotifications();
      String timestamp =
          DateTime.now().toIso8601String(); 
      notifications.add('$timestamp|$title: $body');
      await _storage.write(
          key: 'notifications', value: notifications.join(';'));

      // Update new notification flag
      await _storage.write(key: 'hasNewNotifications', value: 'true');
    } catch (e) {
      print("Error storing notification: $e");
    }
  }

  static Future<List<String>> getNotifications() async {
    try {
      String? storedNotifications = await _storage.read(key: 'notifications');
      if (storedNotifications != null && storedNotifications.isNotEmpty) {
        return storedNotifications.split(';');
      }
    } catch (e) {
      print("Error getting notifications: $e");
    }
    return [];
  }
}
