import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'transactions_page.dart';
import 'home_page.dart';
import 'banks_page.dart';

class SavingPlanPage2 extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final List<Map<String, dynamic>> accounts;

  const SavingPlanPage2({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [],
  });

  @override
  _SavingPlanPage2State createState() => _SavingPlanPage2State();
}

class _SavingPlanPage2State extends State<SavingPlanPage2> {
  int _currentMonthIndex = 0; // Track the selected month
  int _startIndex = 0; // Track the first visible month index

  List<String> months = [
    'الشهر الأول',
    'الشهر الثاني',
    'الشهر الثالث',
    'الشهر الرابع',
    'الشهر الخامس',
    'الشهر السادس'
  ];

  // Define categories and their corresponding icons
  final List<Map<String, dynamic>> categories = [
    {'label': 'المطاعم', 'icon': Icons.restaurant},
    {'label': 'التعليم', 'icon': Icons.school},
    {'label': 'الصحة', 'icon': Icons.local_hospital},
    {'label': 'تسوق', 'icon': Icons.shopping_bag},
    {'label': 'البقالة', 'icon': Icons.local_grocery_store},
    {'label': 'النقل', 'icon': Icons.directions_bus},
    {'label': 'السفر', 'icon': Icons.flight},
    {'label': 'المدفوعات الحكومية', 'icon': Icons.account_balance},
    {'label': 'الترفيه', 'icon': Icons.gamepad_rounded},
    {'label': 'الاستثمار', 'icon': Icons.trending_up},
    {'label': 'الإيجار', 'icon': Icons.home},
    {'label': 'القروض', 'icon': Icons.money},
    {'label': 'الراتب', 'icon': Icons.account_balance_wallet},
    {'label': 'التحويلات', 'icon': Icons.swap_horiz},
  ];

  final List<double> percentages = List.generate(
      14, (index) => (index + 1) * 5.0); // Dummy percentages for demonstration

  void _onArrowTap(bool isLeftArrow) {
    setState(() {
      if (isLeftArrow) {
        _startIndex = (_startIndex + 1).clamp(0, months.length - 2);
      } else {
        _startIndex = (_startIndex - 1).clamp(0, months.length - 2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> visibleMonths = months.sublist(_startIndex, _startIndex + 2);
    bool isLeftArrowEnabled = _startIndex < months.length - 2;
    bool isRightArrowEnabled = _startIndex > 0;

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
            top: 197,
            left: 280,
            child: Text(
              'خطة الإدخار',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),
          Positioned(
            top: 240,
            left: 4,
            child: Container(
              width: 380,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed:
                        isLeftArrowEnabled ? () => _onArrowTap(true) : null,
                    color: isLeftArrowEnabled
                        ? const Color(0xFF777777)
                        : const Color(0xFFCBCBCB),
                    iconSize: 20,
                  ),
                  ...List.generate(visibleMonths.length, (index) {
                    int monthIndex =
                        _startIndex + (visibleMonths.length - 1 - index);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentMonthIndex = monthIndex;
                        });
                      },
                      child: Container(
                        width: 134,
                        height: 38,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: monthIndex == _currentMonthIndex
                                ? const Color(0xFF379874)
                                : const Color(0xFFB9B6B6),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          color: monthIndex == _currentMonthIndex
                              ? const Color(0xFF379874)
                              : const Color(0xFFD9D9D9),
                        ),
                        child: Center(
                          child: Text(
                            visibleMonths[visibleMonths.length - 1 - index],
                            style: TextStyle(
                              color: monthIndex == _currentMonthIndex
                                  ? Colors.white
                                  : const Color(0xFF3D3D3D),
                              fontWeight: monthIndex == _currentMonthIndex
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontFamily: 'GE-SS-Two-Light',
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed:
                        isRightArrowEnabled ? () => _onArrowTap(false) : null,
                    color: isRightArrowEnabled
                        ? const Color(0xFF777777)
                        : const Color(0xFFCBCBCB),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 195,
            left: 19,
            child: GestureDetector(
              onTap: () {
                // Handle trash icon tap if necessary
              },
              child: const Icon(
                Icons.delete_outline_outlined,
                color: Color.fromARGB(255, 239, 44, 54),
                size: 28,
              ),
            ),
          ),
          // Fixed height container for the scrollable squares
          // Fixed height container for the scrollable squares
// Fixed height container for the scrollable squares
          // Fixed height container for the scrollable squares
          Positioned(
            top: 300,
            left: 10,
            right: 10,
            child: Container(
              height: 365, // Set a larger height for the scrollable area
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20), // Add vertical padding
                  child: Center(
                    // Center the content within the scrollable area
                    child: Wrap(
                      spacing: 20, // Space between squares
                      runSpacing: 50, // Space between rows
                      children: List.generate(categories.length, (index) {
                        return Container(
                          width: (MediaQuery.of(context).size.width / 2) -
                              30, // Half the width minus spacing
                          child: buildCategorySquare(
                              categories[index], percentages[index]),
                        );
                      }),
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
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber,
                          accounts: widget.accounts,
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
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber,
                          accounts: widget.accounts,
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
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber,
                          accounts: widget.accounts,
                        ),
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, right: 0),
                    child: buildBottomNavItem(
                        Icons.calendar_today, "خطة الإدخار", 3,
                        onTap: () {}),
                  ),
                ],
              ),
            ),
          ),
          // Home Button with gradient circle
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
                              userName: widget.userName,
                              phoneNumber: widget.phoneNumber,
                              accounts: widget.accounts),
                        ),
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

  Widget buildCategorySquare(Map<String, dynamic> category, double percentage) {
    Color loadingColor;
    if (percentage <= 25) {
      loadingColor = Colors.red;
    } else if (percentage <= 75) {
      loadingColor = Colors.lightGreen;
    } else {
      loadingColor = const Color(0xFF379874);
    }

    return Container(
      width: 101,
      height: 101,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: Text(
              "مجموع الحفظ",
              style: TextStyle(color: const Color(0xFF5F5F5F), fontSize: 10),
            ),
          ),
          Positioned(
            top: 5,
            left: 5,
            child: Text(
              "تم حفظ",
              style: TextStyle(color: const Color(0xFF5F5F5F), fontSize: 10),
            ),
          ),
          Positioned(
            top: 3,
            left: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 3,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
                  ),
                ),
                Icon(
                  category['icon'],
                  color: const Color(0xFF2C8C68),
                  size: 18,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                category['label'],
                style: TextStyle(color: const Color(0xFF379874), fontSize: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
