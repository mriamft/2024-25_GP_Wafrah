import 'package:flutter/material.dart';
import 'home_page.dart'; // Import your home page
import 'acc_link_page.dart'; // Import the account link page
import 'settings_page.dart'; // Import the settings page
import 'transactions_page.dart'; // Import the transactions page
import 'saving_plan_page.dart'; // Import the saving plan page

class BanksPage extends StatelessWidget {
  final String userName; // Pass userName from previous pages
  final String phoneNumber;

  const BanksPage(
      {super.key, required this.userName, required this.phoneNumber});

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
            top: 202,
            left: 210,
            child: Text(
              'الحسابات البنكية',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold', // Ensure same font as the project
              ),
            ),
          ),

          // Plus Icon for adding bank account
          Positioned(
            top: 200,
            left: 26,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AccLinkPage()), // Navigate to account link page
                );
              },
              child: Icon(
                Icons.add,
                color: Color(0xFF313131),
                size: 30,
              ),
            ),
          ),

          // Bar for the first bank account
          Positioned(
            top: 258,
            left: 12,
            child: Container(
              width: 340,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // Align to the right
                children: [
                  Container(
                    width: 65,
                    height: 17,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      border: Border.all(color: Color(0xFFDD2C35), width: 1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        'إزالة الربط',
                        style: TextStyle(
                          color: Color(0xFF313131),
                          fontSize: 8,
                          fontFamily:
                              'GE-SS-Two-Light', // Ensure same font as the project
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 46), // Space between elements
                  Text(
                    'ر.س',
                    style: TextStyle(
                      color: Color(0xFF5F5F5F),
                      fontSize: 13,
                      fontFamily:
                          'GE-SS-Two-Light', // Ensure same font as the project
                    ),
                  ),
                  SizedBox(width: 3), // Adjusted space
                  Text(
                    '60,000',
                    style: TextStyle(
                      color: Color(0xFF313131),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily:
                          'GE-SS-Two-Bold', // Ensure same font as the project
                    ),
                  ),
                  SizedBox(width: 40), // Space between elements
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(right: 40), // Right padding
                        child: Text(
                          'بزنس',
                          style: TextStyle(
                            color: Color(0xFF3D3D3D),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily:
                                'GE-SS-Two-Bold', // Ensure same font as the project
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(right: 40), // Right padding
                        child: Text(
                          'رقم الايبان',
                          style: TextStyle(
                            color: Color(0xFF5F5F5F),
                            fontSize: 13,
                            fontFamily:
                                'GE-SS-Two-Light', // Ensure same font as the project
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bar for the second bank account
          Positioned(
            top: 331,
            left: 12,
            child: Container(
              width: 340,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // Align to the right
                children: [
                  Container(
                    width: 65,
                    height: 17,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      border: Border.all(color: Color(0xFFDD2C35), width: 1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        'إزالة الربط',
                        style: TextStyle(
                          color: Color(0xFF313131),
                          fontSize: 8,
                          fontFamily:
                              'GE-SS-Two-Light', // Ensure same font as the project
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 42), // Space between elements
                  Text(
                    'ر.س',
                    style: TextStyle(
                      color: Color(0xFF5F5F5F),
                      fontSize: 13,
                      fontFamily:
                          'GE-SS-Two-Light', // Ensure same font as the project
                    ),
                  ),
                  SizedBox(width: 3), // Adjusted space
                  Text(
                    '30,000',
                    style: TextStyle(
                      color: Color(0xFF313131),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily:
                          'GE-SS-Two-Bold', // Ensure same font as the project
                    ),
                  ),
                  SizedBox(width: 40), // Space between elements
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(right: 40), // Right padding
                        child: Text(
                          'فورين',
                          style: TextStyle(
                            color: Color(0xFF3D3D3D),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily:
                                'GE-SS-Two-Bold', // Ensure same font as the project
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(right: 40), // Right padding
                        child: Text(
                          'رقم الايبان',
                          style: TextStyle(
                            color: Color(0xFF5F5F5F),
                            fontSize: 13,
                            fontFamily:
                                'GE-SS-Two-Light', // Ensure same font as the project
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // First SAAMA Image
          Positioned(
            left: 317,
            top: 269,
            child: Image.asset(
              'assets/images/SAMA_logo.png', // Ensure this is the correct image path
              width: 30,
              height: 30,
            ),
          ),

          // Second SAMA Image
          Positioned(
            left: 317,
            top: 341,
            child: Image.asset(
              'assets/images/SAMA_logo.png', // Ensure this is the correct image path
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
                  buildBottomNavItem(Icons.settings_outlined, "إعدادات", () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SettingsPage(
                                userName: userName, phoneNumber: userName),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }),
                  buildBottomNavItem(Icons.credit_card, "سجل المعاملات", () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            TransactionsPage(
                                userName: userName, phoneNumber: userName),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }),
                  buildBottomNavItem(Icons.home_outlined, "الرئيسية", () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            HomePage(userName: userName, phoneNumber: userName),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }),
                  buildBottomNavItem(Icons.calendar_today, "خطة الإدخار", () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SavingPlanPage(
                                userName: userName, phoneNumber: userName),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Circular Button above the Navigation Bar
          Positioned(
            bottom: 44,
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
                      // No navigation needed here since we are already on BanksPage
                    },
                  ),
                ),
              ],
            ),
          ),

          // Point under the gradient circle
          Positioned(
            left: 180,
            top: 740,
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
  Widget buildBottomNavItem(IconData icon, String label, VoidCallback onTap) {
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
