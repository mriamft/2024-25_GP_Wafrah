import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'banks_page.dart';
import 'saving_plan_page.dart';
import 'home_page.dart';

class TransactionsPage extends StatelessWidget {
  final String firstName;
  final String userID;

  TransactionsPage({required this.firstName, required this.userID});

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

          // Title
          Positioned(
            top: 185,
            right: 12,
            child: Text(
              'العمليات منذ السبت 1 محرم 1445',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),

          // Date Text
          Positioned(
            top: 234,
            right: 12,
            child: Text(
              'الجمعة 13 شوال 1445',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 13,
                fontFamily: 'GE-SS-Two-Light',
              ),
            ),
          ),

          // First Transaction Bar
          Positioned(
            top: 255,
            right: 10,
            child: Container(
              width: 338,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(width: 4),
                  Text(
                    'ر.س',
                    style: TextStyle(
                      color: Color(0xFF5F5F5F),
                      fontSize: 13,
                      fontFamily: 'GE-SS-Two-Light',
                    ),
                  ),
                  SizedBox(width: 3),
                  Text(
                    '25,000',
                    style: TextStyle(
                      color: Color(0xFF2C8C68),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'GE-SS-Two-Bold',
                    ),
                  ),
                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'الشركة السعودية للكهرباء',
                        style: TextStyle(
                          color: Color(0xFF3D3D3D),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'GE-SS-Two-Bold',
                        ),
                      ),
                      Text(
                        'راتب',
                        style: TextStyle(
                          color: Color(0xFF5F5F5F),
                          fontSize: 13,
                          fontFamily: 'GE-SS-Two-Light',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ),
          ),

          // Second Transaction Bar
          Positioned(
            top: 316,
            right: 10,
            child: Container(
              width: 338,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(width: 4),
                  Text(
                    'ر.س',
                    style: TextStyle(
                      color: Color(0xFF5F5F5F),
                      fontSize: 13,
                      fontFamily: 'GE-SS-Two-Light',
                    ),
                  ),
                  SizedBox(width: 3),
                  Text(
                    '31',
                    style: TextStyle(
                      color: Color(0xFF3D3D3D),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'GE-SS-Two-Bold',
                    ),
                  ),
                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ماكدونالدز',
                        style: TextStyle(
                          color: Color(0xFF3D3D3D),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'GE-SS-Two-Bold',
                        ),
                      ),
                      Text(
                        'الأكل',
                        style: TextStyle(
                          color: Color(0xFF5F5F5F),
                          fontSize: 13,
                          fontFamily: 'GE-SS-Two-Light',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 40),
                ],
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
                            SettingsPage(firstName: firstName, userID: userID),
                        transitionDuration: Duration(seconds: 0),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                      ),
                    );
                  }),
                  buildBottomNavItem(Icons.credit_card, "سجل المعاملات", 1, onTap: () {}),
                  buildBottomNavItem(Icons.home_outlined, "الرئيسية", 2,
                      onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            HomePage(firstName: firstName, userID: userID),
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
                            SavingPlanPage(firstName: firstName, userID: userID),
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
