import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Initialize the notification service
  static Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@drawable/greenlogo'); // Icon for notifications

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Show notification
  static Future<void> showNotification(
      {required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'saving_plan_channel', // Channel ID
      'Saving Plan Notifications', // Channel name
      channelDescription: 'Notifications to track saving progress',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: 'greenlogo',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x', // Optional payload
    );

    // Store notification
    await _storeNotification(title, body);
  }

  // Store notifications in secure storage
// Update this method in NotificationService to track new notifications
  static Future<void> _storeNotification(String title, String body) async {
    try {
      List<String> notifications = await getNotifications();
      notifications.add('$title: $body');
      await _storage.write(
          key: 'notifications', value: notifications.join(';'));

      // Update new notification flag
      await _storage.write(key: 'hasNewNotifications', value: 'true');
    } catch (e) {
      print("Error storing notification: $e");
    }
  }

  // Get stored notifications from secure storage
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
