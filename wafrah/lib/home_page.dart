import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'transactions_page.dart';
import 'saving_plan_page.dart';
import 'banks_page.dart';

class HomePage extends StatefulWidget {
  final String userName; // Dynamic user name passed from SignUp or Login
  final String phoneNumber;
  final List<Map<String, dynamic>> accounts; // Add accounts parameter

  const HomePage({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [], // Default to empty list if not passed
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  int currentPage = 0; // Track the current dashboard
  final PageController _pageController =
      PageController(); // Controller for PageView
  bool _isCirclePressed = false; // Track if the circle button is pressed
  bool _isBalanceVisible = true; // New variable to toggle visibility


  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Define the animation for the green square image (from top to its final position y = -100)
    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: const Offset(0, 0))
            .animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start the animation when the page is opened
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _toggleBalanceVisibility() {
  setState(() {
    _isBalanceVisible = !_isBalanceVisible;
  });
}

// Masked display for hidden values
  String getMaskedValue() => '****';

  // Calculate the total balance from the accounts list
  String getTotalBalance() {
    double totalBalance = widget.accounts.fold(0.0, (sum, account) {
      return sum + double.parse(account['Balance'] ?? '0');
    });
    return totalBalance.toStringAsFixed(2); // Format to 2 decimal places
  }

  // Calculate the total income and expense from transactions for a specific month in 2016
Map<String, double> calculateIncomeAndExpense() {
  double totalIncome = 0.0;
  double totalExpense = 0.0;

  // Get the current month and specify the year as 2016
  int month = DateTime.now().month;
  int year = 2016;
  DateTime startOfMonth = DateTime(year, month, 1);
  DateTime endOfMonth = DateTime(year, month + 1, 0); // Last day of the month

  for (var account in widget.accounts) {
    var transactions = account['transactions'] ?? [];
    for (var transaction in transactions) {
      // Retrieve the transaction date from 'TransactionDateTime'
      String? dateStr = transaction['TransactionDateTime'];
      if (dateStr != null) {
        DateTime transactionDate = DateTime.tryParse(dateStr) ?? DateTime.now();

        // Check if the transaction date is within the specified month and year
        if (transactionDate.isAfter(startOfMonth.subtract(Duration(days: 1))) &&
            transactionDate.isBefore(endOfMonth.add(Duration(days: 1)))) {
          String subtype = transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? 'غير معروف';
          String amountStr = transaction['Amount']?['Amount'] ?? '0.00';
          double amount = double.tryParse(amountStr) ?? 0.0;

          if (['MoneyTransfer', 'Withdrawal', 'Purchase', 'DepositReversal', 'NotApplicable'].contains(subtype)) {
            totalExpense += amount;
          } else if (['Deposit', 'WithdrawalReversal', 'Refund'].contains(subtype)) {
            totalIncome += amount;
          }
        }
      }
    }
  }

  return {'income': totalIncome, 'expense': totalExpense};
}


  @override
  Widget build(BuildContext context) {
    Map<String, double> totals = calculateIncomeAndExpense(); 
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Green square animation
          SlideTransition(
            position: _offsetAnimation,
            child: Stack(
              children: [
                // Green square image (keep the original aspect ratio)
                Positioned(
                  top: -100, // Final stop position for y
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/images/green_square.png',
                    width: MediaQuery.of(context).size.width,
                    height: 289,
                    fit: BoxFit.contain, // Keep original aspect ratio
                  ),
                ),
                // "أهلًا {userName}!" Greeting Text (Sticky to the right side of the image)
                Positioned(
                  top: 25,
                  right: 20, // Stick to the right side of the image
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: '!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontFamily: 'GE-SS-Two-Light',
                          ),
                        ),
                        const TextSpan(
                          text: 'أهلًا ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontFamily: 'GE-SS-Two-Light',
                          ),
                        ),
                        TextSpan(
                          text: widget.userName
                              .split(' ')
                              .first, // Extract only the first name
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontFamily: 'GE-SS-Two-Bold', // Bold user name
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main white card for content (dashboard)
          Positioned(
            top: 80,
            left: 19,
            right: 19,
            child: Container(
              height: 610, // Reduced height of the dashboard
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                children: [
                  buildFirstDashboard(totals['income']!, totals['expense']!),
                  buildSecondDashboard(),
                ],
              ),
            ),
          ),

          // Circle indicators for dashboard navigation
          Positioned(
            bottom: 150, // Positioned higher
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildDot(0),
                const SizedBox(width: 10),
                buildDot(1),
              ],
            ),
          ),

