import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'transactions_page.dart';
import 'banks_page.dart';
import 'home_page.dart';

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
  List<String> months = []; // Dynamically generated months
  List<Map<String, dynamic>> savingsPlan = []; // Savings plan for all months
  Map<String, double> categoryTotalSavings =
      {}; // Store total savings per category

  @override
@override
void initState() {
  super.initState();
  generateMonths(widget.resultData['DurationMonths']);

  _currentMonthIndex = 0; // Ensure "الخطة كاملة" is selected by default

  // Initialize categoryTotalSavings before calling generateSavingsPlan()
  categoryTotalSavings = Map<String, double>.from(
    widget.resultData['CategorySavings']
        .map((key, value) => MapEntry(key, (value as num).toDouble()))
  );

  // Call generateSavingsPlan after categoryTotalSavings is initialized
  setState(() {
    generateSavingsPlan();
  });
}



 void generateMonths(dynamic durationMonths) {
  int monthsCount =
      (durationMonths is int) ? durationMonths : durationMonths.toInt();

  months.clear();
  months.add("الخطة كاملة"); // Full Plan at index 0
  months.addAll(List.generate(monthsCount, (index) => "الشهر ${index + 1}"));
}






void generateSavingsPlan() {
  print("Generating Savings for Month: $_currentMonthIndex");

  int totalMonths = months.length - 1; // Exclude "الخطة كاملة"

  if (_currentMonthIndex == 0) {
    // Full Plan (index 0)
    savingsPlan = categoryTotalSavings.entries
        .where((entry) => entry.value > 0) // Remove zero-value categories
        .map((entry) {
      return {
        'category': entry.key,
        'monthlySavings': entry.value, // Full savings
      };
    }).toList();
  } else {
    // Regular Month (from 1 to last index)
    savingsPlan = categoryTotalSavings.entries
        .map((entry) {
          double monthlySavings = entry.value / totalMonths;
          return {
            'category': entry.key,
            'monthlySavings': (_currentMonthIndex == totalMonths)
                ? monthlySavings // Show savings for the last month
                : monthlySavings, // Show savings per selected month
          };
        })
        .where((entry) => (entry['monthlySavings'] as num) > 0)
        .toList();
  }

  print("Final Computed Savings for $_currentMonthIndex: $savingsPlan");
}



List<Widget> buildCategorySquares() {
  return savingsPlan
      .where((saving) => saving['monthlySavings'] > 0) // Hide zero-value categories
      .map((saving) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width / 2) - 40,
          child: buildCategorySquare(
            saving['category'],
            saving['monthlySavings'], // Show savings per selected month
          ),
        );
      }).toList();
}




 void _onMonthChanged(String? newMonth) {
  setState(() {
    int newIndex = months.indexOf(newMonth!);

    if (newIndex >= 0 && newIndex < months.length) {
      _currentMonthIndex = newIndex;
      generateSavingsPlan(); // Refresh data
    } else {
      print(" Error: Selected month index out of range");
    }
  });
}






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
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: months[_currentMonthIndex],
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  elevation: 16,
                  style:
                      const TextStyle(color: Color(0xFF3D3D3D), fontSize: 16),
                  dropdownColor: const Color(0xFFFFFFFF),
                  underline: Container(
                    height: 2,
                    color: const Color(0xFF2C8C68),
                  ),
                  onChanged: _onMonthChanged,
                  items: months.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontFamily: 'GE-SS-Two-Light',
                              fontSize: 16,
                              color: Color.fromARGB(133, 0, 0, 0),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
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
                      children: _currentMonthIndex == months.length - 1
                          ? buildCategorySquares() // Show all categories with total
                          : savingsPlan.map((saving) {
                              return SizedBox(
                                width: (MediaQuery.of(context).size.width / 2) -
                                    40,
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
          // Home Button with gradient circle
Positioned(
  bottom: 82, // Adjust this to move the home button up
  left: 0,
  right: 0,
  child: Stack(
    alignment: Alignment.center,
    children: [
      // Outer Circle (White background to blend)
      Container(
        width: 80, // Increase to prevent clipping
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFFF9F9F9), // Matches the navbar background
          shape: BoxShape.circle,
        ),
      ),
      // Inner Circle (Green Gradient Home Button)
      Container(
        width: 90, // Increase size
        height: 90, // Increase size
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
                  accounts: widget.accounts,
                ),
              ),
            );
          },
        ),
      ),
    ],
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
        ],
      ),
    );
  }

  Widget buildCategorySquare(String category, dynamic monthlySavings) {
    Map<String, IconData> categoryIcons = {
      'المطاعم': Icons.restaurant,
      'التعليم': Icons.school,
      'الصحة': Icons.local_hospital,
      'تسوق': Icons.shopping_bag,
      'البقالة': Icons.local_grocery_store,
      'النقل': Icons.directions_bus,
      'السفر': Icons.flight,
      'المدفوعات الحكومية': Icons.account_balance,
      'الترفيه': Icons.gamepad_rounded,
      'الاستثمار': Icons.trending_up,
      'الإيجار': Icons.home,
      'القروض': Icons.money,
      'الراتب': Icons.account_balance_wallet,
      'التحويلات': Icons.swap_horiz,
      'الخطة كامله': Icons.check_circle, // Special icon for the complete plan
    };

    IconData categoryIcon = categoryIcons[category] ?? Icons.help_outline;

    // Show total savings for "الخطة كامله"
    double displaySavings = category == "الخطة كامله"
        ? categoryTotalSavings.values.fold(
            0,
            (prev, curr) =>
                prev + curr) // Use the total savings for "الخطة كامله"
        : monthlySavings;

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
            right: 10,
            child: Text(
              category,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'GE-SS-Two-Bold',
                color: Color(0xFF3D3D3D),
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 10,
            right: 10,
            child: Text(
              "المبلغ المطلوب\n ادخاره: ${displaySavings.toStringAsFixed(2)} ريال",
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'GE-SS-Two-Light',
                color: Color(0xFF3D3D3D),
              ),
            ),
          ),
          Positioned(
            top: 6,
            left: 6,
            child: Icon(
              categoryIcon,
              color: const Color(0xFF2C8C68),
              size: 24,
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
