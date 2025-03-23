import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:wafrah/main.dart';
import 'package:wafrah/storage_service.dart';
import 'saving_plan_page.dart';
import 'transactions_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'reset_password_page.dart';
import 'notification_page.dart';
import 'support_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'banks_page.dart';
import 'package:another_flushbar/flushbar.dart';
// Import your goal page for navigation
import 'saving_plan_page2.dart';
import 'secure_storage_helper.dart'; // Import the secure storage helper

class SettingsPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;

  final List<Map<String, dynamic>> accounts;
  const SettingsPage({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [],
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Color _profileColor = const Color(0xFFD9D9D9);
  Color _resetPasswordColor = const Color(0xFFD9D9D9);
  Color _notificationColor = const Color(0xFFD9D9D9);
  Color _supportColor = const Color(0xFFD9D9D9);
  bool hasNewNotifications = false; // Track new notifications

  // Custom page transition
  Route _createNoTransitionRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(seconds: 0),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child; // No animation
      },
    );
  }

// In SettingsPage, check for new notifications in initState
  @override
  void initState() {
    super.initState();
    _checkForNewNotifications();
  }

// In SettingsPage, add the check for new notifications in initState
  void _checkForNewNotifications() async {
    String? hasNewNotifications =
        await _storage.read(key: 'hasNewNotifications');
    setState(() {
      this.hasNewNotifications = (hasNewNotifications == 'true');
    });
  }

//Profile Setting
  void _onProfileTap() {
    setState(() {
      _profileColor = Colors.grey[400]!;
    });
    Navigator.of(context)
        .push(_createNoTransitionRoute(ProfilePage(
            userName: widget.userName, phoneNumber: widget.phoneNumber)))
        .then((_) {
      setState(() {
        _profileColor = const Color(0xFFD9D9D9);
      });
    });
  }

