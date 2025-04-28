import 'package:flutter/material.dart';
import 'package:wafrah/session_manager.dart';
import 'acc_link_page.dart';
import 'transactions_page.dart';
import 'home_page.dart';
import 'saving_plan_page.dart';
import 'settings_page.dart';
import 'storage_service.dart';
import 'saving_plan_page2.dart';
import 'secure_storage_helper.dart'; // Import the secure storage helper
import 'custom_icons.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'chatbot.dart';

class BanksPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final List<Map<String, dynamic>> accounts;

  const BanksPage({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [],
  });

  @override
  _BanksPageState createState() => _BanksPageState();
}

class _BanksPageState extends State<BanksPage> {
  final StorageService _storageService = StorageService();
  List<Map<String, dynamic>> _accounts = [];
  bool _isCirclePressed = false; // Add this line

  @override
  void initState() {
    super.initState();
    _initializeAccounts();
    SessionManager.startTracking(context);
  }
  @override
void dispose() {
  SessionManager.dispose();
  super.dispose();
}


  Future<void> _initializeAccounts() async {
    if (widget.accounts.isNotEmpty) {
      setState(() {
        _accounts = widget.accounts;
      });
    } else {
      final loadedAccounts = await _loadAccountsLocally(widget.phoneNumber);
      setState(() {
        _accounts = loadedAccounts;
      });
    }
  }

  String formatNumberWithArabicComma(double number) {
    // Convert the number to Arabic numerals with a comma separator
    String formattedNumber = NumberFormat("#,##0.00", "ar").format(number);

    // Replace the default decimal point (.) with Arabic comma (،)
    formattedNumber = formattedNumber.replaceAll('.', '،');

    return formattedNumber;
  }

  Future<void> _saveAccountsLocally(List<Map<String, dynamic>> accounts) async {
    await _storageService.saveAccountDataLocally(widget.phoneNumber, accounts);
  }

  Future<List<Map<String, dynamic>>> _loadAccountsLocally(
      String phoneNumber) async {
    return await _storageService.loadAccountDataLocally(phoneNumber);
  }

  Map<String, double> calculateTransactionCategories(
      List<Map<String, dynamic>> accounts) {
    Map<String, double> categories = {};

    for (var account in accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String category = transaction['Category'] ?? 'غير مصنف';
        double amount = double.tryParse(
                transaction['Amount']?['Amount']?.toString() ?? '0.0') ??
            0.0;
        categories[category] = (categories[category] ?? 0.0) + amount;
      }
    }

