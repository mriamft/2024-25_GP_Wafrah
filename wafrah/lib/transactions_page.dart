import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'banks_page.dart';
import 'saving_plan_page.dart';
import 'home_page.dart';

class TransactionsPage extends StatelessWidget {
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
                fontFamily: 'GE-SS-Two-Bold', // Ensure same font as the project
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
                fontFamily:
                    'GE-SS-Two-Light', // Ensure same font as the project
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
                      fontFamily:
                          'GE-SS-Two-Light', // Ensure same font as the project
                    ),
                  ),
                  SizedBox(width: 3), // Spacing
                  Text(
                    '25,000',
                    style: TextStyle(
                      color: Color(0xFF2C8C68),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily:
                          'GE-SS-Two-Bold', // Ensure same font as the project
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
                          fontFamily:
                              'GE-SS-Two-Bold', // Ensure same font as the project
                        ),
                      ),
                      Text(
                        'راتب',
                        style: TextStyle(
                          color: Color(0xFF5F5F5F),
                          fontSize: 13,
                          fontFamily:
                              'GE-SS-Two-Light', // Ensure same font as the project
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
                      fontFamily:
                          'GE-SS-Two-Light', // Ensure same font as the project
                    ),
                  ),
                  SizedBox(width: 3), // Spacing
                  Text(
                    '31',
                    style: TextStyle(
                      color: Color(0xFF3D3D3D),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily:
                          'GE-SS-Two-Bold', // Ensure same font as the project
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
                          fontFamily:
                              'GE-SS-Two-Bold', // Ensure same font as the project
                        ),
                      ),
                      Text(
                        'الأكل',
                        style: TextStyle(
                          color: Color(0xFF5F5F5F),
                          fontSize: 13,
                          fontFamily:
                              'GE-SS-Two-Light', // Ensure same font as the project
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
              'assets/images/Alrajhi.png', // Ensure this is the correct image path
              width: 30,
              height: 30,
            ),
          ),

          // Second Alrajhi Image
          Positioned(
            left: 315,
            top: 326,
            child: Image.asset(
              'assets/images/Alrajhi.png', // Ensure this is the correct image path
              width: 30,
              height: 30,
            ),
          ),

          // Point under "سجل المعاملات"
          Positioned(
            right: 109, // Position x
            top: 700, // Position y
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Color(0xFF2C8C68), // Point color
                shape: BoxShape.circle,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  }),
                  buildBottomNavItem(Icons.credit_card, "سجل المعاملات", 1,
                      onTap: () {
                    // Removed navigation logic here
                  }),
                  buildBottomNavItem(Icons.home_outlined, "الرئيسية", 2,
                      isSelected: false, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  }),
                  buildBottomNavItem(Icons.calendar_today, "خطة الإدخار", 3,
                      onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SavingPlanPage()),
                    );
                  }),
                ],
              ),
            ),
          ),
          Positioned(
            right: 226, // Position x
            top: 762, // Position y
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Color(0xFF2C8C68), // Point color
                shape: BoxShape.circle,
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
                  decoration: BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    shape: BoxShape.circle,
                  ),
                ),
                // Gradient green circle
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
                      // Navigate to Banks Page without transition
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => BanksPage()),
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