import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'banks_page.dart';
import 'dart:async';
import 'saving_plan_page.dart';
import 'home_page.dart';
// Import your goal page for navigation
import 'saving_plan_page2.dart';
import 'secure_storage_helper.dart'; // Import the secure storage helper
import 'custom_icons.dart';
import 'package:intl/intl.dart';
import 'chatbot.dart';

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
  String? selectedCategory; // Field to track the selected category
  bool _showNotification = false;
  String _notificationMessage = '';
  Color _notificationColor = Colors.red;

// Show a top notification for 5 seconds
  void showNotification(String message, {Color color = Colors.red}) {
    setState(() {
      _notificationMessage = message;
      _notificationColor = color;
      _showNotification = true;
    });

    // Auto-dismiss after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showNotification = false;
        });
      }
    });
  }

  List<Map<String, dynamic>> getGroupedTransactions() {
    List<Map<String, dynamic>> allTransactions = [];

    for (var account in widget.accounts) {
      // Filter transactions based on IBAN
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

    // Group transactions by date
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in allTransactions) {
      String date =
          transaction['TransactionDateTime']?.split('T').first ?? 'غير معروف';

      if (date != 'غير معروف') {
        DateTime originalDate = DateTime.tryParse(date) ?? DateTime.now();
        int mappedYear = originalDate.year == 2016
            ? 2024
            : originalDate.year == 2017
                ? 2025
                : originalDate.year;

        DateTime mappedDate =
            DateTime(mappedYear, originalDate.month, originalDate.day);

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

    List<Map<String, dynamic>> result = [];
    groupedTransactions.forEach((date, transactions) {
      result.add({'date': date, 'transactions': transactions});
    });

    return result;
  }

  String formatNumberWithArabicComma(dynamic number) {
    if (number == null) return '٠،٠٠';
    try {
      String formattedNumber = NumberFormat("#,##0.00", "ar").format(number);
      return formattedNumber.replaceAll('.', '،');
    } catch (e) {
      return number.toString().replaceAll('.', '،');
    }
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
            child: DropdownButton<String>(
              alignment: AlignmentDirectional.topEnd, // Align to the right
              isExpanded: true,
              value: selectedIBAN,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 16,
              ),
              dropdownColor: const Color(0xFFFFFFFF),
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
                      alignment:
                          Alignment.centerRight, // Align text to the right
                      child: Text(
                        value,
                        textAlign: TextAlign.right, // Ensure right-alignment
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
          // BNavigation bar
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, left: 0),
                    child: buildBottomNavItem(
                        Icons.credit_card, "سجل المعاملات", 1, onTap: () {
                      // Already on Transactions page
                    }),
                  ),
                  buildBottomNavItem(
                    Icons.account_balance_outlined,
                    "الحسابات",
                    2,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              BanksPage(
                            userName: widget.userName,
                            phoneNumber: widget.phoneNumber,
                            accounts: widget.accounts,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  buildBottomNavItem(Icons.calendar_today, "خطة الإدخار", 3,
                      onTap: navigateToSavingPlan),
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
                color: Color(0xFF2C8C68),
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
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              HomePage(
                            userName: widget.userName,
                            phoneNumber: widget.phoneNumber,
                            accounts: widget.accounts,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                ),
                if (_showNotification)
                  Positioned(
                    top: 23,
                    left: 19,
                    child: Container(
                      width: 353,
                      height: 57,
                      decoration: BoxDecoration(
                        color: _notificationColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            // Wrap the Text widget with Expanded so text doesn't overflow
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: Text(
                                _notificationMessage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'GE-SS-Two-Light',
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // ✅ زر الذكاء الاصطناعي (chatbot) في مكان محدد
          Positioned(
            top: 650,
            left: 328,
            child: GestureDetector(
              onTap: navigateToChatbot,
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
                    'assets/images/chatbotIcon.png',
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

  void _showCategorySelection(
      BuildContext context, Map<String, dynamic> transaction) {
    String? dialogSelectedCategory;

    Map<String, IconData> categories = {
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
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF308C64),
          title: Stack(
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'تصنيف العملية',
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
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, setStateDialog) {
              return Container(
                // Limit the total height of the dialog
                constraints: const BoxConstraints(maxHeight: 500),
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Scrollable area with categories
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: categories.entries.map((entry) {
                            final String category = entry.key;
                            final IconData icon = entry.value;

                            final bool isSelected =
                                (dialogSelectedCategory == category);

                            return GestureDetector(
                              onTap: () {
                                setStateDialog(() {
                                  dialogSelectedCategory = category;
                                });
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFA4A4A4)
                                      : const Color(0xFFD9D9D9),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      category,
                                      style: const TextStyle(
                                        fontFamily: 'GE-SS-Two-Light',
                                        fontSize: 16,
                                        color: Color(0xFF3D3D3D),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(icon, color: const Color(0xFF3D3D3D)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () {
                        // If user did NOT choose a category => error
                        if (dialogSelectedCategory == null) {
                          showNotification(
                            "حدث خطأ ما\nلم يتم اختيار تصنيف العملية",
                            color: Colors.red,
                          );
                          return;
                        }

                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                              'تأكيد التصنيف',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: 'GE-SS-Two-Bold',
                                fontSize: 20,
                                color: Color(0xFF3D3D3D),
                              ),
                            ),
                            content: Text(
                              'هل أنت متأكد من تصنيف العملية إلى $dialogSelectedCategory؟',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'GE-SS-Two-Light',
                                fontSize: 16,
                                color: Color(0xFF3D3D3D),
                              ),
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // "إلغاء" button
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // close confirm
                                    },
                                    child: const Text(
                                      'إلغاء',
                                      style: TextStyle(
                                        fontFamily: 'GE-SS-Two-Light',
                                        color: Color(0xFF838383),
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  // "تصنيف" button
                                  TextButton(
                                    onPressed: () async {
                                      // 1) Update the transaction's category
                                      setState(() {
                                        transaction['Category'] =
                                            dialogSelectedCategory!;
                                      });

                                      // 2) Save the entire updated 'widget.accounts'
                                      //    in local storage so other pages also see the new category
                                      // (Make sure you have StorageService accessible in this page)
                                      // e.g.:
                                      // await _storageService.saveAccountDataLocally(widget.phoneNumber, widget.accounts);

                                      // 3) Close both dialogs
                                      Navigator.pop(context); // confirmation
                                      Navigator.pop(
                                          context); // category selection

                                      // 4) Optionally show success
                                      Future.delayed(
                                          const Duration(milliseconds: 200),
                                          () {
                                        showNotification(
                                          "تم تصنيف العملية إلى $dialogSelectedCategory بنجاح",
                                          color: Colors.green,
                                        );
                                      });
                                    },
                                    child: const Text(
                                      'تصنيف',
                                      style: TextStyle(
                                        fontFamily: 'GE-SS-Two-Light',
                                        fontSize: 18,
                                        color: Color(0xFF2C8C68),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3D3D3D),
                        minimumSize: const Size(100, 40),
                      ),
                      child: const Text(
                        'تصنيف',
                        style: TextStyle(
                          color: Color(0xFFD9D9D9),
                          fontFamily: 'GE-SS-Two-Light',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    String amount = formatNumberWithArabicComma(transaction['Amount']);

    String subtype =
        transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
            'غير معروف';
    String category = transaction['Category'] ?? 'غير مصنف';

    // Color transactions
    Color amountColor;
    if (subtype == 'MoneyTransfer' ||
        subtype == 'Withdrawal' ||
        subtype == 'Purchase' ||
        subtype == 'DepositReversal') {
      amountColor = Colors.red; // Outgoing
    } else if (subtype == 'Deposit' ||
        subtype == 'WithdrawalReversal' ||
        subtype == 'Refund') {
      amountColor = Colors.green; // Ingoing
    } else {
      // Based on the category for notApplicable transactions
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

    if (category == 'أخرى') {
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
                      const Icon(
                        CustomIcons.riyal,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        amount,
                        style: const TextStyle(
                          fontFamily: 'GE-SS-Two-Bold',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showCategorySelection(context,
                              transaction); // Show the category selection dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFADADAD),
                          minimumSize: const Size(133, 30),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'هذه العملية لم تصنف',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF404040),
                            fontFamily: 'GE-SS-Two-Light',
                          ),
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
                    Icon(
                      CustomIcons.riyal, // Riyal icon instead of text
                      size: 14,
                      color: amountColor,
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

    String amount = formatNumberWithArabicComma(transaction['Amount']);

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
    if (date != 'غير معروف') {
      DateTime originalDate = DateTime.tryParse(date) ?? DateTime.now();
      int mappedYear = originalDate.year == 2016
          ? 2024
          : originalDate.year == 2017
              ? 2025
              : originalDate.year;

      DateTime mappedDate =
          DateTime(mappedYear, originalDate.month, originalDate.day);
      date = mappedDate.toIso8601String().split('T').first;

      String year = mappedDate.year.toString();
      String month = mappedDate.month.toString().padLeft(2, '0');
      String day = mappedDate.day.toString().padLeft(2, '0');
      date = '$day-$month-$year';
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CustomIcons.riyal, // Riyal symbol
                    size: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(
                      width: 4), // Space between the symbol and amount
                  Text(
                    'المبلغ: $amount',
                    style: const TextStyle(
                      fontFamily: 'GE-SS-Two-Bold',
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
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
              Text(':رقم الآيبان \n $accountIban',
                  textAlign: TextAlign.right,
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
