import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'settings_page.dart';
import 'saving_plan_page.dart';
import 'transactions_page.dart';
import 'banks_page.dart';
import 'package:flutter/foundation.dart';
import 'home_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; 
import 'dart:convert'; 
import 'package:intl/intl.dart'; 
import 'custom_icons.dart';
import 'dart:ui' as ui;
import 'main.dart';
import 'notification_service.dart';
import 'chatbot.dart';
import 'global_notification_manager.dart';
import 'package:http/http.dart' as http;

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
  late List<List<Map<String, dynamic>>> _monthlyPlans;
  late List<List<Map<String, Object>>> _monthlyRecommendedBudgets;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  Map<String, Map<int, int>> sentNotifications = {};
  int lastNotifiedMonth =
      0; 

  int _currentMonthIndex = 0; 
  List<String> months = []; 
  List<Map<String, dynamic>> savingsPlan = []; 
  Map<String, double> categoryTotalSavings = {}; 
  Map<String, dynamic> wap = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    NotificationService.init((String? payload) {
      if (payload != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => SavingPlanPage2(
              userName: widget.userName,
              phoneNumber: widget.phoneNumber,
              resultData: widget.resultData,
              accounts: widget.accounts,
            ),
          ),
        );
      }
    });

    _setupPlan();

    _loadPlanFromSecureStorage().then((_) {
      _setupPlan();
    });
  }

  void _setupPlan() {

    generateMonths(widget.resultData['DurationMonths']);
    final raw = widget.resultData['Schedule'];
    late List<Map<String, dynamic>> scheduleList;

    if (raw is List) {
      scheduleList = raw.cast<Map<String, dynamic>>();
    } else if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        scheduleList = decoded is List
            ? decoded.cast<Map<String, dynamic>>()
            : <Map<String, dynamic>>[];
      } catch (_) {
        scheduleList = <Map<String, dynamic>>[];
      }
    } else {
      scheduleList = <Map<String, dynamic>>[];
    }

    final Map<String, Map<String, double>> buckets = {};
    final Map<String, Map<String, double>> recBudgetBuckets = {};

    for (var entry in scheduleList) {
      final date = entry['CycleDate'] as String;
      final cat = entry['Category'] as String;
      final amt = (entry['SavingAmount'] as num).toDouble();
      final rec = (entry['RecommendedBudget'] as num).toDouble();

      buckets.putIfAbsent(date, () => {})[cat] = amt;
      recBudgetBuckets.putIfAbsent(date, () => {})[cat] = rec;
    }

    categoryTotalSavings = {};
    for (var monthMap in buckets.values) {
      monthMap.forEach((cat, amt) {
        categoryTotalSavings[cat] = (categoryTotalSavings[cat] ?? 0) + amt;
      });
    }

    _monthlyPlans = [];
    _monthlyPlans.add(
      categoryTotalSavings.entries
          .where((e) => e.value > 0)
          .map((e) => {
                'category': e.key,
                'monthlySavings': e.value,
              })
          .toList(),
    );

    final sortedDates = buckets.keys.toList()..sort();
    for (var date in sortedDates) {
      final m = buckets[date]!;
      _monthlyPlans.add(
        m.entries
            .where((e) => e.value > 0)
            .map((e) => {
                  'category': e.key,
                  'monthlySavings': e.value,
                })
            .toList(),
      );
    }

    _monthlyRecommendedBudgets = [];

    final Map<String, double> totalRec = {};
    for (var monthMap in recBudgetBuckets.values) {
      monthMap.forEach((cat, recAmt) {
        totalRec[cat] = (totalRec[cat] ?? 0) + recAmt;
      });
    }
    _monthlyRecommendedBudgets.add(
      totalRec.entries
          .where((e) => e.value > 0)
          .map((e) => {
                'category': e.key,
                'recBudget': e.value,
              })
          .toList(),
    );

    for (var date in sortedDates) {
      final mRec = recBudgetBuckets[date]!;
      _monthlyRecommendedBudgets.add(
        mRec.entries
            .where((e) => e.value > 0)
            .map((e) => {
                  'category': e.key,
                  'recBudget': e.value,
                })
            .toList(),
      );
    }

    setState(() {
      generateSavingsPlan();
    });
    GlobalNotificationManager().updateData(
      resultData: widget.resultData,
      accounts: widget.accounts,
    );
    GlobalNotificationManager().start();
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
    months.add("الخطة كاملة"); 
    months.addAll(List.generate(monthsCount, (index) => "الشهر ${index + 1}"));
  }

  void updateAndSavePlan(Map<String, dynamic> updatedPlan) {
    setState(() {
      categoryTotalSavings = updatedPlan['CategorySavings'];
    });

    _savePlanToSecureStorage(updatedPlan);
  }

  Future<void> _savePlanToSecureStorage(Map<String, dynamic> planData) async {
    try {
      final existingJson = await secureStorage.read(key: 'savings_plan');
      final Map<String, dynamic> existing = existingJson != null
          ? jsonDecode(existingJson) as Map<String, dynamic>
          : {};

      existing.addAll(planData);

      if (!existing.containsKey('startDate') || existing['startDate'] == null) {
        existing['startDate'] =
            widget.resultData['startDate'] ?? DateTime.now().toString();
      }

      await secureStorage.write(
        key: 'savings_plan',
        value: jsonEncode(existing),
      );
      print("Merged & saved plan: $existing");
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
          if (!widget.resultData.containsKey('startDate') ||
              widget.resultData['startDate'] == null) {
            print( "Error: startDate is missing even after loading from storage. Setting default.");
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

  String getArabicMonth(int month) {
    switch (month) {
      case 1:
        return "الأول";
      case 2:
        return "الثاني";
      case 3:
        return "الثالث";
      case 4:
        return "الرابع";
      case 5:
        return "الخامس";
      case 6:
        return "السادس";
      case 7:
        return "السابع";
      case 8:
        return "الثامن";
      case 9:
        return "التاسع";
      case 10:
        return "العاشر";
      case 11:
        return "الحادي عشر";
      case 12:
        return "الثاني عشر";
      default:
        return "الشهر $month"; 
    }
  }

  void generateSavingsPlan() {
    savingsPlan = _monthlyPlans[_currentMonthIndex];

    final progressData = (_currentMonthIndex == 0)
        ? trackSavingsProgress()
        : MonthlytrackSavingsProgress();
    setState(() => wap = progressData);

    _savePlanToSecureStorage({
      'DurationMonths': widget.resultData['DurationMonths'],
      'CategorySavings': categoryTotalSavings,
      'MonthlySavingsPlan': savingsPlan,
      'SavingsGoal': widget.resultData['SavingsGoal'],
      'startDate': widget.resultData['startDate'],
      'discretionaryRatios': widget.resultData['discretionaryRatios'],
      'Schedule': widget.resultData['Schedule'], 
    });
  }

  void showProgressNotification(Map<String, dynamic> progressData) {
    progressData['progress'].forEach((category, progress) {
      if (progress >= 50 && progress < 75) {
        NotificationService.showNotification(
          title: "أنت في منتصف الطريق!",
          body: "لقد أكملت 50% من هدفك. استمر في العمل!",
        );
      } else if (progress >= 75 && progress < 100) {
        NotificationService.showNotification(
          title: "أنت قريب جدًا من الهدف!",
          body: "لقد أكملت اكثر من 75% من هدفك. قريبًا ستصل!",
        );
      } else if (progress == 100) {
        NotificationService.showNotification(
          title: "تم الادخار بنجاح!",
          body: "لقد أكملت هدف الادخار الخاص بك. تهانينا!",
        );
      }
    });
  }

  void showMonthProgressNotification() {
    DateTime today = DateTime.now();
    DateTime startDate = DateTime.parse(widget.resultData['startDate']);
    int totalMonths = widget.resultData['DurationMonths'].toInt();

    // Calculate days passed and determine which plan month we're in (each month = 30 days)
    int daysPassed = today.difference(startDate).inDays;
    int monthsPassed = daysPassed ~/ 30;

    // If less than one full 30-day period has passed, do nothing.
    if (daysPassed < 30) return;

    // If daysPassed is exactly divisible by 30 (i.e. end of a plan month),
    // and we haven't already sent a notification for this month, then send it.
    if (daysPassed % 30 == 0 &&
        monthsPassed <= totalMonths &&
        monthsPassed > lastNotifiedMonth) {
      NotificationService.showNotification(
        title: "لقد أكملت الشهر $monthsPassed من $totalMonths شهور من الخطة",
        body:
            "في هذا الشهر أنجزت ${(monthsPassed / totalMonths * 100).toStringAsFixed(2)}% من الخطة. استمر في العمل!",
      );
      // Update state so we don't resend for this period
      setState(() {
        lastNotifiedMonth = monthsPassed;
      });
    }
  }

  Future<void> showNotificationsSequentially(
      List<Map<String, String>> notifications) async {
    for (int i = 0; i < notifications.length; i++) {
      // Show the notification at index i
      await NotificationService.showNotification(
        title: notifications[i]['title']!,
        body: notifications[i]['body']!,
      );

      // Wait for 2 seconds before showing the next notification
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void checkFullPlanCompletion() {
    // Check if the user has completed the full plan (last month)
    if (_currentMonthIndex == months.length - 1) {
      double totalSavings =
          categoryTotalSavings.values.fold(0.0, (prev, curr) => prev + curr);
      double savingsGoal = widget.resultData['SavingsGoal'];

      if (totalSavings >= savingsGoal) {
        // User achieved the savings goal
        NotificationService.showNotification(
          title: "تمت الخطة بنجاح!",
          body: "لقد أكملت هدف الإدخار الخاص بك. تهانينا!",
        );
      } else {
        // User did not achieve the savings goal
        NotificationService.showNotification(
          title: "انتهت مدة الخطة",
          body:
              "لقد انتهت مدة الخطة ولكن لم تصل إلى الهدف المحدد. استمر في المحاولة!",
        );
      }
    }
  }

  void _updatePlan(Map<String, dynamic> updatedPlan) {
    _savePlanToSecureStorage(updatedPlan);
  }

  List<Widget> buildCategorySquares() {
    return savingsPlan
        .where((saving) =>
            saving['monthlySavings'] > 0) 
        .map((saving) {
      return SizedBox(
        width: (MediaQuery.of(context).size.width / 2) - 40,
        child: buildCategorySquare(
          saving['category'],
          saving['monthlySavings'], 
        ),
      );
    }).toList();
  }

  void _onMonthChanged(String? newMonth) {
    setState(() {
      int newIndex = months.indexOf(newMonth!);
      if (newIndex >= 0 && newIndex < months.length) {
        _currentMonthIndex = newIndex;
        generateSavingsPlan(); 
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
                    await _deletePlanFromStorage();
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
    final recBudgetList = _monthlyRecommendedBudgets[0]; 
    final Map<String, double> recBudgetMap = {
      for (var item in recBudgetList)
        item['category'] as String: (item['recBudget'] as num).toDouble()
    };

    DateTime today = DateTime.now();
    DateTime startDate = DateTime.parse(widget.resultData['startDate']);
    int totalMonths = (widget.resultData['DurationMonths'] ?? 0).toInt();
    int totalDays =
        totalMonths * 30; 

    DateTime lastYearStart = startDate.subtract(const Duration(days: 365));
    DateTime lastYearEnd = lastYearStart.add(Duration(days: totalDays));

    Map<String, double> lastYearSpending = {};
    Map<String, double> currentSpending = {};
    Map<String, double> progressPercentage = {};

    Map<String, double> categorySavings =
        Map<String, double>.from(widget.resultData['CategorySavings'])
            .map((key, value) => MapEntry(key, (value as num).toDouble()));

    for (var account in widget.accounts) {
      for (var transaction in account['transactions']) {
        DateTime transactionDate =
            DateTime.parse(transaction['TransactionDateTime']);
        String category = transaction['Category'] ?? 'Unknown';
        double amount = double.parse(transaction['Amount'].toString());

        if (transactionDate.isAfter(startDate) &&
            transactionDate.isBefore(today)) {
          currentSpending[category] = (currentSpending[category] ?? 0) + amount;
        }
      }
    }

    int daysPassed = today
        .difference(startDate)
        .inDays
        .clamp(0, totalDays); 
    double dailyProgressGrowth = 100 / totalDays; 

    for (var category in categorySavings.keys) {
      double progress = daysPassed * dailyProgressGrowth; 
      // If spending increased compared to the recommended budjet, reset progress to 0
      if ((currentSpending[category] ?? 0) >
          (recBudgetMap[category] ?? double.infinity)) {
        progress = 0;
      }

      progressPercentage[category] =
          progress.clamp(0, 100); 
    }

    return {'progress': progressPercentage};
  }

  Map<String, dynamic> MonthlytrackSavingsProgress() {
    final recBudgetList =
        _monthlyRecommendedBudgets[_currentMonthIndex]; 
    final Map<String, double> recBudgetMap = {
      for (var item in recBudgetList)
        item['category'] as String: (item['recBudget'] as num).toDouble()
    };

    DateTime today = DateTime.now();
    DateTime startDate = DateTime.parse(widget.resultData['startDate']);
    DateTime selectedMonthStart =
        startDate.add(Duration(days: (_currentMonthIndex - 1) * 30));
    DateTime selectedMonthEnd =
        selectedMonthStart.add(const Duration(days: 29));
    DateTime lastYearStart =
        selectedMonthStart.subtract(const Duration(days: 365));
    DateTime lastYearEnd = selectedMonthEnd.subtract(const Duration(days: 365));

    Map<String, double> lastYearSpending = {};
    Map<String, double> currentSpending = {};
    Map<String, double> progressPercentage = {};

    Map<String, double> categorySavings =
        Map<String, double>.from(widget.resultData['CategorySavings'])
            .map((key, value) => MapEntry(key, (value as num).toDouble()));

    for (var account in widget.accounts) {
      for (var transaction in account['transactions']) {
        DateTime transactionDate =
            DateTime.parse(transaction['TransactionDateTime']);
        String category = transaction['Category'] ?? 'Unknown';
        double amount = double.parse(transaction['Amount'].toString());

        if (transactionDate.isAfter(selectedMonthStart) &&
            transactionDate.isBefore(today)) {
          currentSpending[category] = (currentSpending[category] ?? 0) + amount;
        }
      }
    }

    int daysPassed = today
        .difference(selectedMonthStart)
        .inDays
        .clamp(0, 30); 
    double dailyProgressGrowth = 100 / 30; // 3.33% per day

    for (var category in categorySavings.keys) {
      double progress = daysPassed * dailyProgressGrowth;

      // If spending increased compared to the recommended budjet, reset progress to 0
      if ((currentSpending[category] ?? 0) >
          (recBudgetMap[category] ?? double.infinity)) {
        progress = 0;
      }

      progressPercentage[category] =
          progress.clamp(0, 100); 
    }
    return {'progress': progressPercentage};
  }

  Color getProgressColor(double progress) {
    if (progress < 50) return Colors.red;
    if (progress < 75) return Colors.orange;
    return const Color(0xFF2C8C68); 
  }

  Future<void> _deletePlanFromStorage() async {
    try {
      await secureStorage.delete(key: 'savings_plan');
      setState(() {
        savingsPlan.clear(); 
      });
    } catch (e) {
      print("Error deleting plan from storage: $e");
    }
  }

  Widget buildDeleteButton() {
    return Positioned(
      top: 190, 
      right: 310,
      child: GestureDetector(
        onTap: deletePlan,
        child: Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(
            color: Color(0xFFF9F9F9),
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
    int totalMonths = (widget.resultData['DurationMonths'] ?? 0).toInt();
    int elapsedMonths = today.difference(startDate).inDays ~/ 30;
    int remainingMonths = (totalMonths - elapsedMonths).clamp(0, totalMonths);

    DateTime selectedMonthStart =
        startDate.add(Duration(days: (_currentMonthIndex - 1) * 30));
    DateTime selectedMonthEnd =
        selectedMonthStart.add(const Duration(days: 29));

    int daysPassed = today.difference(selectedMonthStart).inDays.clamp(0, 30);
    int remainingDays =
        (30 - daysPassed).clamp(0, 30); 
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
          if (_currentMonthIndex == 0)
            Positioned(
              top: 130,
              left: 95,
              child: Text(
                'متبقي ${convertToArabicNumbers(remainingMonths.toString())} شهر لإتمام الخطة',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'GE-SS-Two-Bold',
                  color: Colors.white,
                ),
              ),
            ),
          if (_currentMonthIndex != 0 && !selectedMonthStart.isAfter(today))
            Positioned(
              top: 130,
              left: 95,
              child: Text(
                'متبقي ${convertToArabicNumbers(remainingDays.toString())} يوم لإتمام الشهر',
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
            top: 290,
            left: 10,
            right: 10,
            child: SizedBox(
              height: 410,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Wrap(
                      spacing: 27,
                      runSpacing: 30,
                      children: buildCategorySquares(),
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
                  buildBottomNavItem(
                    Icons.settings_outlined,
                    "إعدادات",
                    0,
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
                    },
                  ),
                  buildBottomNavItem(
                    Icons.credit_card,
                    "سجل المعاملات",
                    1,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              TransactionsPage(
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
              ],
            ),
          ),
          Positioned(
            left: 338,
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
    double originalProgress = wap['progress']?[category] ?? 0.0;
    double progress = originalProgress.clamp(0, 100);
    DateTime today = DateTime.now();
    DateTime startDate = DateTime.parse(widget.resultData['startDate']);
    DateTime selectedMonthStart =
        startDate.add(Duration(days: (_currentMonthIndex - 1) * 30));
    bool isFutureMonth = selectedMonthStart.isAfter(today);

    final recList = _monthlyRecommendedBudgets[_currentMonthIndex];
    final found = recList.firstWhere(
      (e) => e['category'] == category,
      orElse: () => <String, Object>{'recBudget': 0.0},
    );
    double recBudget = (found['recBudget'] as num).toDouble();

    return Container(
      width: 110,
      height: 160,
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
          if (!isFutureMonth)
            Positioned(
              top: 10,
              right: 70,
              child: Text(
                "%${convertToArabicNumbers(formatNumber(progress))}",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
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
                    value:
                        isFutureMonth ? 0 : (progress / 100).clamp(0.01, 1.0),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isFutureMonth
                          ? Colors.grey.shade300
                          : getProgressColor(progress),
                    ),
                    strokeWidth: 6,
                  ),
                  Icon(categoryIcon, color: const Color(0xFF2C8C68), size: 22),
                ],
              ),
            ),
          ),
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
            top: 75,
            right: 10,
            child: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("مطلوب ادخار: ",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'GE-SS-Two-Light',
                            color: Color(0xFF3D3D3D),
                          )),
                      Text(formatNumber(monthlySavings),
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'GE-SS-Two-Light',
                            color: Color(0xFF3D3D3D),
                          )),
                      const SizedBox(width: 3),
                      const Icon(CustomIcons.riyal,
                          size: 14, color: Color(0xFF3D3D3D)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("المصروف: ",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'GE-SS-Two-Light',
                            color: Color(0xFF3D3D3D),
                          )),
                      Text(formatNumber(calculateSpentAmount(category)),
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'GE-SS-Two-Light',
                            color: Color(0xFF3D3D3D),
                          )),
                      const SizedBox(width: 3),
                      const Icon(CustomIcons.riyal,
                          size: 14, color: Color(0xFF3D3D3D)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("المتاح للصرف: ",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'GE-SS-Two-Light',
                            color: Color(0xFF3D3D3D),
                          )),
                      Text(formatNumber(recBudget),
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'GE-SS-Two-Light',
                            color: Color(0xFF3D3D3D),
                          )),
                      const SizedBox(width: 3),
                      const Icon(CustomIcons.riyal,
                          size: 14, color: Color(0xFF3D3D3D)),
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

  double calculateSpentAmount(String category) {
    DateTime today = DateTime.now();
    DateTime startDate = DateTime.parse(widget.resultData['startDate']);
    DateTime selectedStartDate;

    if (_currentMonthIndex == 0) {
      // Whole plan selected
      selectedStartDate = startDate;
    } else {
      // Specific month selected 
      selectedStartDate =
          startDate.add(Duration(days: (_currentMonthIndex - 1) * 30));
    }

    double totalSpent = 0.0;

    for (var account in widget.accounts) {
      for (var transaction in account['transactions']) {
        DateTime transactionDate =
            DateTime.parse(transaction['TransactionDateTime']);
        String transactionCategory = transaction['Category'] ?? 'Unknown';
        double amount =
            double.tryParse(transaction['Amount'].toString()) ?? 0.0;

        if (transactionCategory == category &&
            transactionDate.isAfter(selectedStartDate) &&
            transactionDate.isBefore(today)) {
          totalSpent += amount;
        }
      }
    }

    return totalSpent;
  }
}
