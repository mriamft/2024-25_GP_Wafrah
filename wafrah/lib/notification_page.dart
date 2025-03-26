import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'notification_service.dart';

class NotificationPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;

  const NotificationPage({
    super.key,
    required this.userName,
    required this.phoneNumber,
  });

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool hasNewNotifications = false;
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // Load notifications from secure storage.
  // Expected format for each notification: "timestamp|title:body"
  void _loadNotifications() async {
    String? storedNotifications = await _storage.read(key: 'notifications');
    if (storedNotifications != null && storedNotifications.isNotEmpty) {
      // Split by semicolon and remove any empty entries.
      notifications = storedNotifications
          .split(';')
          .where((s) => s.trim().isNotEmpty)
          .toList();
    }
    setState(() {
      hasNewNotifications = notifications.isNotEmpty;
    });
  }

  // Delete a single notification with a confirmation dialog.
  void _deleteNotification(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تأكيد حذف الإشعار',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'GE-SS-Two-Bold',
            fontSize: 20,
            color: Color(0xFF3D3D3D),
          ),
        ),
        content: const Text(
          'هل أنت متأكد أنك تريد حذف هذا الإشعار؟',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'GE-SS-Two-Light',
            color: Color(0xFF3D3D3D),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close without deleting.
                },
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Light',
                    color: Color(0xFF838383),
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    // Since we are displaying reversed list, calculate original index.
                    int originalIndex = notifications.length - 1 - index;
                    notifications.removeAt(originalIndex);
                    hasNewNotifications = notifications.isNotEmpty;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تم حذف الإشعار بنجاح.',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontFamily: 'GE-SS-Two-Light'),
                      ),
                      backgroundColor: Color(0xFF0FBE7C),
                    ),
                  );
                },
                child: const Text(
                  'حذف الإشعار',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Light',
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Remove all notifications.
  void _clearNotifications() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تأكيد حذف جميع الإشعارات',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'GE-SS-Two-Bold',
            fontSize: 20,
            color: Color(0xFF3D3D3D),
          ),
        ),
        content: const Text(
          'هل أنت متأكد أنك تريد حذف جميع الإشعارات؟',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'GE-SS-Two-Light',
            color: Color(0xFF3D3D3D),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Light',
                    color: Color(0xFF838383),
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () async {
                  await _storage.delete(key: 'notifications');
                  setState(() {
                    notifications.clear();
                    hasNewNotifications = false;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تم حذف جميع الإشعارات بنجاح.',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontFamily: 'GE-SS-Two-Light'),
                      ),
                      backgroundColor: Color(0xFF0FBE7C),
                    ),
                  );
                },
                child: const Text(
                  'حذف الكل',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Light',
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Back arrow tap handler.
  void _onArrowTap() {
    Navigator.pop(context);
  }

  // Fallback: get current time if parsing fails.
  String _getCurrentDateTime() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy-MM-dd HH:mm').format(now);
  }

  @override
  Widget build(BuildContext context) {
    // Reverse the list so that the newest notifications appear at the top.
    final List<String> sortedNotifications = notifications.reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Back Arrow in header.
          Positioned(
            top: 60,
            right: 15,
            child: GestureDetector(
              onTap: _onArrowTap,
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF3D3D3D),
                size: 28,
              ),
            ),
          ),
          // Header text.
          const Positioned(
            top: 58,
            left: 170,
            child: Text(
              'إدارة الإشعارات',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),
          // "Delete All" button (top left).
          Positioned(
            top: 51,
            left: 15,
            child: ElevatedButton(
              onPressed: sortedNotifications.isEmpty ? null : _clearNotifications,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return const Color(0xFF707070);
                    }
                    return Colors.red;
                  },
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
              child: const Text(
                'حذف الكل',
                style: TextStyle(
                  fontFamily: 'GE-SS-Two-Light',
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          // Notifications List.
          Positioned(
            top: 100,
            left: 15,
            right: 15,
            bottom: 50,
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(sortedNotifications.length, (index) {
                  final notif = sortedNotifications[index];
                  String formattedTime;
                  String title;
                  String body;
                  // Expected format: "timestamp|title:body"
                  if (notif.contains('|')) {
                    final parts = notif.split('|');
                    if (parts.length >= 2) {
                      final timestampString = parts[0];
                      final content = parts[1];
                      final contentParts = content.split(':');
                      if (contentParts.length >= 2) {
                        title = contentParts[0];
                        // In case the body contains additional colons, join the remaining parts.
                        body = contentParts.sublist(1).join(':');
                      } else {
                        title = content;
                        body = '';
                      }
                      DateTime? notifTime = DateTime.tryParse(timestampString);
                      if (notifTime == null) {
                        formattedTime = _getCurrentDateTime();
                      } else {
                        formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(notifTime);
                      }
                    } else {
                      formattedTime = _getCurrentDateTime();
                      title = notif;
                      body = '';
                    }
                  } else {
                    // Fallback if not in expected format.
                    formattedTime = _getCurrentDateTime();
                    final contentParts = notif.split(':');
                    if (contentParts.length >= 2) {
                      title = contentParts[0];
                      body = contentParts.sublist(1).join(':');
                    } else {
                      title = notif;
                      body = '';
                    }
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Display the actual stored time.
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Text(
                          formattedTime,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF3D3D3D),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GE-SS-Two-Bold',
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Notification container with delete button.
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Delete button.
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteNotification(index);
                              },
                            ),
                            const SizedBox(width: 10),
                            // Notification content.
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Notification title.
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'GE-SS-Two-Light',
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  // Notification body.
                                  Text(
                                    body,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'GE-SS-Two-Light',
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
