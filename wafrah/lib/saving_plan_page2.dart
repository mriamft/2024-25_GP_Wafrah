import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'settings_page.dart';
import 'saving_plan_page.dart';
import 'transactions_page.dart';
import 'banks_page.dart';
import 'home_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For secure storage
import 'dart:convert'; // For JSON encoding and decoding
import 'package:intl/intl.dart'; // For date formatting
import 'custom_icons.dart';
import 'dart:ui' as ui;


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
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  int _currentMonthIndex = 0; // Track the selected month
  List<String> months = []; // Dynamically generated months
  List<Map<String, dynamic>> savingsPlan = []; // Savings plan for all months
  Map<String, double> categoryTotalSavings =
      {}; // Store total savings per category
  Map<String, dynamic> wap = {};
  bool isLoading = false;

@override
void initState() {
  super.initState();

  if (widget.resultData.isEmpty || !widget.resultData.containsKey('startDate')) {
    print("Loading saved plan data...");
    _loadPlanFromSecureStorage().then((_) {
      if (widget.resultData.containsKey('startDate')) {
        print("startDate found: ${widget.resultData['startDate']}");
        generateMonths(widget.resultData['DurationMonths']);
        generateSavingsPlan();
      } else {
        print("Error: startDate is still missing after loading from storage.");
      }
    });
  } else {
    print("Using existing resultData");
    generateMonths(widget.resultData['DurationMonths']);
    generateSavingsPlan();
  }

  generateMonths(widget.resultData['DurationMonths']);
  print("result data");
  print(widget.resultData["startDate"]);
  print("resultData Keys: ${widget.resultData.keys}");
  print(widget.accounts);

  _currentMonthIndex = 0; // Ensure "الخطة كاملة" is selected by default

  // Initialize categoryTotalSavings before calling generateSavingsPlan()
  categoryTotalSavings = Map<String, double>.from(widget
      .resultData['CategorySavings']
      .map((key, value) => MapEntry(key, (value as num).toDouble())));

  // Call generateSavingsPlan after categoryTotalSavings is initialized
  setState(() {
    generateSavingsPlan();
  });
    _loadPlanFromSecureStorage(); 
}

String formatNumber(double number) {
  return NumberFormat("#,##0", "ar").format(number);
}


String convertToArabicNumbers(String input) {
  const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return input.replaceAllMapped(RegExp(r'[0-9]'), (match) {
    return arabicNumbers[int.parse(match.group(0)!)];
  });
}


  void generateMonths(dynamic durationMonths) {
    int monthsCount =
        (durationMonths is int) ? durationMonths : durationMonths.toInt();

    months.clear();
    months.add("الخطة كاملة"); // Full Plan at index 0
    months.addAll(List.generate(monthsCount, (index) => "الشهر ${index + 1}"));
  }

  void updateAndSavePlan(Map<String, dynamic> updatedPlan) {
    // Update plan based on your logic
    setState(() {
      // Example: Calculate new savings (you can insert your logic here)
      categoryTotalSavings = updatedPlan['CategorySavings'];
    });

    // Save the updated plan
    _savePlanToSecureStorage(updatedPlan);
  }

Future<void> _savePlanToSecureStorage(Map<String, dynamic> planData) async {
  try {
    // Ensure startDate is saved properly
    if (!planData.containsKey('startDate') || planData['startDate'] == null) {
      print("Warning: startDate is missing in planData. Setting default.");
      planData['startDate'] = widget.resultData['startDate'] ?? DateTime.now().toString();
    }

    print("Saving plan data: $planData"); // Debugging
    String planJson = jsonEncode(planData);
    await secureStorage.write(key: 'savings_plan', value: planJson);
  } catch (e) {
    print("Error saving plan to secure storage: $e");
  }
}

