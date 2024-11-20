import 'package:flutter/material.dart';
import 'acc_link_page.dart';
import 'transactions_page.dart';
import 'home_page.dart';
import 'saving_plan_page.dart';
import 'settings_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

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
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _accounts = [];

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
      final loadedAccounts = await _loadAccountsLocally();
      setState(() {
        _accounts = loadedAccounts;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadAccountsLocally() async {
    String? accountsJson = await _storage.read(key: 'user_accounts');
    if (accountsJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(accountsJson));
    }
    return [];
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
                  icon: const Icon(
                    Icons.add_circle,
                    color: Color(0xFF3D3D3D),
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccLinkPage(
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber,
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
            top: 240,
            left: 12,
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccLinkPage(
                        userName: widget.userName,
                        phoneNumber: widget.phoneNumber,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor:
                      Colors.transparent, // Ensures no background color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit,
                      color: Color(0xFF3D3D3D),
                    ),
                    SizedBox(width: 5),
                    Text(
                      '',
                      style: TextStyle(
                        color: Color(0xFF3D3D3D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 350,
            left: 12,
            right: 12,
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