          // Bottom Navigation Bar with shadow
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
                    color: Colors.black.withOpacity(0.2), // Shadow color
                    blurRadius: 10, // Shadow blur
                    offset:
                        const Offset(0, -5), // Shadow position (above the bar)
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildBottomNavItem(Icons.settings_outlined, "إعدادات", 0,
                      onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SettingsPage(
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber,
                        ),
                        transitionDuration:
                            const Duration(seconds: 0), // Disable transition
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child; // No animation
                        },
                      ),
                      (route) => false,
                    );
                  }), // Outlined settings icon

                  buildBottomNavItem(Icons.credit_card, "سجل المعاملات", 1,
                      onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            TransactionsPage(
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber,
                          accounts: widget.accounts,
                        ),
                        transitionDuration:
                            const Duration(seconds: 0), // Disable transition
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child; // No animation
                        },
                      ),
                      (route) => false,
                    );
                  }), // Transaction icon

                  buildBottomNavItem(Icons.home_outlined, "الرئيسية", 2,
                      isSelected: true, onTap: () {}), // Outlined home icon

                  buildBottomNavItem(Icons.calendar_today, "خطة الإدخار", 3,
                      onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SavingPlanPage(
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber,
                          accounts: widget.accounts,
                        ),
                        transitionDuration:
                            const Duration(seconds: 0), // Disable transition
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child; // No animation
                        },
                      ),
                      (route) => false,
                    );
                  }), // Plan icon
                ],
              ),
            ),
          ),

          // Circular Button above the Navigation Bar (F9F9F9 circle + gradient green circle)
          Positioned(
            bottom: 45, // Adjusted the position to be more lower
            left: 0,
            right: 0,
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _isCirclePressed = true; // Set the state to pressed
                });
              },
              onTapUp: (_) {
                setState(() {
                  _isCirclePressed = false; // Reset the state after press
                });
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        BanksPage(
                      userName: widget.userName,
                      phoneNumber: widget.phoneNumber,
                      accounts: widget.accounts, // Pass accounts
                    ),
                    transitionDuration:
                        const Duration(seconds: 0), // Disable transition
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return child; // No animation
                    },
                  ),
                  (route) => false,
                );
              },
              onTapCancel: () {
                setState(() {
                  _isCirclePressed =
                      false; // Reset the state if tap is canceled
                });
              },
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isCirclePressed
                            ? [const Color(0xFF1A7A5E), const Color(0xFF6FC3A0)]
                            : [
                                const Color(0xFF2C8C68),
                                const Color(0xFF8FD9BD)
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dot for switching between dashboards
  Widget buildDot(int pageIndex) {
    return Container(
      width: 10, // Smaller width
      height: 10, // Smaller height
      decoration: BoxDecoration(
        color: currentPage == pageIndex ? const Color(0xFF2C8C68) : Colors.grey,
        shape: BoxShape.circle,
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
            size: 30, // Increased size for icons
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2C8C68),
              fontSize: 12,
              fontFamily: 'GE-SS-Two-Light',
            ),
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C8C68),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // First Dashboard Layout
 Widget buildFirstDashboard(double totalIncome, double totalExpense) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 80), // Additional top padding for centering

        Stack(
          children: [
            // "مجموع أموالك" Text and Balance Display
            Column(
              children: [
                const Text(
                  'مجموع أموالك',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Light',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),

                // Display total balance with toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ر.س', // Currency symbol
                      style: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isBalanceVisible ? getTotalBalance() : getMaskedValue(),
                      style: const TextStyle(
                        fontFamily: 'GE-SS-Two-Bold',
                        fontSize: 32,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Eye icon to toggle balance visibility
            Positioned(
              top: -10, // Move it up further
              right: 0,
              child: IconButton(
                icon: Icon(
                  _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black,
                  size: 24,
                ),
                onPressed: _toggleBalanceVisibility,
              ),
            ),
          ],
        ),

        const SizedBox(height: 60), // Increase spacing for a more centered look

        // "تدفقك المالي لهذا الشهر" Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text(
                'تدفقك المالي لهذا الشهر',
                style: TextStyle(
                  fontFamily: 'GE-SS-Two-Light',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Expense Section
                  Column(
                    children: [
                      Icon(Icons.arrow_downward, color: Colors.red, size: 24),
                      const SizedBox(height: 5),
                      const Text(
                        'الصرف',
                        style: TextStyle(
                          fontFamily: 'GE-SS-Two-Light',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text(
                            'ر.س', // Currency symbol
                            style: TextStyle(
                              fontFamily: 'GE-SS-Two-Light',
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _isBalanceVisible
                                ? totalExpense.toStringAsFixed(2)
                                : getMaskedValue(),
                            style: const TextStyle(
                              fontFamily: 'GE-SS-Two-Bold',
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Divider
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.grey[300],
                  ),

                  // Income Section
                  Column(
                    children: [
                      Icon(Icons.arrow_upward, color: Colors.green, size: 24),
                      const SizedBox(height: 5),
                      const Text(
                        'الدخل',
                        style: TextStyle(
                          fontFamily: 'GE-SS-Two-Light',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text(
                            'ر.س', // Currency symbol
                            style: TextStyle(
                              fontFamily: 'GE-SS-Two-Light',
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _isBalanceVisible
                                ? totalIncome.toStringAsFixed(2)
                                : getMaskedValue(),
                            style: const TextStyle(
                              fontFamily: 'GE-SS-Two-Bold',
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}




  // Second Dashboard Layout
  Widget buildSecondDashboard() {
    return Container(); 
  }
} 