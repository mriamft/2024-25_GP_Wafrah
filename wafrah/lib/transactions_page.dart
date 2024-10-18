import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'banks_page.dart';
import 'saving_plan_page.dart';
import 'home_page.dart';

class TransactionsPage extends StatelessWidget {
  final String userName; // Pass userName from previous pages
  final String phoneNumber;
  TransactionsPage({required this.userName, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9), // Background color
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
                  SizedBox(width: 3), // Spacing
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
                  SizedBox(width: 40), // Spacing
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
                  SizedBox(width: 3), // Spacing
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
                  SizedBox(width: 40), // Spacing
                ],
              ),
            ),
          ),

          // First Alrajhi Image
          Positioned(
            left: 315,
            top: 265,
            child: Image.asset(
              'assets/images/Alrajhi.png',
              width: 30,
              height: 30,
            ),
          ),

          // Second Alrajhi Image
          Positioned(
            left: 315,
            top: 326,
            child: Image.asset(
              'assets/images/Alrajhi.png',
              width: 30,
              height: 30,
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
                  buildBottomNavItem(Icons.settings_outlined, "إعدادات", 0, onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage(userName: userName, phoneNumber:phoneNumber)),
                    );
                  }),
                  buildBottomNavItem(Icons.credit_card, "سجل المعاملات", 1, onTap: () {
                    // Already on Transactions page
                  }),
                  buildBottomNavItem(Icons.home_outlined, "الرئيسية", 2, onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage(userName: userName, phoneNumber:phoneNumber)),
                    );
                  }),
                  buildBottomNavItem(Icons.calendar_today, "خطة الإدخار", 3, onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SavingPlanPage(userName: userName, phoneNumber:phoneNumber)),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Circular Button for Banks Page
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
                  decoration: BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2C8C68), Color(0xFF8FD9BD)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => BanksPage(userName: userName, phoneNumber:phoneNumber)),
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

  Widget buildBottomNavItem(IconData icon, String label, int index, {required VoidCallback onTap}) {
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
