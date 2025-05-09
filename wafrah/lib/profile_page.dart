import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'settings_page.dart' as Settings;

class ProfilePage extends StatefulWidget {
  String userName; 
  final String phoneNumber;
  final List<Map<String, dynamic>> accounts;

  ProfilePage({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [],
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Notification state variables
  bool showErrorNotification = false;
  String errorMessage = '';
  Color notificationColor = const Color(0xFFC62C2C);
  Timer? _notificationTimer;

  Color _arrowColor = const Color(0xFF3D3D3D);
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userName;
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  void _onArrowTap() {
    setState(() => _arrowColor = Colors.grey);
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => _arrowColor = const Color(0xFF3D3D3D));
      Navigator.pop(context);
    });
  }

  void _showEditNameDialog() {
    _nameController.text = widget.userName;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'تعديل الاسم',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'GE-SS-Two-Bold',
              fontSize: 18,
              color: Color(0xFF3D3D3D),
            ),
          ),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم الجديد',
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontFamily: 'GE-SS-Two-Light',
                      color: Color(0xFF838383),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () async {
                    String newName = _nameController.text.trim();

                    if (newName.isEmpty) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى إدخال اسم صالح'),
                          backgroundColor: Color(0xFFC62C2C),
                        ),
                      );
                      return;
                    }

                    bool isSuccess = await _updateNameInDatabase(newName);

                    Navigator.pop(dialogContext); // Close dialog

                    if (isSuccess) {
                      setState(() {
                        widget.userName = newName;
                      });

                      setState(() {
                        errorMessage = 'تم تعديل الاسم بنجاح';
                        notificationColor = const Color(0xFF2C8C68);
                        showErrorNotification = true;
                      });
                      _notificationTimer?.cancel();
                      _notificationTimer =
                          Timer(const Duration(seconds: 5), () {
                        if (mounted) {
                          setState(() {
                            showErrorNotification = false;
                          });
                        }
                      });

                      await Future.delayed(
                          const Duration(seconds: 5)); 
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Settings.SettingsPage(
                              userName: widget.userName,
                              phoneNumber: widget.phoneNumber,
                              accounts: widget.accounts,
                            ),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('فشل في تحديث الاسم'),
                          backgroundColor: Color(0xFFC62C2C),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'تعديل',
                    style: TextStyle(
                      fontFamily: 'GE-SS-Two-Light',
                      color: Color(0xFF2C8C68),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<bool> _updateNameInDatabase(String newName) async {
    print(widget.phoneNumber);
    final response = await http.post(
      Uri.parse('https://login-service.ngrok.io/update-username'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': widget.phoneNumber,
        'newUserName': newName,
      }),
    );

    if (response.statusCode == 200) {
      print('Username updated successfully');
      return true;
    } else {
      print('Failed to update username: ${response.body}');
      // Show error notification if update fails
      showNotification('فشل في تحديث الاسم');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Back arrow at top-right
          Positioned(
            top: 60,
            right: 15,
            child: GestureDetector(
              onTap: _onArrowTap,
              child: Icon(
                Icons.arrow_forward_ios,
                color: _arrowColor,
                size: 28,
              ),
            ),
          ),
          const Positioned(
            top: 58,
            left: 145,
            child: Text(
              'الحساب الشخصي',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 14,
            child: Container(
              width: 364,
              height: 148,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  const Positioned(
                    top: 20,
                    left: 310,
                    child: Text(
                      'الاسم',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5F5F5F),
                        fontFamily: 'GE-SS-Two-Light',
                      ),
                    ),
                  ),
                  Positioned(
                    top: 41,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _showEditNameDialog,
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFF3D3D3D),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GE-SS-Two-Bold',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    top: 78,
                    left: 277,
                    child: Text(
                      'رقم الجوال',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5F5F5F),
                        fontFamily: 'GE-SS-Two-Light',
                      ),
                    ),
                  ),
                  Positioned(
                    top: 99,
                    left: 235,
                    child: Text(
                      widget.phoneNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'GE-SS-Two-Bold',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 127,
            left: 268,
            child: Text(
              'الحساب الشخصي',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF5F5F5F),
                fontFamily: 'GE-SS-Two-Light',
              ),
            ),
          ),
          if (showErrorNotification)
            Positioned(
              top: 23,
              left: 19,
              child: Container(
                width: 353,
                height: 57,
                decoration: BoxDecoration(
                  color: notificationColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'GE-SS-Two-Light',
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void showNotification(String message,
      {Color color = const Color(0xFFC62C2C)}) {
    setState(() {
      errorMessage = message;
      notificationColor = color;
      showErrorNotification = true;
    });
    _notificationTimer?.cancel();
    _notificationTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          showErrorNotification = false;
        });
      }
    });
  }
}
