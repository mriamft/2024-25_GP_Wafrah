import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'banks_page.dart';
import 'saving_plan_page.dart';
import 'home_page.dart';

class TransactionsPage extends StatelessWidget {
  final String userName;
  final String phoneNumber;
  final List<Map<String, dynamic>> accounts;

  const TransactionsPage({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [],
  });

  // Function to extract and group transactions by date
  List<Map<String, dynamic>> getGroupedTransactions() {
    List<Map<String, dynamic>> allTransactions = [];

    for (var account in accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        allTransactions.add(transaction);
      }
    }

    // Sort transactions by date
    allTransactions.sort((a, b) {
      String dateA = a['TransactionDateTime'] ?? '';
      String dateB = b['TransactionDateTime'] ?? '';
      DateTime dateTimeA = DateTime.tryParse(dateA) ?? DateTime.now();
      DateTime dateTimeB = DateTime.tryParse(dateB) ?? DateTime.now();
      return dateTimeB.compareTo(dateTimeA);
    });

    // Group transactions by date
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in allTransactions) {
      String date =
          transaction['TransactionDateTime']?.split('T').first ?? 'غير معروف';
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    // Convert grouped map to a list of maps for easier building
    List<Map<String, dynamic>> result = [];
    groupedTransactions.forEach((date, transactions) {
      result.add({'date': date, 'transactions': transactions});
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> groupedTransactions = getGroupedTransactions();

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
            top: 210,
            right: 12,
            child: Text(
              'سجل المعاملات',
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
            left: 10,
            right: 10,
            bottom: 90,
            child: groupedTransactions.isEmpty
                ? const Center(
                    child: Text(
                      'لا يوجد لديك معاملات',
                      style: TextStyle(
                        color: Color(0xFF3D3D3D),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'GE-SS-Two-Bold',
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: groupedTransactions.length,
                    itemBuilder: (context, index) {
                      var group = groupedTransactions[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                group['date'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3D3D3D),
                                  fontFamily: 'GE-SS-Two-Bold',
                                ),
                              ),
                            ),
                          ),
                          ...group['transactions'].map<Widget>((transaction) {
                            return GestureDetector(
                              onTap: () {
                                _showTransactionDetails(context, transaction);
                              },
                              child: _buildTransactionCard(transaction),
                            );
                          }).toList(),
                        ],
                      );
                    },
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
                              )),
                    );
                  }),
                  buildBottomNavItem(Icons.credit_card, "سجل المعاملات", 1,
                      onTap: () {
                    // Already on Transactions page
                  }),
                  buildBottomNavItem(Icons.home_outlined, "الرئيسية", 2,
                      onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
                                userName: userName,
                                phoneNumber: phoneNumber,
                                accounts: accounts,
                              )),
                    );
                  }),
                  buildBottomNavItem(Icons.calendar_today, "خطة الإدخار", 3,
                      onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SavingPlanPage(
                                userName: userName,
                                phoneNumber: phoneNumber,
                                accounts: accounts,
                              )),
                    );
                  }),
                ],
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
                      Icons.account_balance,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {
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

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    String amount = transaction['Amount']?['Amount'] ?? '0.00';
    String subtype =
        transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
            'غير معروف';
    String category = transaction['Category'] ?? 'غير مصنف';

    Color amountColor;
    if (subtype == 'MoneyTransfer' ||
        subtype == 'Withdrawal' ||
        subtype == 'Purchase' ||
        subtype == 'DepositReversal') {
      amountColor = Colors.red;
    } else if (subtype == 'Deposit' ||
        subtype == 'WithdrawalReversal' ||
        subtype == 'Refund') {
      amountColor = Colors.green;
    } else {
      amountColor = const Color(0xFF3D3D3D);
    }

    // Mapping of categories to icons
    Map<String, IconData> categoryIcons = {
      'المطاعم': Icons.restaurant,
      'التعليم': Icons.school,
      'الصحة': Icons.local_hospital,
      'التسوق': Icons.shopping_bag,
      'تسوق': Icons.shopping_bag,
      'الترفيه': Icons.movie,
      'البقالة': Icons.local_grocery_store,
      'النقل': Icons.directions_bus,
      'السفر': Icons.flight,
      'الحكومة': Icons.account_balance,
      'العمل الخيري': Icons.volunteer_activism,
      'الاستثمار': Icons.trending_up,
      'الإيجار': Icons.home,
      'القروض': Icons.money,
      'الراتب والإيرادات': Icons.account_balance_wallet,
      'التحويلات': Icons.swap_horiz,
      'أخرى': Icons.category,
    };

    IconData categoryIcon = categoryIcons[category] ?? Icons.help_outline;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10), // Space before the arrow
          const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF3D3D3D), size: 15), // Arrow icon
          const SizedBox(width: 10), // Space after the arrow
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ر.س',
                      style: TextStyle(
                        color: amountColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'GE-SS-Two-Light',
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      amount,
                      style: TextStyle(
                        color: amountColor,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'GE-SS-Two-Bold',
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        color: Color(0xFF3D3D3D),
                        fontSize: 17,
                        fontFamily: 'GE-SS-Two-Bold',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10), // Space before the icon
          Icon(categoryIcon,
              color: const Color(0xFF3D3D3D), size: 24), // Category icon
        ],
      ),
    );
  }

  void _showTransactionDetails(
      BuildContext context, Map<String, dynamic> transaction) {
    // Find the account containing this transaction
    String accountIban = 'غير معروف';
    for (var account in accounts) {
      var transactions = account['transactions'] ?? [];
      if (transactions.contains(transaction)) {
        accountIban = account['IBAN'] ?? 'غير معروف';
        break;
      }
    }

    String amount = transaction['Amount']?['Amount'] ?? '0.00';
    String subtype = transaction['SubTransactionType'] ?? 'غير معروف';
    String dateTime = transaction['TransactionDateTime'] ?? 'غير معروف';
    String category = transaction['Category'] ?? 'غير مصنف';
    String transactionInfo =
        transaction['TransactionInformation'] ?? 'لا توجد معلومات';

    subtype = subtype.replaceAll('KSAOB.', '').trim();

    Map<String, String> transactionTypeTranslations = {
      'MoneyTransfer': 'تحويل مالي',
      'WithdrawalReversal': 'سحب عكسي',
      'Withdrawal': 'سحب مبلغ',
      'Deposit': 'إيداع',
      'NotApplicable': 'غير قابل للتطبيق',
      'Purchase': 'شراء بضاعة',
      'Refund': 'إعادة مبلغ',
      'DepositReversal': 'إيداع عكسي',
      'Reversal': 'عملية عكسية',
    };

    if (!transactionTypeTranslations.containsKey(subtype)) {
      debugPrint('Missing SubTransactionType: $subtype');
    }

    String translatedSubtype =
        transactionTypeTranslations[subtype] ?? 'غير معروف';
    String date = dateTime.split('T').first;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF308C64),
          title: Stack(
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'تفاصيل العملية',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Light',
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              Positioned(
                right: -17,
                top: -18,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('المبلغ: $amount ر.س ',
                  style: const TextStyle(
                      fontFamily: 'GE-SS-Two-Bold',
                      fontSize: 15,
                      color: Colors.white)),
              Text('النوع: $translatedSubtype',
                  style: const TextStyle(
                      fontFamily: 'GE-SS-Two-Bold',
                      fontSize: 15,
                      color: Colors.white)),
              Text('التاريخ: $date',
                  style: const TextStyle(
                      fontFamily: 'GE-SS-Two-Bold',
                      fontSize: 15,
                      color: Colors.white)),
              Text('الفئة: $category',
                  style: const TextStyle(
                      fontFamily: 'GE-SS-Two-Bold',
                      fontSize: 15,
                      color: Colors.white)),
              Text('$transactionInfo :العملية من',
                  style: const TextStyle(
                      fontFamily: 'GE-SS-Two-Bold',
                      fontSize: 15,
                      color: Colors.white)),
              Text('رقم الإيبان: $accountIban',
                  style: const TextStyle(
                      fontFamily: 'GE-SS-Two-Bold',
                      fontSize: 15,
                      color: Colors.white)),
            ],
          ),
        );
      },
    );
  }

  Widget buildBottomNavItem(IconData icon, String label, int index,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF2C8C68), size: 30),
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
