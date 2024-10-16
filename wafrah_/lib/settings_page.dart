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
  final String firstName;
  final String userID;

  SettingsPage({required this.firstName, required this.userID});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Color _profileColor = Color(0xFFD9D9D9);
  Color _resetPasswordColor = Color(0xFFD9D9D9);
  Color _notificationColor = Color(0xFFD9D9D9);
  Color _supportColor = Color(0xFFD9D9D9);

  // Custom page transition for no transition effect
  Route _createNoTransitionRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration(seconds: 0), // No transition
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
        .push(_createNoTransitionRoute(ProfilePage(firstName: widget.firstName, userID: widget.userID)))
        .then((_) {
      setState(() {
        _profileColor = Color(0xFFD9D9D9); // Reset color after navigating back
      });
    });
  }

  void _onResetPasswordTap() {
    setState(() {
      _resetPasswordColor = Colors.grey[400]!; // Darker color on press
    });
    Navigator.of(context)
        .push(_createNoTransitionRoute(ResetPasswordPage(firstName: widget.firstName, userID: widget.userID)))
        .then((_) {
      setState(() {
        _resetPasswordColor = Color(0xFFD9D9D9); // Reset color after navigating back
      });
    });
  }

  void _onNotificationTap() {
    setState(() {
      _notificationColor = Colors.grey[400]!; // Darker color on press
    });
    Navigator.of(context)
        .push(_createNoTransitionRoute(NotificationPage(firstName: widget.firstName, userID: widget.userID)))
        .then((_) {
      setState(() {
        _notificationColor = Color(0xFFD9D9D9); // Reset color after navigating back
      });
    });
  }

  void _onSupportTap() {
    setState(() {
      _supportColor = Colors.grey[400]!; // Darker color on press
    });
    Navigator.of(context)
        .push(_createNoTransitionRoute(SupportPage(firstName: widget.firstName, userID: widget.userID)))
        .then((_) {
      setState(() {
        _supportColor = Color(0xFFD9D9D9); // Reset color after navigating back
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
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
          Positioned(
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
                    SizedBox(width: 10), // Move arrow to the right
                    Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF3D3D3D), size: 15), // Smaller arrow
                    SizedBox(width: 10),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
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
                    SizedBox(width: 10), // Move arrow to the right
                    Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF3D3D3D), size: 15), // Smaller arrow
                    SizedBox(width: 10),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
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
                    SizedBox(width: 10), // Move arrow to the right
                    Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF3D3D3D), size: 15), // Smaller arrow
                    SizedBox(width: 10),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
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
                    SizedBox(width: 10), // Move arrow to the right
                    Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF3D3D3D), size: 15), // Smaller arrow
                    SizedBox(width: 10),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
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
            bottom: 205, // Adjust position as needed
            left: (MediaQuery.of(context).size.width - 194) / 2,
            child: SizedBox(
              width: 194,
              height: 39,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3D3D3D), // Background color
                  foregroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100), // Rounded corners
                  ),
                  shadowColor: Colors.black, // Shadow color
                  elevation: 5, // Shadow elevation
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/'); // Navigate to main.dart
                },
                child: Text(
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
            bottom: 150, // Adjust position as needed
            left: (MediaQuery.of(context).size.width - 194) / 2,
            child: SizedBox(
              width: 194,
              height: 39,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF9F9F9),
                  border: Border.all(color: Color(0xFFDD2C35), width: 1),
                  borderRadius: BorderRadius.circular(100), // Rounded corners
                ),
                child: TextButton(
                  onPressed: () {
                    // Add your deletion logic here
                  },
                  child: Text(
                    'حذف الحساب',
                    style: TextStyle(
                      color: Color(0xFFDD2C35),
                      fontSize: 15,
                      fontFamily: 'GE-SS-Two-Light',
                    ),
                  ),
                ),
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
                    offset: Offset(0, -5),
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
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SettingsPage(firstName: widget.firstName, userID: widget.userID),
                        transitionDuration: Duration(seconds: 0),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                      ),
                    );
                  }),
                  buildBottomNavItem(Icons.credit_card, "سجل المعاملات", 1,
                      onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            TransactionsPage(firstName: widget.firstName, userID: widget.userID),
                        transitionDuration: Duration(seconds: 0),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                      ),
                    );
                  }),
                  buildBottomNavItem(Icons.home_outlined, "الرئيسية", 2,
                      onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            HomePage(firstName: widget.firstName, userID: widget.userID),
                        transitionDuration: Duration(seconds: 0),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                      ),
                    );
                  }),
                  buildBottomNavItem(Icons.calendar_today, "خطة الإدخار", 3,
                      onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SavingPlanPage(firstName: widget.firstName, userID: widget.userID),
                        transitionDuration: Duration(seconds: 0),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                      ),
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
              decoration: BoxDecoration(
                color: Color(0xFF2C8C68),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Item
  Widget buildBottomNavItem(IconData icon, String label, int index,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Color(0xFF2C8C68),
            size: 30,
          ),
          Text(
            label,
            style: TextStyle(
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
