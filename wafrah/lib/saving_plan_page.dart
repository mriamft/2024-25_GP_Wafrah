import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'transactions_page.dart';
import 'home_page.dart';
import 'banks_page.dart';

class SavingPlanPage extends StatelessWidget {
  final String userName;
  final String phoneNumber;
  final List<Map<String, dynamic>> accounts; 

  const SavingPlanPage({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [], 
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
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
          const Positioned(
            top: 380,
            left: 19,
            right: 19,
            child: Center(
              child: Text(
                'هذه الخاصية سوف تتوفر قريبًا \n Next Sprint',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF838383),
                  fontSize: 20,
                  fontFamily: 'GE-SS-Two-Bold',
                ),
              ),
            ),
          ),
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
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(
                          userName: userName,
                          phoneNumber: phoneNumber,
                          accounts: accounts,
                        ),
                      ),
                    );
                  }),
                  buildBottomNavItem(Icons.credit_card, "سجل المعاملات", 1,
                      onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionsPage(
                          userName: userName,
                          phoneNumber: phoneNumber,
                          accounts: accounts,
                        ),
                      ),
                    );
                  }),
                  buildBottomNavItem(
                      Icons.account_balance_outlined, "الحسابات", 2, onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BanksPage(
                          userName: userName,
                          phoneNumber: phoneNumber,
                          accounts: accounts,
                        ),
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, right: 0), 
                    child: buildBottomNavItem(
                        Icons.calendar_today, "خطة الإدخار", 3, onTap: () {
                    }),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 339,
            top: 785,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF2C8C68), 
                shape: BoxShape.circle,
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
                        MaterialPageRoute(
                            builder: (context) => HomePage(
                                userName: userName,
                                phoneNumber: phoneNumber,
                                accounts: accounts)), 
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

// Method to build the bottom navigation bar
  Widget buildBottomNavItem(IconData icon, String label, int index,
      {required VoidCallback onTap}) {
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