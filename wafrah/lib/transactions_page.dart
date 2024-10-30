import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'banks_page.dart';
import 'saving_plan_page.dart';
import 'home_page.dart';

class TransactionsPage extends StatelessWidget {
  final String userName;
  final String phoneNumber;
  final List<Map<String, dynamic>> accounts; // Optional accounts

  const TransactionsPage({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts =
        const [], // Default to an empty list if no accounts are provided
  });

  // Function to extract and sort all transactions from connected accounts
  List<Map<String, dynamic>> getAllTransactions() {
    List<Map<String, dynamic>> allTransactions = [];

    for (var account in accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        allTransactions.add(transaction);
      }
    }

    // Sort transactions by date (most recent to oldest)
    allTransactions.sort((a, b) {
      String dateA = a['TransactionDateTime'] ?? '';
      String dateB = b['TransactionDateTime'] ?? '';

      DateTime dateTimeA = DateTime.tryParse(dateA) ?? DateTime.now();
      DateTime dateTimeB = DateTime.tryParse(dateB) ?? DateTime.now();

      // Sort in descending order, most recent first
      return dateTimeB.compareTo(dateTimeA);
    });

    return allTransactions;
  }

  @override
  Widget build(BuildContext context) {
    // Get all transactions sorted by date
    List<Map<String, dynamic>> allTransactions = getAllTransactions();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Background color
      body: Stack(
        children: [
          // Green square image
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

          // Title
          const Positioned(
            top: 185,
            right: 12,
            child: Text(
              'سجل المعاملات',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold', // Ensure same font as the project
              ),
            ),
          ),

          // Transactions List or No Transactions Message
          Positioned(
            top: 240,
            left: 10,
            right: 10,
            bottom:
                90, // Added bottom padding to make space for the navigation bar
            child: allTransactions.isEmpty
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
                    // Use ListView.builder for better scrolling with large datasets
                    itemCount: allTransactions.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(allTransactions[index]);
                    },
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
                                accounts: accounts, // Pass accounts
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
                                accounts: accounts, // Pass accounts
                              )),
                    );
                  }),
                ],
              ),
            ),
          ),
           Positioned(

            right: 225,

            top: 762,

            child: Container(

              width: 6,

              height: 6,

              decoration: BoxDecoration(

                color: Color(0xFF2C8C68), // Point color

                shape: BoxShape.circle,

              ),

            ),

          ),

          // Circular Button for Banks Page
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
                            accounts: accounts, // Pass the accounts data here
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
    // Extract the necessary data
    String dateTime = transaction['TransactionDateTime'] ?? '';
    String date = dateTime.split('T').first; // Only get the date part

    String subtype =
        transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
            'غير معروف'; // Remove KSAOB.

    // Transaction amount
    String amount = transaction['Amount']?['Amount'] ?? '0.00';

    // Translate transaction subtype to Arabic
    Map<String, String> transactionTypeTranslations = {
      'MoneyTransfer': 'تحويل مالي',
      'WithdrawalReversal': 'سحب عكسي',
      'Withdrawal': 'سحب مبلغ',
      'Deposit': 'إيداع',
      'NotApplicable': 'غير محدد',
      'Purchase': 'شراء بضاعة',
      'Refund': 'إعادة مبلغ',
      'DepositReversal': 'إيداع عكسي',
      'Reversal': 'عملية عكسية',
    };
    String translatedSubtype = transactionTypeTranslations[subtype] ?? subtype;

    // Determine the color based on the translated subtype
    Color amountColor;
    if (translatedSubtype == 'تحويل مالي' ||
        translatedSubtype == 'سحب مبلغ' ||
        translatedSubtype == 'شراء بضاعة' ||
        translatedSubtype == 'إيداع عكسي') {
      amountColor = Colors.red; // Red color for these transaction types
    } else if (translatedSubtype == 'إيداع' ||
        translatedSubtype == 'سحب عكسي' ||
        translatedSubtype == 'إعادة مبلغ') {
      amountColor = Colors.green; // Green color for these transaction types
    } else if (translatedSubtype == 'عملية عكسية' ||
        translatedSubtype == 'غير محدد') {
      amountColor = Colors.black; // Black color for these transaction types
    } else {
      amountColor = const Color(
          0xFF3D3D3D); // Default color (same as used for other texts)
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'التاريخ: $date',
                  style: const TextStyle(
                    color: Color(0xFF3D3D3D),
                    fontSize: 14,
                    fontFamily: 'GE-SS-Two-Bold',
                  ),
                ),
                Text(
                  'نوع العملية: $translatedSubtype', // Translated transaction subtype
                  style: const TextStyle(
                    color: Color(0xFF3D3D3D),
                    fontSize: 14,
                    fontFamily: 'GE-SS-Two-Light',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ر.س',
                    style: TextStyle(
                      color: amountColor, // Dynamically set the color
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'GE-SS-Two-Bold',
                    ),
                  ),
                  const SizedBox(
                      width:
                          4), // Add a small space between "ر.س" and the amount
                  Text(
                    amount,
                    style: TextStyle(
                      color: amountColor, // Dynamically set the color
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'GE-SS-Two-Bold',
                    ),
                  ),
                ],
              ),
            ],
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
