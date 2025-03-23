import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart'; // Import this for date formatting
import 'notification_service.dart';

class NotificationPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;

  const NotificationPage(
      {super.key, required this.userName, required this.phoneNumber});

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

  // Load notifications from secure storage
  void _loadNotifications() async {
    // Fetch notifications from secure storage
    String? storedNotifications = await _storage.read(key: 'notifications');
    if (storedNotifications != null) {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      notifications = storedNotifications.split(
          ';'); // Assuming stored notifications are separated by a semicolon
=======
      notifications = storedNotifications.split(';'); // Assuming notifications are stored as a semicolon-separated string
>>>>>>> Stashed changes
=======
      notifications = storedNotifications.split(';'); // Assuming notifications are stored as a semicolon-separated string
>>>>>>> Stashed changes
    }

    setState(() {
      hasNewNotifications = notifications.isNotEmpty;
    });
  }

  // Delete notification with confirmation dialog
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
                  Navigator.of(context)
                      .pop(); // Close the dialog without deleting
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
                    notifications.removeAt(index); // Delete the notification
                    hasNewNotifications = notifications.isNotEmpty;
                  });
                  Navigator.of(context)
                      .pop(); // Close the dialog after deleting
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تم حذف الإشعار بنجاح.',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'GE-SS-Two-Light',
                        ),
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

  // Remove all notifications from the list and secure storage
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
                  Navigator.of(context).pop(); // Close the dialog without deleting
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
                  Navigator.of(context).pop(); // Close the dialog after deleting
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تم حذف جميع الإشعارات بنجاح.',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'GE-SS-Two-Light',
                        ),
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

  // Handle arrow tap to go back
  void _onArrowTap() {
    Navigator.pop(context);
  }

  // Get current date and time
  String _getCurrentDateTime() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now); // Format date as yyyy-MM-dd HH:mm
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Back Arrow (as in the original header)
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

          // Header text (as in the original header)
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
          // "Delete All" button positioned on the top left
          Positioned(
            top: 51,
            left: 15,
            child: ElevatedButton(
  onPressed: notifications.isEmpty ? null : _clearNotifications, // Disable button if no notifications
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith<Color>( 
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return Color(0xFF707070); // Darker gray when the button is disabled
        }
        return Colors.red; // Color when the button is enabled
      },
    ),
    shape: MaterialStateProperty.all(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    )),
    padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
  ),
  child: const Text(
    'حذف الكل',
    style: TextStyle(
      fontFamily: 'GE-SS-Two-Light',
      color: Colors.white,
      fontSize: 12,
    ),
  ),
)

          ),
          // Notifications List wrapped in a SingleChildScrollView
          Positioned(
            top: 100,
            left: 15,
            right: 15,
            bottom: 50, // Adjust the bottom space if needed
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(notifications.length, (index) {
                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end, // Right align all content
                    children: [
                      // Date displayed outside the gray box
                      const Padding(
                        padding: EdgeInsets.only(right: 15.0),
                        child: Text(
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                          '2025-03-14', // Format it to YYYY-MM-DD
                          style: TextStyle(
=======
=======
>>>>>>> Stashed changes
                          _getCurrentDateTime(), // Show current date and time
                          style: const TextStyle(
>>>>>>> Stashed changes
                            fontSize: 14,
                            color: Color(0xFF3D3D3D),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GE-SS-Two-Bold',
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 5), // Space between date and notification

                      // Notification container with delete button
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[
                              300], // Slightly darker background for the notification box
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .start, // Align delete button to the left
                          children: [
                            // Delete Button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteNotification(
                                    index); // Show confirmation dialog
                              },
                            ),
                            const SizedBox(
                                width: 10), // Space between button and content
                            // Notification content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .end, // Right align everything
                                children: [
                                  // Notification title (bold)
                                  Text(
                                    notifications[index].split(":")[0], // Title
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold, // Bold title
                                      fontFamily: 'GE-SS-Two-Light',
                                    ),
                                  ),
                                  const SizedBox(
                                      height:
                                          5), // Space between title and body
                                  // Notification body
                                  Text(
                                    notifications[index].split(":")[1], // Body
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'GE-SS-Two-Light',
                                    ),
                                    textAlign:
                                        TextAlign.right, // Right align the text
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
