import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';


class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static late Function(String?) onNotificationResponse;

  // Initialize the notification service and set onSelectNotification callback
  // Initialize the notification service and pass the onNotificationResponse callback.
  static Future<void> init(Function(String?) onNotificationResponseCallback) async {
    onNotificationResponse = onNotificationResponseCallback;

    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/greenlogo'); // Icon for notifications

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Initialize the plugin without onSelectNotification
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    // Initialize the plugin with the new onDidReceiveNotificationResponse parameter.
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final String? payload = response.payload;
        if (onNotificationResponse != null) {
          onNotificationResponse(payload);
        }
      },
    );
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
    // Create a timestamp string using ISO8601 format.
    String timestamp = DateTime.now().toIso8601String(); // e.g. "2025-04-04T01:10:00.000"
    // Store in the expected format: "timestamp|title:body"
    notifications.add('$timestamp|$title: $body');
    await _storage.write(key: 'notifications', value: notifications.join(';'));

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