    print('Transaction Categories: $categories');
    return categories;
  }

  void navigateToSavingPlan() async {
    // Check if there is a saved plan
    var savedPlan = await loadPlanFromSecureStorage();

    // If saved plan exists, navigate to SavingPlanPage2
    if (savedPlan != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => SavingPlanPage2(
            userName: widget.userName,
            phoneNumber: widget.phoneNumber,
            accounts: widget.accounts,
            resultData: savedPlan, // Pass saved plan data to the next page
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      // If no saved plan exists, navigate to GoalPage to create a new plan
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => SavingPlanPage(
            userName: widget.userName,
            phoneNumber: widget.phoneNumber,
            accounts: widget.accounts,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  Widget _buildAccountCard(Map<String, dynamic> account) {
    Map<String, String> accountTypeTranslations = {
      'CurrentAccount': 'الحساب الجاري',
      'SavingsAccount': 'حساب التوفير',
      'CheckingAccount': 'حساب الشيكات',
      'CreditAccount': 'حساب الائتمان',
    };

    String accountSubType = account['AccountSubType'] ?? 'نوع الحساب';
    String translatedAccountSubType =
        accountTypeTranslations[accountSubType] ?? accountSubType;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: 340,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // ✅ Ensures spacing between items
        children: [
          // Left section for monetary amount
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Row(
              children: [
                const Icon(
                  CustomIcons.riyal, // Use the new Riyal symbol
                  size: 14, // Adjust size as needed
                  color: Color(0xFF5F5F5F),
                ),
                const SizedBox(width: 5), // Spacing between icon and amount
                Text(
                  formatNumberWithArabicComma(
                      double.tryParse(account['Balance']?.toString() ?? '0') ??
                          0.0),
                  style: const TextStyle(
                    color: Color(0xFF313131),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GE-SS-Two-Bold',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Middle section for account details
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.end, // ✅ Ensures right alignment
              children: [
                Text(
                  translatedAccountSubType,
                  style: const TextStyle(
                    color: Color(0xFF3D3D3D),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GE-SS-Two-Bold',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(
                    height:
                        8), // ✅ Adds space above the IBAN to prevent overlap

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // ✅ Ensures text alignment
                  children: [
                    Expanded(
                      // ✅ Allows the IBAN to take available space
                      child: Text(
                        account['IBAN'] ?? 'رقم الايبان',
                        style: const TextStyle(
                          color: Color(0xFF5F5F5F),
                          fontSize: 13,
                          fontFamily: 'GE-SS-Two-Light',
                        ),
                        textAlign: TextAlign.right,
                        softWrap: false, // Prevents automatic wrapping
                        overflow: TextOverflow
                            .visible, // ✅ Ensures full IBAN is shown
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'رقم الآيبان',
                      style: TextStyle(
                        color: Color(0xFF3D3D3D),
                        fontSize: 13,
                        fontFamily: 'GE-SS-Two-Bold',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right section for SAMA logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Image.asset(
              'assets/images/SAMA_logo.png',
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
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
          Positioned(
            top: 202,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    _accounts.isEmpty ? Icons.add_circle : Icons.edit,
                    color: _accounts.isEmpty
                        ? const Color(0xFF3D3D3D)
                        : const Color(0xFF3D3D3D),
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccLinkPage(
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber,
                          accounts: _accounts,
                        ),
                      ),
                    );
                  },
                ),
                const Text(
                  'الحسابات البنكية',
                  style: TextStyle(
                    color: Color(0xFF3D3D3D),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GE-SS-Two-Bold',
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 280,
            left: 12,
            right: 12,
            bottom: 77,
            child: SingleChildScrollView(
              child: Column(
                children: _accounts.isNotEmpty
                    ? _accounts.map((account) {
                        return _buildAccountCard(account);
                      }).toList()
                    : [
                        const Center(
                          child: Text(
                            'لم تقم بإضافة حساباتك البنكية',
                            style: TextStyle(
                              color: Color(0xFF3D3D3D),
                              fontSize: 16,
                              fontFamily: 'GE-SS-Two-Light',
                            ),
                          ),
                        ),
                      ],
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
                  buildBottomNavItem(Icons.settings_outlined, "إعدادات", () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            SettingsPage(
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber,
                          accounts: widget.accounts,
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }),
                  buildBottomNavItem(Icons.credit_card, "سجل المعاملات", () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            TransactionsPage(
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber,
                          accounts: _accounts,
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }),
                  Transform.translate(
                    offset: const Offset(0, -5),
                    child: buildBottomNavItem(
                        Icons.account_balance_outlined, "الحسابات", () {}),
                  ),
                  buildBottomNavItem(Icons.calendar_today, "خطة الإدخار",
                      navigateToSavingPlan),
                ],
              ),
            ),
          ),
          Positioned(
            right: 144,
            top: 784,
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
            bottom: 45,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _isCirclePressed = true;
                });
              },
              onTapUp: (_) {
                setState(() {
                  _isCirclePressed = false;
                });
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        BanksPage(
                      userName: widget.userName,
                      phoneNumber: widget.phoneNumber,
                      accounts: widget.accounts,
                    ),
                    transitionDuration: const Duration(seconds: 0),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return child;
                    },
                  ),
                  (route) => false,
                );
              },
              onTapCancel: () {
                setState(() {
                  _isCirclePressed = false;
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              HomePage(
                            userName: widget.userName,
                            phoneNumber: widget.phoneNumber,
                            accounts: _accounts,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isCirclePressed
                              ? [
                                  const Color(0xFF1A7A5E),
                                  const Color(0xFF6FC3A0)
                                ]
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
                        Icons.home,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          // Chatbot button with the image in the specified position
          Positioned(
            top: 650, // Position the image at x=333 and y=702
            left: 328,
            child: GestureDetector(
              onTap: navigateToChatbot, // Navigate to Chatbot when clicked
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/chatbotIcon.png', // Image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigateToChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chatbot(
          userName: widget.userName,
          phoneNumber: widget.phoneNumber,
          accounts: widget.accounts,
        ),
      ),
    );
  }

  Widget buildBottomNavItem(IconData icon, String label, VoidCallback onTap) {
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
