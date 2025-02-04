import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'transactions_page.dart';
import 'home_page.dart';
import 'banks_page.dart';

class SavingPlanPage2 extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final List<Map<String, dynamic>> accounts;
  final Map<String, dynamic> resultData;

  const SavingPlanPage2({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [],
    required this.resultData,
  });

  @override
  _SavingPlanPage2State createState() => _SavingPlanPage2State();
}

class _SavingPlanPage2State extends State<SavingPlanPage2> {
  int _currentMonthIndex = 0; // Track the selected month
  int _startIndex = 0; // Track the first visible month index

  List<String> months = []; // Dynamically generated months
  List<Map<String, dynamic>> savingsPlan = []; // Savings plan for all months

  @override
  void initState() {
    super.initState();
    generateMonths(widget.resultData['DurationMonths']);
    generateSavingsPlan(widget.resultData['MonthlySavingsPlan']);
  }

  void generateMonths(int durationMonths) {
    // Dynamically create month labels based on duration
    months = List.generate(durationMonths, (index) => "الشهر ${index + 1}");
  }

  void generateSavingsPlan(Map<String, dynamic> monthlySavingsPlan) {
    // Generate the savings plan based on Python result
    savingsPlan = monthlySavingsPlan.entries
        .map((entry) => {
              'category': entry.key,
              'monthlySavings': entry.value,
            })
        .toList();
  }

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
    List<String> visibleMonths = months.sublist(
        _startIndex, (_startIndex + 2).clamp(0, months.length));
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
            top: 300,
            left: 10,
            right: 10,
            child: SizedBox(
              height: 365, // Set a larger height for the scrollable area
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Wrap(
                      spacing: 27, // Space between squares
                      runSpacing: 30, // Space between rows
                      children: savingsPlan.map((saving) {
                        return SizedBox(
                          width: (MediaQuery.of(context).size.width / 2) - 40,
                          child: buildCategorySquare(
                            saving['category'],
                            saving['monthlySavings'],
                          ),
                        );
                      }).toList(),
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
                        Icons.calendar_today, "خطة الإدخار", 3, onTap: () {}),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategorySquare(String category, dynamic monthlySavings) {
    return Container(
      width: 101,
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 40,
            left: 10,
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'GE-SS-Two-Light',
                color: Color(0xFF3D3D3D),
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 10,
            child: Text(
              "مجموع الادخار: ${monthlySavings.toStringAsFixed(2)} ريال",
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'GE-SS-Two-Light',
                color: Color(0xFF3D3D3D),
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
