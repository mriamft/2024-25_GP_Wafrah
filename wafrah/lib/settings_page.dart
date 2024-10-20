import 'package:flutter/material.dart';
import 'saving_plan_page.dart';
import 'transactions_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'reset_password_page.dart';
import 'notification_page.dart';
import 'support_page.dart';
import 'banks_page.dart';

class SettingsPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;

  const SettingsPage(
      {super.key, required this.userName, required this.phoneNumber});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Color _profileColor = const Color(0xFFD9D9D9);
  Color _resetPasswordColor = const Color(0xFFD9D9D9);
  Color _notificationColor = const Color(0xFFD9D9D9);
  Color _supportColor = const Color(0xFFD9D9D9);

  // Custom page transition for no transition effect
  Route _createNoTransitionRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(seconds: 0), // No transition
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child; // No animation
      },
    );
  }

  void _onProfileTap() {
    setState(() {
      _profileColor = Colors.grey[400]!; // Darker color on press
    });
    Navigator.of(context)
        .push(_createNoTransitionRoute(ProfilePage(
            userName: widget.userName, phoneNumber: widget.phoneNumber)))
        .then((_) {
      setState(() {
        _profileColor =
            const Color(0xFFD9D9D9); // Reset color after navigating back
      });
    });
  }

  void _onResetPasswordTap() {
    setState(() {
      _resetPasswordColor = Colors.grey[400]!; // Darker color on press
    });
    Navigator.of(context)
        .push(_createNoTransitionRoute(ResetPasswordPage(
            userName: widget.userName,
            phoneNumber: widget.phoneNumber))) // Pass user phone number
        .then((_) {
      setState(() {
        _resetPasswordColor =
            const Color(0xFFD9D9D9); // Reset color after navigating back
      });
    });
  }

  void _onNotificationTap() {
    setState(() {
      _notificationColor = Colors.grey[400]!; // Darker color on press
    });
    Navigator.of(context)
        .push(_createNoTransitionRoute(NotificationPage(
            userName: widget.userName, phoneNumber: widget.phoneNumber)))
        .then((_) {
      setState(() {
        _notificationColor =
            const Color(0xFFD9D9D9); // Reset color after navigating back
      });
    });
  }

  void _onSupportTap() {
    setState(() {
      _supportColor = Colors.grey[400]!; // Darker color on press
    });
    Navigator.of(context)
        .push(_createNoTransitionRoute(SupportPage(
            userName: widget.userName, phoneNumber: widget.phoneNumber)))
        .then((_) {
      setState(() {
        _supportColor =
            const Color(0xFFD9D9D9); // Reset color after navigating back
      });
    });
  }

  void _onLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/'); // Navigate to main.dart
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('تم تسجيل الخروج بنجاح'), // Successfully logged out
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('تسجيل الخروج'),
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
              'إعدادات الحساب',
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
                  buildBottomNavItem(Icons.settings_outlined, "إعدادات", 0,
                      onTap: () {
                    Navigator.pushReplacement(
                      context,
                      _createNoTransitionRoute(SettingsPage(
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber)), // Pass userName
                    );
                  }),
                  buildBottomNavItem(Icons.credit_card, "سجل المعاملات", 1,
                      onTap: () {
                    Navigator.pushReplacement(
                      context,
                      _createNoTransitionRoute(TransactionsPage(
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber)), // Pass userName
                    );
                  }),
                  buildBottomNavItem(Icons.home_outlined, "الرئيسية", 2,
                      isSelected: false, onTap: () {
                    Navigator.pushReplacement(
                      context,
                      _createNoTransitionRoute(HomePage(
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber)), // Pass userName
                    );
                  }),
                  buildBottomNavItem(Icons.calendar_today, "خطة الإدخار", 3,
                      onTap: () {
                    Navigator.pushReplacement(
                      context,
                      _createNoTransitionRoute(SavingPlanPage(
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber)), // Pass userName
                    );
                  }),
                ],
              ),
            ),
          ),

          // Point under "إعدادات"
          Positioned(
            right: 320,
            top: 762,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF2C8C68), // Point color
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Setting Item 1: Profile
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
                    const SizedBox(width: 10), // Move arrow to the right
                    const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF3D3D3D), size: 15), // Smaller arrow
                    const SizedBox(width: 10),
                    Expanded(
                      // Use Expanded to fill remaining space
                      child: Align(
                        // Align text
                        alignment: Alignment.centerRight * 0.9,
                        child: const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end, // Right align texts
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'الحساب الشخصي',
                              style: TextStyle(
                                color: Color(0xFF3D3D3D),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily:
                                    'GE-SS-Two-Bold', // Use the same font as the project
                              ),
                            ),
                            Text(
                              'عرض المعلومات الشخصية',
                              style: TextStyle(
                                color: Color(0xFF686868),
                                fontSize: 9,
                                fontFamily:
                                    'GE-SS-Two-Light', // Use the same font as the project
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

          // Setting Item 2: Reset Password
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
                    const SizedBox(width: 10), // Move arrow to the right
                    const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF3D3D3D), size: 15), // Smaller arrow
                    const SizedBox(width: 10),
                    Expanded(
                      // Use Expanded to fill remaining space
                      child: Align(
                        // Align text
                        alignment: Alignment.centerRight * 0.9,
                        child: const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end, // Right align texts
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'إعادة تعيين رمز المرور',
                              style: TextStyle(
                                color: Color(0xFF3D3D3D),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily:
                                    'GE-SS-Two-Bold', // Use the same font as the project
                              ),
                            ),
                            Text(
                              'تعديل رمز المرور الخاص بك',
                              style: TextStyle(
                                color: Color(0xFF686868),
                                fontSize: 9,
                                fontFamily:
                                    'GE-SS-Two-Light', // Use the same font as the project
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

          // Setting Item 3: Manage Notifications
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
                    const SizedBox(width: 10), // Move arrow to the right
                    const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF3D3D3D), size: 15), // Smaller arrow
                    const SizedBox(width: 10),
                    Expanded(
                      // Use Expanded to fill remaining space
                      child: Align(
                        // Align text
                        alignment: Alignment.centerRight * 0.9,
                        child: const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end, // Right align texts
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'إدارة الإشعارات',
                              style: TextStyle(
                                color: Color(0xFF3D3D3D),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily:
                                    'GE-SS-Two-Bold', // Use the same font as the project
                              ),
                            ),
                            Text(
                              'تفعيل الإشعارات وضبطها',
                              style: TextStyle(
                                color: Color(0xFF686868),
                                fontSize: 9,
                                fontFamily:
                                    'GE-SS-Two-Light', // Use the same font as the project
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

          // Setting Item 4: Contact Support
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
                    const SizedBox(width: 10), // Move arrow to the right
                    const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF3D3D3D), size: 15), // Smaller arrow
                    const SizedBox(width: 10),
                    Expanded(
                      // Use Expanded to fill remaining space
                      child: Align(
                        // Align text
                        alignment: Alignment.centerRight * 0.9,
                        child: const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end, // Right align texts
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'التواصل مع الدعم',
                              style: TextStyle(
                                color: Color(0xFF3D3D3D),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily:
                                    'GE-SS-Two-Bold', // Use the same font as the project
                              ),
                            ),
                            Text(
                              'وسيلة التواصل مع الدعم',
                              style: TextStyle(
                                color: Color(0xFF686868),
                                fontSize: 9,
                                fontFamily:
                                    'GE-SS-Two-Light', // Use the same font as the project
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
            bottom: 205, // Adjust position as needed
            left: (MediaQuery.of(context).size.width - 194) / 2,
            child: SizedBox(
              width: 194,
              height: 39,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D3D3D), // Background color
                  foregroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100), // Rounded corners
                  ),
                  shadowColor: Colors.black, // Shadow color
                  elevation: 5, // Shadow elevation
                ),
                onPressed: _onLogout, // Call logout method
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily:
                        'GE-SS-Two-Light', // Use the same font as the project
                  ),
                ),
              ),
            ),
          ),

          // Delete Account button
          Positioned(
            bottom: 150, // Adjust position as needed
            left: (MediaQuery.of(context).size.width - 194) / 2,
            child: SizedBox(
              width: 194,
              height: 39,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  border: Border.all(color: const Color(0xFFDD2C35), width: 1),
                  borderRadius: BorderRadius.circular(100), // Rounded corners
                ),
                child: TextButton(
                  onPressed: () {
                    // Add your deletion logic here
                  },
                  child: const Text(
                    'حذف الحساب',
                    style: TextStyle(
                      color: Color(0xFFDD2C35),
                      fontSize: 15,
                      fontFamily:
                          'GE-SS-Two-Light', // Use the same font as the project
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Circular Button above the Navigation Bar (F9F9F9 circle + gradient green circle)
          Positioned(
            bottom: 44, // Adjusted position
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // #F9F9F9 circle without shadow
                Container(
                  width: 92,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    shape: BoxShape.circle,
                  ),
                ),
                // Gradient green circle
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
                      Icons.account_balance,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {
                      // Navigate to Banks Page without transition and pass userName
                      Navigator.pushReplacement(
                        context,
                        _createNoTransitionRoute(BanksPage(
                            userName: widget.userName,
                            phoneNumber: widget.phoneNumber)), // Pass userName
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

  // Bottom Navigation Item
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
