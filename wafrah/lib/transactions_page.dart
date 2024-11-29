import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'banks_page.dart';
import 'saving_plan_page.dart';
import 'home_page.dart';

class TransactionsPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final List<Map<String, dynamic>> accounts;

  const TransactionsPage({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [],
  });

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String selectedIBAN = "الكل";

  List<Map<String, dynamic>> getGroupedTransactions() {
    List<Map<String, dynamic>> allTransactions = [];

    for (var account in widget.accounts) {
      // If a specific IBAN is selected, only add transactions for that account
      if (selectedIBAN != "الكل" && account['IBAN'] != selectedIBAN) {
        continue;
      }

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

    // Get today's date
    DateTime today = DateTime.now();

    // Group transactions by modified date and filter future dates
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in allTransactions) {
      String date =
          transaction['TransactionDateTime']?.split('T').first ?? 'غير معروف';

      // Modify the year mapping
      if (date != 'غير معروف') {
        DateTime originalDate = DateTime.tryParse(date) ?? DateTime.now();
        int mappedYear = originalDate.year == 2016
            ? 2024
            : originalDate.year == 2017
                ? 2025
                : originalDate.year; // Keep the original year for other cases

        DateTime mappedDate =
            DateTime(mappedYear, originalDate.month, originalDate.day);

        // Skip transactions with dates after today
        if (mappedDate.isAfter(today)) {
          continue;
        }

        date = mappedDate.toIso8601String().split('T').first;
      }

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
    List<String> ibans = widget.accounts
            .where((account) =>
                account.containsKey('IBAN') && account['IBAN'] != null)
            .map((account) => account['IBAN'].toString())
            .toList() ??
        [];

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
          // Dropdown for filtering by IBAN
          Positioned(
            top: 250,
            left: 10,
            right: 10,
            child: Directionality(
              textDirection:
                  TextDirection.rtl, // Ensure dropdown aligns correctly
              child: DropdownButton<String>(
                alignment:
                    AlignmentDirectional.topEnd, // Align dropdown to the right
                isExpanded: true,
                value: selectedIBAN,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Color(0xFF3D3D3D), fontSize: 16),
                dropdownColor:
                    const Color(0xFFFFFFFF), // Set dropdown background color
                underline: Container(
                  height: 2,
                  color: const Color(0xFF2C8C68),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedIBAN = newValue ?? "الكل";
                  });
                },
                items: ["الكل", ...ibans]
                    .map<DropdownMenuItem<String>>((String value) {
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

          Positioned(
            top: 300,
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
          // Bottom Navigation Bar remains the same
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
                              )),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, left: 0),
                    child: buildBottomNavItem(
                        Icons.credit_card, "سجل المعاملات", 1, onTap: () {
                      // Already on Transactions page
                    }),
                  ),
                  buildBottomNavItem(
                      Icons.account_balance_outlined, "الحسابات", 2, onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BanksPage(
                                userName: widget.userName,
                                phoneNumber: widget.phoneNumber,
                                accounts: widget.accounts,
                              )),
                    );
                  }),
                  buildBottomNavItem(Icons.calendar_today, "خطة الإدخار", 3,
                      onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SavingPlanPage(
                                userName: widget.userName,
                                phoneNumber: widget.phoneNumber,
                                accounts: widget.accounts,
                              )),
                    );
                  }),
                ],
              ),
            ),
          ),

          Positioned(
            right: 246,
            top: 785,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF2C8C68), // Point color
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

    // Determine the color of the amount
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
      // Decide based on the category
      const redCategories = [
        'المطاعم',
        'الصحة',
        'التسوق',
        'البقالة',
        'النقل',
        'السفر',
        'المدفوعات الحكومية',
        'الإيجار',
        'القروض',
        'أخرى',
      ];
      amountColor =
          redCategories.contains(category) ? Colors.red : Colors.green;
    }

    Map<String, IconData> categoryIcons = {
      'المطاعم': Icons.restaurant,
      'التعليم': Icons.school,
      'الصحة': Icons.local_hospital,
      'تسوق': Icons.shopping_bag,
      'البقالة': Icons.local_grocery_store,
      'النقل': Icons.directions_bus,
      'السفر': Icons.flight,
      'المدفوعات الحكومية': Icons.account_balance,
      'العمل الخيري': Icons.volunteer_activism,
      'الاستثمار': Icons.trending_up,
      'الإيجار': Icons.home,
      'القروض': Icons.money,
      'الراتب': Icons.account_balance_wallet,
      'التحويلات': Icons.swap_horiz,
      'أخرى': Icons.question_mark,
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
          const SizedBox(width: 10),
          const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF3D3D3D), size: 15),
          const SizedBox(width: 10),
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
          const SizedBox(width: 10),
          Icon(categoryIcon, color: const Color(0xFF3D3D3D), size: 24),
        ],
      ),
    );
  }

  void _showTransactionDetails(
      BuildContext context, Map<String, dynamic> transaction) {
    String accountIban = 'غير معروف';
    for (var account in widget.accounts) {
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

    // Map the date for year modifications
    String date = dateTime.split('T').first;
    if (date != 'غير معروف') {
      DateTime originalDate = DateTime.tryParse(date) ?? DateTime.now();
      int mappedYear = originalDate.year == 2016
          ? 2024
          : originalDate.year == 2017
              ? 2025
              : originalDate.year; // Keep the original year for other cases

      DateTime mappedDate =
          DateTime(mappedYear, originalDate.month, originalDate.day);
      date = mappedDate.toIso8601String().split('T').first;
    }

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
                left: -17,
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
