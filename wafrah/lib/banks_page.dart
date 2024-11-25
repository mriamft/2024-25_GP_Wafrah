import 'package:flutter/material.dart';
import 'acc_link_page.dart';
import 'transactions_page.dart';
import 'home_page.dart';
import 'saving_plan_page.dart';
import 'settings_page.dart';
import 'storage_service.dart';

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
Future<void> _saveAccountsLocally(List<Map<String, dynamic>> accounts) async {
  await _storageService.saveAccountDataLocally(widget.phoneNumber, accounts);
}
Future<List<Map<String, dynamic>>> _loadAccountsLocally(String phoneNumber) async {
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

    print('Transaction Categories: $categories'); // Debugging
    return categories;
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'ر.س',
                  style: TextStyle(
                    color: Color(0xFF5F5F5F),
                    fontSize: 16,
                    fontFamily: 'GE-SS-Two-Light',
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  account['Balance'] ?? '0',
                  style: const TextStyle(
                    color: Color(0xFF313131),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GE-SS-Two-Bold',
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  translatedAccountSubType,
                  style: const TextStyle(
                    color: Color(0xFF3D3D3D),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GE-SS-Two-Bold',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      account['IBAN'] ?? 'رقم الايبان',
                      style: const TextStyle(
                        color: Color(0xFF5F5F5F),
                        fontSize: 13,
                        fontFamily: 'GE-SS-Two-Light',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 5),
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
              ),
            ],
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(right: 10),
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
              fit: BoxFit.cover,
            ),
          ),
          // Top Row with Add Button
          Positioned(
            top: 202,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
IconButton(
  icon: Icon(
    Icons.add_circle,
    color: _accounts.isEmpty
        ? const Color(0xFF3D3D3D) // Enabled color
        : Colors.grey, // Disabled color
    size: 30,
  ),
  onPressed: _accounts.isEmpty
      ? () {
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
        }
      : null, // Disable button
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
          // Edit Button
          Positioned(
            top: 240,
            left: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
  onPressed: _accounts.isNotEmpty
      ? () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AccLinkPage(
                userName: widget.userName,
                phoneNumber: widget.phoneNumber,
                accounts: _accounts, // Pass accounts here

              ),
            ),
          );
        }
      : null, // Disable button
  child: Icon(
    Icons.edit,
    color: _accounts.isNotEmpty
        ? const Color(0xFF3D3D3D) // Enabled color
        : Colors.grey, // Disabled color
  ),
),

            ),
          ),
          // Scrollable Accounts List
          Positioned(
            top: 280, // Adjust this value to move the list higher
            left: 12,
            right: 12,
            bottom: 77, // Space for the bottom navigation bar
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
                  buildBottomNavItem(Icons.settings_outlined, "إعدادات", () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(
                            userName: widget.userName,
                            phoneNumber: widget.phoneNumber,
                            accounts: widget.accounts),
                      ),
                    );
                  }),
                  buildBottomNavItem(Icons.credit_card, "سجل المعاملات", () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionsPage(
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber,
                          accounts: _accounts,
                        ),
                      ),
                    );
                  }),
                  buildBottomNavItem(Icons.home_outlined, "الرئيسية", () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber,
                          accounts: _accounts,
                        ),
                      ),
                    );
                  }),
                  buildBottomNavItem(Icons.calendar_today, "خطة الإدخار", () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SavingPlanPage(
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber,
                          accounts: _accounts,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Point under "إعدادات"
          Positioned(
            right: 192,
            top: 765,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF2C8C68), // Point color
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Circular Button above the Navigation Bar
          Positioned(
            bottom: 45,
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