//Method to handle password reset
  void _onResetPasswordTap() {
    setState(() {
      _resetPasswordColor = Colors.grey[400]!;
    });
    Navigator.of(context)
        .push(_createNoTransitionRoute(ResetPasswordPage(
            userName: widget.userName, phoneNumber: widget.phoneNumber)))
        .then((_) {
      setState(() {
        _resetPasswordColor = const Color(0xFFD9D9D9);
      });
    });
  }

  void _onNotificationTap() {
    setState(() {
      hasNewNotifications =
          false; // Mark notifications as read when opening the page
      _notificationColor =
          Colors.grey[400]!; // Change notification button color to normal
    });

    Navigator.of(context)
        .push(_createNoTransitionRoute(NotificationPage(
            userName: widget.userName, phoneNumber: widget.phoneNumber)))
        .then((_) {
      setState(() {
        _notificationColor = const Color(0xFFD9D9D9);
      });
    });
  }

  void navigateToSavingPlan() async {
    // Check if there is a saved plan
    var savedPlan = await loadPlanFromSecureStorage();

    // If saved plan exists, navigate to SavingPlanPage2
    if (savedPlan != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SavingPlanPage2(
            userName: widget.userName,
            phoneNumber: widget.phoneNumber,
            accounts: widget.accounts,
            resultData: savedPlan, // Pass saved plan data to the next page
          ),
        ),
      );
    } else {
      // If no saved plan exists, navigate to GoalPage to create a new plan
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SavingPlanPage(
            userName: widget.userName,
            phoneNumber: widget.phoneNumber,
            accounts: widget.accounts,
          ),
        ),
      );
    }
  }

  void _onSupportTap() {
    setState(() {
      _supportColor = Colors.grey[400]!;
    });
    Navigator.of(context)
        .push(_createNoTransitionRoute(SupportPage(
            userName: widget.userName, phoneNumber: widget.phoneNumber)))
        .then((_) {
      setState(() {
        _supportColor = const Color(0xFFD9D9D9);
      });
    });
  }

  void _onDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تأكيد حذف الحساب',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'GE-SS-Two-Bold',
            fontSize: 20,
            color: Color(0xFF3D3D3D),
          ),
        ),
        content: const Text(
          'هل أنت متأكد أنك تريد حذف الحساب؟ لن تتمكن من استعادته لاحقًا.',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'GE-SS-Two-Light',
            fontSize: 16,
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
                  Navigator.of(context).pop(); // Close the dialog
                  try {
                    final response = await http.delete(
                      Uri.parse(
                          'https://c2f7-82-167-113-9.ngrok-free.app/delete-user'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({'phoneNumber': widget.phoneNumber}),
                    );

                    if (response.statusCode == 200) {
                      // Delete local data for the user from the emulator
                      final storageService = StorageService();
                      await storageService.clearUserData(widget.phoneNumber);

                      // Navigate to main page before showing Flushbar
                      navigatorKey.currentState?.pushNamed('/');

                      // Show success message
                      Flushbar(
                        message: 'تم حذف الحساب بنجاح',
                        messageText: const Text(
                          'تم حذف الحساب بنجاح',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'GE-SS-Two-Light',
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: const Color(0xFF0FBE7C),
                        duration: const Duration(seconds: 5),
                        flushbarPosition: FlushbarPosition.TOP,
                        margin: const EdgeInsets.all(8.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ).show(navigatorKey.currentState!.overlay!.context);
                    } else {
                      // Show failure message
                      Flushbar(
                        message: 'فشل في حذف الحساب. الرجاء المحاولة لاحقًا.',
                        messageText: const Text(
                          'فشل في حذف الحساب. الرجاء المحاولة لاحقًا.',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'GE-SS-Two-Light',
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                        flushbarPosition: FlushbarPosition.TOP,
                        margin: const EdgeInsets.all(8.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ).show(navigatorKey.currentState!.overlay!.context);
                    }
                  } catch (e) {}
                },
                child: const Text(
                  'حذف الحساب',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Light',
                    fontSize: 18,
                    color: Color(0xFFDD2C35),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تأكيد تسجيل الخروج',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'GE-SS-Two-Bold',
            fontSize: 20,
            color: Color(0xFF3D3D3D),
          ),
        ),
        content: const Text(
          'هل أنت متأكد أنك تريد تسجيل الخروج؟',
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
                onPressed: () {
                  Navigator.of(context).pushNamed('/');
                  Flushbar(
                    message: 'لقد تم تسجيل خروجك بنجاح',
                    messageText: const Text(
                      'لقد تم تسجيل خروجك بنجاح',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: const Color(0xFF0FBE7C),
                    duration: const Duration(seconds: 5),
                    flushbarPosition: FlushbarPosition.TOP,
                    margin: const EdgeInsets.all(8.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ).show(context);
                },
                child: const Text(
                  'تسجيل الخروج',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Green square image
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/green_square.png',
              width: MediaQuery.of(context).size.width,
              height: 289,
              fit: BoxFit.contain,
            ),
          ),

          // Settings Title
          const Positioned(
            top: 200,
            right: 19,
            child: Text(
              'الإعدادات',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 13,
                fontFamily: 'GE-SS-Two-Light',
              ),
            ),
          ),

          // Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 77,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 11, right: 0),
                    child: buildBottomNavItem(
                      Icons.settings_outlined,
                      "إعدادات",
                      0,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          _createNoTransitionRoute(SettingsPage(
                            userName: widget.userName,
                            phoneNumber: widget.phoneNumber,
                          )),
                        );
                      },
                    ),
                  ),
                  buildBottomNavItem(Icons.credit_card, "سجل المعاملات", 1,
                      onTap: () {
                    Navigator.pushReplacement(
                      context,
                      _createNoTransitionRoute(TransactionsPage(
                        userName: widget.userName,
                        phoneNumber: widget.phoneNumber,
                        accounts: widget.accounts,
                      )),
                    );
                  }),
                  buildBottomNavItem(
                      Icons.account_balance_outlined, "الحسابات", 2,
                      isSelected: false, onTap: () {
                    Navigator.pushReplacement(
                      context,
                      _createNoTransitionRoute(BanksPage(
                        userName: widget.userName,
                        phoneNumber: widget.phoneNumber,
                        accounts: widget.accounts,
                      )),
                    );
                  }),
                  buildBottomNavItem(Icons.calendar_today, "خطة الإدخار", 3,
                      onTap: navigateToSavingPlan),
                ],
              ),
            ),
          ),

          Positioned(
            right: 350,
            top: 785,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF2C8C68), // Point color
                shape: BoxShape.circle,
              ),
            ),
          ),

          //Profile UI
          Positioned(
            top: 235,
            left: 19,
            right: 19,
            child: GestureDetector(
              onTap: _onProfileTap,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: _profileColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF3D3D3D), size: 15),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight * 0.9,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'الحساب الشخصي',
                              style: TextStyle(
                                color: Color(0xFF3D3D3D),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'GE-SS-Two-Bold',
                              ),
                            ),
                            Text(
                              'عرض المعلومات الشخصية',
                              style: TextStyle(
                                color: Color(0xFF686868),
                                fontSize: 9,
                                fontFamily: 'GE-SS-Two-Light',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Reset Password UI
          Positioned(
            top: 300,
            left: 19,
            right: 19,
            child: GestureDetector(
              onTap: _onResetPasswordTap,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: _resetPasswordColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF3D3D3D), size: 15),
                    const SizedBox(width: 10),
                    Expanded(
                      // Use Expanded to fill remaining space
                      child: Align(
                        // Align text
                        alignment: Alignment.centerRight * 0.9,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'إعادة تعيين رمز المرور',
                              style: TextStyle(
                                color: Color(0xFF3D3D3D),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'GE-SS-Two-Bold',
                              ),
                            ),
                            Text(
                              'تعديل رمز المرور الخاص بك',
                              style: TextStyle(
                                color: Color(0xFF686868),
                                fontSize: 9,
                                fontFamily: 'GE-SS-Two-Light',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

// Manage Notifications UI
          Positioned(
            top: 365,
            left: 19,
            right: 19,
            child: GestureDetector(
              onTap: _onNotificationTap,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: _notificationColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF3D3D3D), size: 15),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight * 0.9,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'إدارة الإشعارات',
                              style: TextStyle(
                                color: Color(0xFF3D3D3D),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'GE-SS-Two-Bold',
                              ),
                            ),
                            Text(
                              'تفعيل الإشعارات وضبطها',
                              style: TextStyle(
                                color: Color(0xFF686868),
                                fontSize: 9,
                                fontFamily: 'GE-SS-Two-Light',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Red Dot Indicator
                    if (hasNewNotifications)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Stack(
                          children: [
                            const Icon(Icons.notifications),
                            // Show red dot if new notifications are available
                            if (hasNewNotifications)
                              Positioned(
                                right: 10,
                                top: 10,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          //Contact Support UI
          Positioned(
            top: 430,
            left: 19,
            right: 19,
            child: GestureDetector(
              onTap: _onSupportTap,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: _supportColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF3D3D3D), size: 15),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight * 0.9,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'التواصل مع الدعم',
                              style: TextStyle(
                                color: Color(0xFF3D3D3D),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'GE-SS-Two-Bold',
                              ),
                            ),
                            Text(
                              'وسيلة التواصل مع الدعم',
                              style: TextStyle(
                                color: Color(0xFF686868),
                                fontSize: 9,
                                fontFamily: 'GE-SS-Two-Light',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Logout button
          Positioned(
            bottom: 205,
            left: (MediaQuery.of(context).size.width - 194) / 2,
            child: SizedBox(
              width: 194,
              height: 39,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D3D3D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  shadowColor: Colors.black,
                  elevation: 5,
                ),
                onPressed: _onLogout,
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'GE-SS-Two-Light',
                  ),
                ),
              ),
            ),
          ),

// Delete Account button
          Positioned(
            bottom: 150,
            left: (MediaQuery.of(context).size.width - 194) / 2,
            child: SizedBox(
              width: 194,
              height: 39,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9F9F9),
                  foregroundColor: const Color(0xFFDD2C35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: const BorderSide(color: Color(0xFFDD2C35), width: 1),
                  ),
                ),
                onPressed: _onDeleteAccount, // Call the delete account function
                child: const Text(
                  'حذف الحساب',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'GE-SS-Two-Light',
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 44,
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 92,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2C8C68), Color(0xFF8FD9BD)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 44,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        _createNoTransitionRoute(HomePage(
                            userName: widget.userName,
                            phoneNumber: widget.phoneNumber,
                            accounts: widget.accounts)), // Pass userName
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Navigation
  Widget buildBottomNavItem(IconData icon, String label, int index,
      {bool isSelected = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFF2C8C68),
            size: 30,
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2C8C68),
              fontSize: 12,
              fontFamily: 'GE-SS-Two-Light',
            ),
          ),
        ],
      ),
    );
  }
}
