import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:wafrah/session_manager.dart';
import 'notification_service.dart';

class NotificationPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;

  const NotificationPage({
    Key? key,
    required this.userName,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    SessionManager.startTracking(context);
  }

  Future<void> _loadNotifications() async {
    final stored = await _storage.read(key: 'notifications');
    if (stored != null && stored.isNotEmpty) {
      notifications = stored
          .split(';')
          .where((s) => s.trim().isNotEmpty)
          .toList();
      notifications.sort((a, b) {
        final ta = _parseTimestamp(a);
        final tb = _parseTimestamp(b);
        return tb.compareTo(ta);
      });
    }
    setState(() {});
  }

  DateTime _parseTimestamp(String entry) {
    try {
      return DateTime.parse(entry.split('|')[0]);
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<void> _saveNotifications() async {
    await _storage.write(
      key: 'notifications',
      value: notifications.join(';'),
    );
  }

  void _deleteNotification(int index) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
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
            fontSize: 16,
            color: Color(0xFF3D3D3D),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'GE-SS-Two-Light',
                fontSize: 18,
                color: Color(0xFF838383),
              ),
            ),
          ),
          const SizedBox(width: 20),
          TextButton(
            onPressed: () async {
              Navigator.of(c).pop();
              notifications.removeAt(index);
              await _saveNotifications();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'تم حذف الإشعار بنجاح.',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'GE-SS-Two-Light',
                      fontSize: 16,
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
    );
  }

  void _clearNotifications() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
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
            fontSize: 16,
            color: Color(0xFF3D3D3D),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'GE-SS-Two-Light',
                fontSize: 18,
                color: Color(0xFF838383),
              ),
            ),
          ),
          const SizedBox(width: 20),
          TextButton(
            onPressed: () async {
              Navigator.of(c).pop();
              await _storage.delete(key: 'notifications');
              notifications.clear();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'تم حذف جميع الإشعارات بنجاح.',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'GE-SS-Two-Light',
                      fontSize: 16,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: notifications.isEmpty ? null : _clearNotifications,
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.disabled)) {
                          return const Color(0xFF707070);
                        }
                        return Colors.red;
                      }),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  const Text(
                    'إدارة الإشعارات',
                    style: TextStyle(
                      color: Color(0xFF3D3D3D),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'GE-SS-Two-Bold',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF3D3D3D),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Notifications List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: notifications.length,
                itemBuilder: (context, i) {
                  final entry = notifications[i];
                  final dt = _parseTimestamp(entry);
                  final dateStr = DateFormat('yyyy-MM-dd').format(dt);
                  final timeStr = DateFormat('hh:mm').format(dt);
                  final suffix = dt.hour < 12 ? 'صباحًا' : 'مساءً';
                  final content = entry.contains('|') ? entry.split('|')[1] : '';
                  final parts = content.split(':');
                  final title = parts[0];
                  final body = parts.length > 1 ? parts.sublist(1).join(':') : '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF3D3D3D),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'GE-SS-Two-Bold',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                suffix,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF3D3D3D),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'GE-SS-Two-Bold',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                timeStr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF3D3D3D),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'GE-SS-Two-Bold',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteNotification(i),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'GE-SS-Two-Light',
                                      ),
                                    ),
                                    if (body.isNotEmpty) ...[
                                      const SizedBox(height: 5),
                                      Text(
                                        body,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'GE-SS-Two-Light',
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}