Future<void> _loadPlanFromSecureStorage() async {
  try {
    String? planJson = await secureStorage.read(key: 'savings_plan');
    if (planJson != null) {
      Map<String, dynamic> storedPlan = jsonDecode(planJson);

      setState(() {
        widget.resultData.addAll(storedPlan);

        // Ensure startDate is not null
        if (!widget.resultData.containsKey('startDate') || widget.resultData['startDate'] == null) {
          print("Error: startDate is missing even after loading from storage. Setting default.");
          widget.resultData['startDate'] = DateTime.now().toString();
        }
      });
    } else {
      print('No plan found in secure storage');
    }
  } catch (e) {
    print("Error loading plan from secure storage: $e");
  }
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

  // Track savings progress and store it
  Map<String, dynamic> progressData = (_currentMonthIndex == 0)
      ? trackSavingsProgress()
      : MonthlytrackSavingsProgress();

  print("Savings Progress Data: $progressData");

  // Store progress in state
  setState(() {
    wap = progressData; // Store progress data
  });

  // Save the updated plan to secure storage
  Map<String, dynamic> updatedPlan = {
    'DurationMonths': widget.resultData['DurationMonths'],
    'CategorySavings': categoryTotalSavings,
    'MonthlySavingsPlan': savingsPlan,
    'SavingsGoal': widget.resultData['SavingsGoal'],
    'startDate': widget.resultData['startDate'],
    'discretionaryRatios': widget.resultData['discretionaryRatios'],
  };

  _savePlanToSecureStorage(updatedPlan);
}


  void _updatePlan(Map<String, dynamic> updatedPlan) {
    // Save the updated plan to secure storage
    _savePlanToSecureStorage(updatedPlan);
  }

  List<Widget> buildCategorySquares() {
    return savingsPlan
        .where((saving) =>
            saving['monthlySavings'] > 0) // Hide zero-value categories
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
        _updatePlan({
          'DurationMonths': widget.resultData['DurationMonths'],
          'CategorySavings': categoryTotalSavings,
        }); // Update secure storage after changes
      } else {
        print(" Error: Selected month index out of range");
      }
    });
  }

  void deletePlan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تأكيد حذف الخطة',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'GE-SS-Two-Bold',
            fontSize: 20,
            color: Color(0xFF3D3D3D),
          ),
        ),
        content: const Text(
          'هل أنت متأكد أنك تريد حذف هذه الخطة؟ لن تتمكن من استعادتها لاحقًا.',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'GE-SS-Two-Light',
            fontSize: 16,
            color: Color(0xFF3D3D3D),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
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
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  try {
                    // Call the function to delete the plan from secure storage
                    await _deletePlanFromStorage();

                    // Show success message
                    Flushbar(
                      message: 'تم حذف الخطة بنجاح.',
                      messageText: const Text(
                        'تم حذف الخطة بنجاح.',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'GE-SS-Two-Light',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: const Color(0xFF0FBE7C),
                      duration: const Duration(seconds: 5),
                      flushbarPosition: FlushbarPosition.TOP,
                      margin: const EdgeInsets.all(8.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ).show(context);

                    // Navigate back to SavingPlanPage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SavingPlanPage(
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber,
                          accounts: widget.accounts,
                        ),
                      ),
                    );
                  } catch (e) {
                    // Show failure message if something went wrong
                    Flushbar(
                      message: 'فشل في حذف الخطة. الرجاء المحاولة لاحقًا.',
                      messageText: const Text(
                        'فشل في حذف الخطة. الرجاء المحاولة لاحقًا.',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'GE-SS-Two-Light',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                      flushbarPosition: FlushbarPosition.TOP,
                      margin: const EdgeInsets.all(8.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ).show(context);
                  }
                },
                child: const Text(
                  'حذف الخطة',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Light',
                    fontSize: 18,
                    color: Color(0xFFDD2C35),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

Map<String, dynamic> trackSavingsProgress() {
  DateTime today = DateTime.now();

  // Ensure startDate exists before parsing
  String? rawStartDate = widget.resultData['startDate']?.toString();
  if (rawStartDate == null || rawStartDate.isEmpty) {
    print("Error: startDate is missing or null");
    return {'progress': {}, 'lastYearSpending': {}, 'currentYearSpending': {}};
  }
  DateTime startDate = DateTime.parse(rawStartDate);
  
  int totalMonths = (widget.resultData['DurationMonths'] ?? 0).toInt();
  if (totalMonths == 0) {
    print("Error: DurationMonths is 0 or null");
    return {'progress': {}, 'lastYearSpending': {}, 'currentYearSpending': {}};
  }

  int remainingMonths = totalMonths - today.difference(startDate).inDays ~/ 30;
  if (remainingMonths < 0) remainingMonths = 0; // Ensure no negative values

  // Corrected Last Year's Spending Period (Same Duration as Current)
  DateTime lastYearStart = startDate.subtract(Duration(days: 365));
  DateTime lastYearEnd = lastYearStart.add(Duration(days: totalMonths * 30));

  // Corrected Current Spending Period
  DateTime currentStart = startDate;
  DateTime currentEnd = today;

  // Debugging: Print the expected date ranges
  print("Last Year Period: $lastYearStart to $lastYearEnd");
  print("Current Year Period: $currentStart to $currentEnd");

  Map<String, double> lastYearSpending = {};
  Map<String, double> currentSpending = {};
  Map<String, double> progressPercentage = {};

  // Ensure 'CategorySavings' exists and filter out zero-value categories
  Map<String, double> categorySavings = {};
  if (widget.resultData['CategorySavings'] != null) {
    categorySavings = Map<String, double>.from(widget.resultData['CategorySavings'])
        .map((key, value) => MapEntry(key, (value as num).toDouble()))
        ..removeWhere((key, value) => value == 0.0);
  } else {
    print("Error: CategorySavings is null");
    return {'progress': {}, 'lastYearSpending': {}, 'currentYearSpending': {}};
  }

  for (var account in widget.accounts) {
    for (var transaction in account['transactions']) {
      if (!transaction.containsKey('TransactionDateTime') || 
          !transaction.containsKey('Category') || 
          !transaction.containsKey('Amount')) {
        print("Error: Missing key in transaction: $transaction");
        continue;
      }

      // Debugging: Print transaction details
      //print("Processing Transaction: $transaction");

      DateTime? transactionDate = DateTime.tryParse(transaction['TransactionDateTime']);
      if (transactionDate == null) {
        print("Error: Invalid TransactionDateTime - ${transaction['TransactionDateTime']}");
        continue;
      }

      String category = transaction['Category'] ?? 'Unknown';
      double amount = double.tryParse(transaction['Amount'].toString()) ?? 0.0; 
      String type = transaction['SubTransactionType'] ?? 'Unknown';

      if (!categorySavings.containsKey(category)) {
        //print("Skipping category: $category");
        continue;
      }

      if (amount == 0.0) {
        print("Warning: Amount is zero for transaction: $transaction");
      }

      if (type == 'Withdrawal' || type == 'Purchase' || type == 'Deposit' || type == 'MoneyTransfer') {
        // Last Year's Spending (same period from previous year)
        if (transactionDate.isAfter(lastYearStart.subtract(Duration(days: 1))) &&
            transactionDate.isBefore(lastYearEnd.add(Duration(days: 1)))) {
          //print("Adding to last year spending: $category - Amount: $amount");
          lastYearSpending[category] = (lastYearSpending[category] ?? 0) + amount;
        } 
        // Current Spending (from start date to today)
        else if (transactionDate.isAfter(currentStart.subtract(Duration(days: 1))) &&
                 transactionDate.isBefore(currentEnd.add(Duration(days: 1)))) {
          //print("Adding to current year spending: $category - Amount: $amount");
          currentSpending[category] = (currentSpending[category] ?? 0) + amount;
        }
      }
    }
  }

  for (var category in categorySavings.keys) {
    double savingPerMonth = categorySavings[category]! / totalMonths;
    double totalSavingAmount = savingPerMonth * totalMonths;

    // Corrected Total Savings Progress Formula
    double totalSavingsProgress;

        if (lastYearSpending[category] == 0 && currentSpending[category] == 0) {
      totalSavingsProgress = savingPerMonth * remainingMonths;  
    } else {
       totalSavingsProgress = ((lastYearSpending[category] ?? 0) - (currentSpending[category] ?? 0)) - 
        ((totalSavingAmount / totalMonths) * remainingMonths);
    }

    // Updated Progress Percentage Formula
    double progressPercentageValue = (totalSavingAmount == 0) ? 0 : (totalSavingsProgress / totalSavingAmount) * 100;

    progressPercentage[category] = progressPercentageValue;
  }

  return {
    'progress': progressPercentage,
    'lastYearSpending': lastYearSpending,
    'currentYearSpending': currentSpending
  };
}

Map<String, dynamic> MonthlytrackSavingsProgress() {
  DateTime today = DateTime.now();

  // Ensure startDate exists before parsing
  String? rawStartDate = widget.resultData['startDate']?.toString();
  if (rawStartDate == null || rawStartDate.isEmpty) {
    print("Error: startDate is missing or null");
    return {'progress': {}, 'lastYearSpending': {}, 'currentYearSpending': {}};
  }
  DateTime startDate = DateTime.parse(rawStartDate);
  
  int totalMonths = (widget.resultData['DurationMonths'] ?? 0).toInt();
  if (totalMonths == 0) {
    print("Error: DurationMonths is 0 or null");
    return {'progress': {}, 'lastYearSpending': {}, 'currentYearSpending': {}};
  }

  // Determine the start and end dates of the selected month
  DateTime selectedMonthStart = startDate.add(Duration(days: (_currentMonthIndex - 1) * 30));
  DateTime selectedMonthEnd = selectedMonthStart.add(Duration(days: 29));

  // Correct Last Year's Spending Period (Same Month, One Year Earlier)
  DateTime lastYearStart = selectedMonthStart.subtract(Duration(days: 365));
  DateTime lastYearEnd = selectedMonthEnd.subtract(Duration(days: 365));

  // Correct Current Year Spending Period
  DateTime currentStart = selectedMonthStart;
  DateTime currentEnd = selectedMonthEnd.isBefore(today) ? selectedMonthEnd : today;

  // Debugging: Print the expected date ranges
  print("Last Year Period: $lastYearStart to $lastYearEnd");
  print("Current Year Period: $currentStart to $currentEnd");

  // Check if the selected month is in the future
  if (selectedMonthStart.isAfter(today)) {
    print("The selected month ($_currentMonthIndex) is in the future. Returning 0% progress.");
    return {
      'progress': {for (var key in widget.resultData['CategorySavings'].keys) key: 0.0},
      'lastYearSpending': {},
      'currentYearSpending': {}
    };
  }

  // Get remaining days in the selected month
  int remainingDays = selectedMonthEnd.difference(today).inDays;
  if (remainingDays == 0) remainingDays = 1;
  if (remainingDays < 0) remainingDays = 0;  // Ensure no negative values

  Map<String, double> lastYearSpending = {};
  Map<String, double> currentSpending = {};
  Map<String, double> progressPercentage = {};

  // Ensure 'CategorySavings' exists and filter out zero-value categories
  Map<String, double> categorySavings = {};
  if (widget.resultData['CategorySavings'] != null) {
    categorySavings = Map<String, double>.from(widget.resultData['CategorySavings'])
        .map((key, value) => MapEntry(key, (value as num).toDouble()))
        ..removeWhere((key, value) => value == 0.0);
  } else {
    print("Error: CategorySavings is null");
    return {'progress': {}, 'lastYearSpending': {}, 'currentYearSpending': {}};
  }

  for (var account in widget.accounts) {
    for (var transaction in account['transactions']) {
      
      if (!transaction.containsKey('TransactionDateTime') || 
          !transaction.containsKey('Category') || 
          !transaction.containsKey('Amount')) {
        print("Error: Missing key in transaction: $transaction");
        continue;
      }

      DateTime? transactionDate = DateTime.tryParse(transaction['TransactionDateTime']);
      if (transactionDate == null) {
        print("Error: Invalid TransactionDateTime - ${transaction['TransactionDateTime']}");
        continue;
      }

      String category = transaction['Category'] ?? 'Unknown';
      double amount = double.tryParse(transaction['Amount'].toString()) ?? 0.0; 
      String type = transaction['SubTransactionType'] ?? 'Unknown';

      if (!categorySavings.containsKey(category)) {
        continue;  // Skip categories not in savings plan
      }

      if (amount == 0.0) {
        print("Warning: Amount is zero for transaction: $transaction");
      }

      if (type == 'Withdrawal' || type == 'Purchase' || type == 'Deposit' || type == 'MoneyTransfer') {
        // Last Year's Spending (Same Month One Year Ago)
        if (transactionDate.isAfter(lastYearStart.subtract(Duration(days: 1))) &&
            transactionDate.isBefore(lastYearEnd.add(Duration(days: 1)))) {
          lastYearSpending[category] = (lastYearSpending[category] ?? 0) + amount;
        } 
        // Current Spending (Selected Month of Current Year)
        else if (transactionDate.isAfter(currentStart.subtract(Duration(days: 1))) &&
                 transactionDate.isBefore(currentEnd.add(Duration(days: 1)))) {
          currentSpending[category] = (currentSpending[category] ?? 0) + amount;
        }
      }
      
    }
  }

  print("Current spending for السفر: ${currentSpending['السفر']}");
  print("Last year spending for السفر: ${lastYearSpending['السفر']}");

  for (var category in categorySavings.keys) {
    double savingPerMonth = categorySavings[category]! / totalMonths;
    double savingPerDay = savingPerMonth / 30;

    double daysFactor = remainingDays / 30.0;  

    double lastYearValue = lastYearSpending[category] ?? 0;
    double currentYearValue = currentSpending[category] ?? 0;

    double savingsProgress;

    // Debugging for السفر category
    if (category == 'السفر') {
      print("Category: السفر");
      print("Last Year Spending: $lastYearValue");
      print("Current Year Spending: $currentYearValue");
    }

    if (lastYearValue == 0 && currentYearValue == 0) {
      savingsProgress = savingPerDay * remainingDays;  
      if (category == 'السفر'){ print("Case: No spending in both years");
      print("savingPerDay: $savingPerDay");
      print("daysFactor: $daysFactor");
      print("savingsProgress: $savingsProgress");
      }
    } else if (lastYearValue == 0) {
      savingsProgress = (-currentYearValue) - (savingPerDay * daysFactor);
      if (category == 'السفر') print("Case: No last year spending");
    } else {
      savingsProgress = (lastYearValue - currentYearValue) - (savingPerDay * daysFactor);
      if (category == 'السفر') print("Case: Normal case (Both years have spending)");
    }

    double progressPercentageValue = (savingPerDay == 0) ? 0 : (savingsProgress / savingPerDay) * 100;
    if (category == 'السفر')
    print("progressPercentageValue: $progressPercentageValue");
    if (progressPercentageValue < 0) progressPercentageValue = 0;

    progressPercentage[category] = progressPercentageValue;
  }

  return {
    'progress': progressPercentage,
    'lastYearSpending': lastYearSpending,
    'currentYearSpending': currentSpending
  };
}

  Future<void> _deletePlanFromStorage() async {
    try {
      await secureStorage.delete(key: 'savings_plan');
      setState(() {
        savingsPlan.clear(); // Clear the plan from the UI
      });
    } catch (e) {
      print("Error deleting plan from storage: $e");
    }
  }

  Widget buildDeleteButton() {
    return Positioned(
      top: 190, // Adjust the position as needed
      right: 310,
      child: GestureDetector(
        onTap: deletePlan,
        child: Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(
            color: Color(0xFFF9F9F9), // Green color
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.delete,
            color: Color(0xFFEB5757),
            size: 30,
          ),
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  DateTime today = DateTime.now();
  DateTime startDate = DateTime.parse(widget.resultData['startDate']);

  // Calculate remaining months (same logic as trackSavingsProgress)
  int totalMonths = (widget.resultData['DurationMonths'] ?? 0).toInt();
  int elapsedMonths = today.difference(startDate).inDays ~/ 30;
  int remainingMonths = (totalMonths - elapsedMonths).clamp(0, totalMonths);

  // Calculate remaining days for the current month (same logic as MonthlytrackSavingsProgress)
  DateTime selectedMonthStart = startDate.add(Duration(days: (_currentMonthIndex - 1) * 30));
  DateTime selectedMonthEnd = selectedMonthStart.add(Duration(days: 29));
  int remainingDays = selectedMonthEnd.difference(today).inDays.clamp(0, 30);

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

        // Show remaining months when "الخطة كاملة" is selected
        if (_currentMonthIndex == 0)
          Positioned(
            top: 130,
            left: 75,
            child: Text(
              'الأشهر المتبقية لإتمام الخطة: ${convertToArabicNumbers(remainingMonths.toString())}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
                color: Colors.white,
              ),
            ),
          ),

// Show remaining days when a specific month is selected and not in the future
if (_currentMonthIndex != 0 && !selectedMonthStart.isAfter(today))
  Positioned(
    top: 130,
    left: 16,
    child: Text(
      'الأيام المتبقية لإتمام الشهر الحالي من الخطة: ${convertToArabicNumbers(remainingDays.toString())}',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'GE-SS-Two-Bold',
        color: Colors.white,
      ),
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
          buildDeleteButton(),

        // Dropdown for month selection
        Positioned(
          top: 230,
          left: 4,
          child: Container(
            width: 380,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: months[_currentMonthIndex],
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Color(0xFF3D3D3D), fontSize: 16),
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
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
const Positioned(
  left: 25,
  top: 275,
  child: Text(
    'بعد إنشاء خطة الادخار، سيكون التقدم دائمًا ١٠٠٪، إلا إذا تم الإنفاق بشكل زائد\n'
    'في حال تم الإنفاق الزائد في فئة معينة، ستظهر رسالة تحذيرية في مربع هذه الفئة\n',
    style: TextStyle(
      color: Color(0xFF3D3D3D),
      fontSize: 10,
      fontFamily: 'GE-SS-Two-Light',
    ),
    textAlign: TextAlign.right,
  ),
),


          Positioned(
            top: 305,
            left: 10,
            right: 10,
            child: SizedBox(
              height: 410, // Set a larger height for the scrollable area
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
                              accounts: widget.accounts),
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
    'الخطة كامله': Icons.check_circle,
  };

  IconData categoryIcon = categoryIcons[category] ?? Icons.help_outline;

  // Get the original progress without modification
  double originalProgress = wap['progress']?[category] ?? 0.0;

  // Apply the 100% cap after storing the original value
  double progress = originalProgress > 100 ? 100 : originalProgress;

  // Determine if the selected month is in the future
  DateTime today = DateTime.now();
  DateTime startDate = DateTime.parse(widget.resultData['startDate']);
  DateTime selectedMonthDate = startDate.add(Duration(days: (_currentMonthIndex - 1) * 30));

  bool isFutureMonth = selectedMonthDate.isAfter(today);

  return Container(
    width: 110,
    height: 135, // Fixed height
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
        // ✅ Show Alert Box only if the month is not in the future and progress is ≤ 100%
        if (!isFutureMonth && originalProgress <= 100.0)
          Positioned(
            top: 5,
            right: 5, // Align to the right
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color.fromARGB(222, 247, 89, 78), // Red background
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "تنبيه",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'GE-SS-Two-Light',
                  color: Colors.white, // White text
                ),
              ),
            ),
          ),

        // ❌ Remove Percentage Display for Future Months
        if (!isFutureMonth)
          Positioned(
            top: 10,
            right: 70, // Align to the right
            child: Text(
              "%${convertToArabicNumbers(formatNumber(progress))}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

        // Circular Progress Bar with Icon
        Positioned(
          top: 18,
          left: 10,
          child: SizedBox(
            width: 45,
            height: 45,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: isFutureMonth ? 0 : (progress > 0 ? progress / 100 : 0.01),
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(isFutureMonth ? Colors.grey.shade300 : const Color(0xFF2C8C68)),
                  strokeWidth: 6,
                ),
                Icon(
                  categoryIcon,
                  color: const Color(0xFF2C8C68),
                  size: 22,
                ),
              ],
            ),
          ),
        ),

        // Category Name
        Positioned(
          top: 50,
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
          right: 10,
          child: Directionality(
            textDirection: ui.TextDirection.rtl, // Ensure proper Arabic text alignment
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align text properly
              children: [
                const Text(
                  "المبلغ المطلوب ادخاره:",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'GE-SS-Two-Light',
                    color: Color(0xFF3D3D3D),
                  ),
                ),
                const SizedBox(height: 2), // Add spacing between text and amount
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatNumber(monthlySavings), 
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'GE-SS-Two-Light',
                        color: Color(0xFF3D3D3D),
                      ),
                    ),
                    const SizedBox(width: 3), // Space between amount and icon
                    Icon(
                      CustomIcons.riyal, // Riyal symbol
                      size: 14,
                      color: Color(0xFF3D3D3D),
                    ),
                  ],
                ),
              ],
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