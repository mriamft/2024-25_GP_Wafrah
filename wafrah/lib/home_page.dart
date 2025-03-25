import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'transactions_page.dart';
import 'saving_plan_page.dart';
import 'banks_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// Import your goal page for navigation
import 'saving_plan_page2.dart';
import 'secure_storage_helper.dart'; // Import the secure storage helper
import 'custom_icons.dart';
import 'package:intl/intl.dart';
import 'chatbot.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final List<Map<String, dynamic>> accounts;

  const HomePage({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [],
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  Map<String, double> transactionCategories = {};

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  String _selectedPeriod = 'شهري';
  double _filteredIncome = 0.0;
  double _filteredExpense = 0.0;

  int currentPage = 0; // Track the current dashboard
  final PageController _pageController =
      PageController(); // Controller for PageView
  bool _isCirclePressed = false; // Track if the circle button is pressed
  bool _isBalanceVisible = true; // Default visibility state
  double _minIncome = double.infinity;
  double _maxIncome = double.negativeInfinity;
  double _minExpense = double.infinity;
  double _maxExpense = double.negativeInfinity;
  int _touchedIndex = -1; // Track the currently touched slice index
  // bool _isPieChartVisible = true; // Tracks pie chart visibility

  @override
  @override
  void initState() {
    super.initState();
    print("Backend response: ${jsonEncode(widget.accounts)}");

    _loadVisibilityState(); // Load saved visibility state on initialization

    // Log the transaction categories to verify the data
    print('Transaction Categories33: $transactionCategories');

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

    // Initialize the dashboard data
    updateDashboardData(); // Call this to populate the initial chart data
  }

  // Load the saved visibility state from SharedPreferences
  Future<void> _loadVisibilityState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBalanceVisible =
          prefs.getBool('isBalanceVisible') ?? true; // Default is true
    });
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

  String formatNumberWithArabicComma(double? number) {
    if (number == null) return '٠،٠٠'; // Default for null values
    String formattedNumber = NumberFormat("#,##0.00", "ar").format(number);
    return formattedNumber.replaceAll('.', '،'); // Convert dot to Arabic comma
  }

  // Save the visibility state to SharedPreferences
  Future<void> _saveVisibilityState(bool isVisible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBalanceVisible', isVisible);
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
    _saveVisibilityState(_isBalanceVisible); // Save the new state
  }

  Widget buildTimePeriodSelector() {
    return DropdownButton<String>(
      value: _selectedPeriod,
      items: ['اسبوعي', 'شهري', 'سنوي'] // Removed "يومي"
          .map((period) => DropdownMenuItem(
                value: period,
                child: Text(
                  period,
                  style: const TextStyle(fontFamily: 'GE-SS-Two-Light'),
                ),
              ))
          .toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedPeriod = newValue!;
          updateDashboardData(); // Refresh data based on selected period
        });
      },
    );
  }

  List<FlSpot> incomeData = [];
  List<FlSpot> expenseData = [];

  void updateDashboardData() {
    DateTime now = DateTime.now();
    DateTime selectedDate = DateTime(2025, now.month - monthOffset, now.day);

    // Clear existing data
    incomeData.clear();
    expenseData.clear();

    if (_selectedPeriod == 'سنوي') {
      _calculateMonthlyData(selectedDate); // Ensure this is for 'سنوي'
      calculateStatistics('سنوي', selectedDate);
      transactionCategories =
          _calculateCategoryDataForPieChart('سنوي', selectedDate);
    } else if (_selectedPeriod == 'شهري') {
      _calculateWeeklyData(selectedDate); // Confirm this is called for 'شهري'
      calculateStatistics('شهري', selectedDate);
      transactionCategories =
          _calculateCategoryDataForPieChart('شهري', selectedDate);
    } else if (_selectedPeriod == 'اسبوعي') {
      int startDay = ((4 - weekOffset) * 7) - 6;
      int endDay = (4 - weekOffset) * 7;
      DateTime weeklyDate =
          DateTime(selectedDate.year, selectedDate.month, startDay);
      _calculateDailyData(weeklyDate);
      calculateStatistics('اسبوعي', weeklyDate);
      transactionCategories =
          _calculateCategoryDataForPieChart('اسبوعي', weeklyDate);
    }
    setState(() {});
  }

  void calculateStatistics(String period, DateTime selectedDate) {
    // Define a cutoff date based on the current day and month in 2016
    DateTime now = DateTime.now();
    DateTime cutoffDate =
        DateTime(2025, now.month, now.day, now.hour, now.minute, now.second);

    // Reset statistics
    _minIncome = double.infinity;
    _maxIncome = double.negativeInfinity;
    _minExpense = double.infinity;
    _maxExpense = double.negativeInfinity;
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    int incomeCount = 0;
    int expenseCount = 0;

    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String dateStr = transaction['TransactionDateTime'] ?? '';
        DateTime transactionDate = DateTime.tryParse(dateStr) ?? DateTime.now();

        bool includeTransaction = false;
        // Apply period-specific filtering with the cutoff date
        if (transactionDate.isAfter(cutoffDate)) {
          continue; // Skip transactions beyond the cutoff date
        }

        if (period == 'اسبوعي' &&
            transactionDate.year == 2025 &&
            transactionDate.month == selectedDate.month &&
            _getWeekOfMonth(transactionDate.day) ==
                _getWeekOfMonth(selectedDate.day)) {
          includeTransaction = true;
        } else if (period == 'شهري' &&
            transactionDate.year == 2025 &&
            transactionDate.month == selectedDate.month) {
          includeTransaction = true;
        } else if (period == 'سنوي' && transactionDate.year == 2025) {
          includeTransaction = true;
        }

        if (includeTransaction) {
          String subtype =
              transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
                  'غير معروف';
          double amount =
              double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;

          if (['Deposit', 'WithdrawalReversal', 'Refund'].contains(subtype)) {
            totalIncome += amount;
            incomeCount++;
            _minIncome = amount < _minIncome ? amount : _minIncome;
            _maxIncome = amount > _maxIncome ? amount : _maxIncome;
          } else if ([
            'MoneyTransfer',
            'Withdrawal',
            'Purchase',
            'DepositReversal',
            'NotApplicable'
          ].contains(subtype)) {
            totalExpense += amount;
            expenseCount++;
            _minExpense = amount < _minExpense ? amount : _minExpense;
            _maxExpense = amount > _maxExpense ? amount : _maxExpense;
          }
        }
      }
    }

    // Calculate averages
    _filteredIncome = incomeCount > 0 ? totalIncome / incomeCount : 0.0;
    _filteredExpense = expenseCount > 0 ? totalExpense / expenseCount : 0.0;

    // Set to zero if no data was found
    _minIncome = _minIncome == double.infinity ? 0.0 : _minIncome;
    _maxIncome = _maxIncome == double.negativeInfinity ? 0.0 : _maxIncome;
    _minExpense = _minExpense == double.infinity ? 0.0 : _minExpense;
    _maxExpense = _maxExpense == double.negativeInfinity ? 0.0 : _maxExpense;

    setState(() {});
  }

  void _calculateWeeklyData(DateTime currentDate) {
    DateTime now = DateTime.now();
    DateTime cutoffDate =
        currentDate.month == now.month && currentDate.year == now.year
            ? DateTime(currentDate.year, currentDate.month, now.day)
            : DateTime(currentDate.year, currentDate.month + 1, 0);

    Map<int, double> weeklyIncome = {};
    Map<int, double> weeklyExpense = {};

    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String dateStr = transaction['TransactionDateTime'] ?? '';
        DateTime transactionDate = DateTime.tryParse(dateStr) ?? DateTime.now();

        // Ensure the transaction date falls within the weekly period
        if (transactionDate.year == currentDate.year &&
            transactionDate.month == currentDate.month &&
            transactionDate.isBefore(cutoffDate)) {
          int week = ((transactionDate.day - 1) / 7).floor();
          double amount =
              double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;

          String type =
              transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? '';

          if (['Deposit', 'WithdrawalReversal', 'Refund'].contains(type)) {
            weeklyIncome[week] = (weeklyIncome[week] ?? 0.0) + amount;
          } else if ([
            'MoneyTransfer',
            'Withdrawal',
            'Purchase',
            'DepositReversal',
            'NotApplicable'
          ].contains(type)) {
            weeklyExpense[week] = (weeklyExpense[week] ?? 0.0) + amount;
          }
        }
      }
    }

    // Assign data to FlSpots for the line chart
    incomeData =
        List.generate(4, (i) => FlSpot(i.toDouble(), weeklyIncome[i] ?? 0.0));
    expenseData =
        List.generate(4, (i) => FlSpot(i.toDouble(), weeklyExpense[i] ?? 0.0));

    print('Weekly Income Data: $weeklyIncome');
    print('Weekly Expense Data: $weeklyExpense');
  }

// Helper function to get week number in a month
  int _getWeekOfMonth(int day) {
    if (day <= 7) {
      return 1;
    } else if (day <= 14) {
      return 2;
    } else if (day <= 21) {
      return 3;
    } else {
      return 4;
    }
  }

  int _getTimeIndex(DateTime transactionDate) {
    if (_selectedPeriod == 'اسبوعي') {
      return transactionDate.weekday - 1; // Saturday = 0, Friday = 6
    } else if (_selectedPeriod == 'شهري') {
      return _getWeekOfMonth(transactionDate.day) -
          1; // 0-based index for weeks
    } else if (_selectedPeriod == 'سنوي') {
      return transactionDate.month - 1; // 0-based index for months
    }
    return -1; // Out of range
  }

  Widget buildCategoryLineChart() {
    List<FlSpot> generateSpotsForCategory(String category) {
      List<FlSpot> spots = [];

      if (expenseData.isEmpty) return [];

      // Initialize list to store category expenses at each time step
      List<double> categoryExpenseAtEachTime =
          List.filled(expenseData.length, 0.0);
      List<double> totalExpenseAtEachTime =
          List.filled(expenseData.length, 0.0);

      // Step 1: Collect all expenses per time step
      for (var account in widget.accounts) {
        var transactions = account['transactions'] ?? [];
        for (var transaction in transactions) {
          String dateStr = transaction['TransactionDateTime'] ?? '';
          DateTime transactionDate =
              DateTime.tryParse(dateStr) ?? DateTime.now();

          double amount =
              double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;
          String transactionCategory =
              transaction['Category'] ?? 'غير مصنف'; // Default category

          // Find the time index for this transaction
          int timeIndex = _getTimeIndex(transactionDate);
          if (timeIndex >= 0 && timeIndex < categoryExpenseAtEachTime.length) {
            totalExpenseAtEachTime[timeIndex] +=
                amount; // Track total expenses at this time step
            if (transactionCategory == category) {
              categoryExpenseAtEachTime[timeIndex] +=
                  amount; // Assign category expenses
            }
          }
        }
      }

      // Step 2: Scale category expenses based on total expense at each time step
      for (int i = 0; i < categoryExpenseAtEachTime.length; i++) {
        double totalExpense = totalExpenseAtEachTime[i];
        double categoryExpense = categoryExpenseAtEachTime[i];

        // Ensure correct proportion (Avoid division by zero)
        double adjustedExpense = (totalExpense > 0)
            ? (categoryExpense / totalExpense) * expenseData[i].y
            : 0;

        spots.add(FlSpot(i.toDouble(), adjustedExpense));
      }

      return spots;
    }

    List<String> xAxisLabels;
    if (_selectedPeriod == 'اسبوعي') {
      int todayIndex = DateTime.now().weekday - 1;
      xAxisLabels = [
        'السبت',
        'الأحد',
        'الإثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة'
      ];
    } else if (_selectedPeriod == 'شهري') {
      int currentWeek = _getWeekOfMonth(DateTime.now().day);
      xAxisLabels = ['الأسبوع 1', 'الأسبوع 2', 'الأسبوع 3', 'الأسبوع 4']
          .sublist(0, currentWeek);
    } else {
      int currentMonth = DateTime.now().month;
      xAxisLabels = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر'
      ].sublist(0, currentMonth);
    }

    Map<String, Color> categoryColors = {
      "التعليم": Colors.blue,
      "الترفيه": Colors.purple,
      "المدفوعات الحكومية": Colors.orange,
      "البقالة": Colors.green,
      "الصحة": Colors.red,
      "القروض": Colors.brown,
      "الاستثمار": Colors.indigo,
      "الإيجار": Colors.teal,
      "المطاعم": Colors.pink,
      "تسوق": Colors.amber,
      "التحويلات": Colors.cyan,
      "النقل": Colors.deepPurple,
      "السفر": Colors.deepOrange,
      "أخرى": Colors.grey
    };

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(8.0, 25.0, 8.0, 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'توزيع الصرف حسب الفئة',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Bold',
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, _) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'GE-SS-Two-Light',
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                          interval: 1,
                          getTitlesWidget: (value, _) {
                            int index = value.toInt();
                            if (index >= 0 && index < xAxisLabels.length) {
                              return Text(
                                xAxisLabels[index],
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'GE-SS-Two-Light',
                                  color: Colors.grey,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      drawHorizontalLine: true,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      ),
                    ),
                    lineBarsData: categoryColors.entries.map((entry) {
                      return LineChartBarData(
                        spots: generateSpotsForCategory(entry.key),
                        isCurved: true,
                        color: entry.value,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: entry.value.withOpacity(0.4),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                children: categoryColors.entries.map((entry) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        color: entry.value,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'GE-SS-Two-Light',
                          color: Colors.black,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

// Monthly data calculation for the 'سنوي' view (for completeness)
  void _calculateMonthlyData(DateTime currentDate) {
    // Get today's date for truncation
    DateTime now = DateTime.now();
    DateTime cutoffDate = DateTime(now.year, now.month, now.day);

    Map<int, double> monthlyIncome = {};
    Map<int, double> monthlyExpense = {};

    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String dateStr = transaction['TransactionDateTime'] ?? '';
        DateTime transactionDate = DateTime.tryParse(dateStr) ?? DateTime.now();

        // Only include transactions up to the current date
        if (transactionDate.isBefore(cutoffDate) ||
            transactionDate.isAtSameMomentAs(cutoffDate)) {
          if (transactionDate.year == currentDate.year) {
            int month = transactionDate.month - 1; // Month index starts from 0
            double amount =
                double.tryParse(transaction['Amount']?.toString() ?? '0') ??
                    0.0;

            String type =
                transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
                    '';

            if (['Deposit', 'WithdrawalReversal', 'Refund'].contains(type)) {
              monthlyIncome[month] = (monthlyIncome[month] ?? 0.0) + amount;
            } else if ([
              'MoneyTransfer',
              'Withdrawal',
              'Purchase',
              'DepositReversal',
              'NotApplicable'
            ].contains(type)) {
              monthlyExpense[month] = (monthlyExpense[month] ?? 0.0) + amount;
            }
          }
        }
      }
    }

    // Populate the graph data
    incomeData =
        List.generate(12, (i) => FlSpot(i.toDouble(), monthlyIncome[i] ?? 0.0));
    expenseData = List.generate(
        12, (i) => FlSpot(i.toDouble(), monthlyExpense[i] ?? 0.0));

    // Trim months beyond today's month
    int currentMonthIndex = now.month - 1;
    incomeData = incomeData
        .where((spot) => spot.x <= currentMonthIndex.toDouble())
        .toList();
    expenseData = expenseData
        .where((spot) => spot.x <= currentMonthIndex.toDouble())
        .toList();

    setState(() {});
  }

  int weekOffset = 0;
  int monthOffset = 0;
  int yearOffset = 0;

  void _calculateDailyData(DateTime currentDate) {
    DateTime now = DateTime.now();
    DateTime cutoffDate = (currentDate.month == now.month)
        ? DateTime(2025, now.month, now.day, now.hour, now.minute, now.second)
        : DateTime(2025, currentDate.month + 1, 1, now.hour, now.minute,
                now.second)
            .subtract(const Duration(days: 1));

    int selectedWeek = 4 - (weekOffset % 4);
    int startDay = (selectedWeek - 1) * 7 + 1;
    int endDay = selectedWeek * 7;

    Map<int, double> dailyIncome = {
      for (int i = startDay; i <= endDay; i++) i: 0.0
    };
    Map<int, double> dailyExpense = {
      for (int i = startDay; i <= endDay; i++) i: 0.0
    };

    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String dateStr = transaction['TransactionDateTime'] ?? '';
        DateTime transactionDate = DateTime.tryParse(dateStr) ?? DateTime.now();

        if (transactionDate.year == 2025 &&
            transactionDate.month == currentDate.month &&
            transactionDate.day >= startDay &&
            transactionDate.day <= endDay &&
            transactionDate.isBefore(cutoffDate)) {
          int day = transactionDate.day;
          double amount =
              double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;

          String type =
              transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? '';

          if (['Deposit', 'WithdrawalReversal', 'Refund'].contains(type)) {
            dailyIncome[day] = (dailyIncome[day] ?? 0.0) + amount;
          } else if ([
            'MoneyTransfer',
            'Withdrawal',
            'Purchase',
            'DepositReversal',
            'NotApplicable'
          ].contains(type)) {
            dailyExpense[day] = (dailyExpense[day] ?? 0.0) + amount;
          }
        }
      }
    }

    incomeData.clear();
    expenseData.clear();

    for (int i = startDay; i <= endDay; i++) {
      incomeData.add(FlSpot(i.toDouble() - startDay, dailyIncome[i] ?? 0.0));
      expenseData.add(FlSpot(i.toDouble() - startDay, dailyExpense[i] ?? 0.0));
    }

    setState(() {});
  }

  String getCurrentWeekLabel() {
    int currentWeek = 4 - (weekOffset % 4);
    DateTime currentDate =
        DateTime(2025, DateTime.now().month - monthOffset, 1);
    String monthName = getMonthName(currentDate.month);
    return '$monthName 2025 - الأسبوع $currentWeek';
  }

  Widget buildDailyNavigationButtons() {
    // Ensure that the weekOffset does not go below the current week in the current month
    bool disableLeft = weekOffset >= 3; // Reached the beginning of the month
    bool disableRight =
        weekOffset <= 0; // Reached the current week in the current month

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: disableLeft ? Colors.grey : Colors.black,
          ),
          onPressed: disableLeft
              ? null
              : () {
                  setState(() {
                    weekOffset++;
                    updateDashboardData();
                  });
                },
        ),
        Text(
          getCurrentWeekLabel(), // Display the current week label
          style: const TextStyle(fontFamily: 'GE-SS-Two-Light'),
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_forward,
            color: disableRight ? Colors.grey : Colors.black,
          ),
          onPressed: disableRight
              ? null
              : () {
                  setState(() {
                    weekOffset--;
                    updateDashboardData();
                  });
                },
        ),
      ],
    );
  }

  String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'يناير';
      case 2:
        return 'فبراير';
      case 3:
        return 'مارس';
      case 4:
        return 'أبريل';
      case 5:
        return 'مايو';
      case 6:
        return 'يونيو';
      case 7:
        return 'يوليو';
      case 8:
        return 'أغسطس';
      case 9:
        return 'سبتمبر';
      case 10:
        return 'أكتوبر';
      case 11:
        return 'نوفمبر';
      case 12:
        return 'ديسمبر';
      default:
        return '';
    }
  }

  Widget buildWeekNavigationButtons() {
    DateTime now = DateTime.now();
    DateTime selectedDate = DateTime(2025, now.month - monthOffset, 1);
    bool isCurrentMonth =
        selectedDate.month == now.month && selectedDate.year == now.year;

    // Get the current week number based on today's date
    int currentWeekInMonth = ((now.day - 1) / 7).floor() + 1;
    int displayedWeek = 4 - weekOffset;

    // Determine if the left or right buttons should be disabled
    bool disableLeft = displayedWeek == 1; // Disable left arrow for Week 1
    bool disableRight = isCurrentMonth
        ? (displayedWeek >= currentWeekInMonth)
        : (displayedWeek == 4);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: disableLeft ? Colors.grey : Colors.black,
          ),
          onPressed: disableLeft
              ? null
              : () {
                  setState(() {
                    weekOffset++;
                    updateDashboardData();
                  });
                },
        ),
        Text(
          getCurrentWeekLabel(),
          style: const TextStyle(fontFamily: 'GE-SS-Two-Light'),
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_forward,
            color: disableRight ? Colors.grey : Colors.black,
          ),
          onPressed: disableRight
              ? null
              : () {
                  setState(() {
                    weekOffset--;
                    updateDashboardData();
                  });
                },
        ),
      ],
    );
  }

  String getCurrentMonthName() {
    DateTime targetMonth = DateTime(2025, DateTime.now().month - monthOffset);
    List<String> monthNames = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return monthNames[targetMonth.month - 1];
  }

  Widget buildMonthNavigationButtons() {
    // Get the actual current month
    DateTime now = DateTime.now();
    int currentMonth = now.month;

    // Calculate the displayed month based on the offset
    int displayedMonth = currentMonth - monthOffset;

    // Determine if left or right button should be disabled
    bool disableLeft = displayedMonth == 1; // January
    bool disableRight = displayedMonth == currentMonth; // Current month

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: disableLeft ? Colors.grey : Colors.black,
          ),
          onPressed: disableLeft
              ? null
              : () {
                  setState(() {
                    monthOffset++;
                    updateDashboardData();
                  });
                },
        ),
        Text(
          getLocalizedMonthName(
              displayedMonth), // Display the current month name
          style: const TextStyle(fontFamily: 'GE-SS-Two-Light'),
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_forward,
            color: disableRight ? Colors.grey : Colors.black,
          ),
          onPressed: disableRight
              ? null
              : () {
                  setState(() {
                    monthOffset--;
                    updateDashboardData();
                  });
                },
        ),
      ],
    );
  }

  String getLocalizedMonthName(int month) {
    List<String> monthNames = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return monthNames[month - 1];
  }

/*
   String getCurrentYear() {
  int baseYear = 2016 - yearOffset;
  return getMappedYear(DateTime(baseYear)).toString();
}

 */
  int getMappedYear(DateTime date) {
    if (date.year == 2025) {
      return 2025;
    } else if (date.year == 2025) {
      return 2025;
    }
    return date.year; // Default to the actual year if no mapping is needed
  }

  Widget buildYearNavigationButtons() {
    DateTime now = DateTime.now();
    DateTime modifiedDate = DateTime(now.year);

    int mappedYear = getMappedYear(modifiedDate);
    return Center(
      child: Text(
        mappedYear.toString(), // Display mapped year
        style: TextStyle(
          fontFamily: 'GE-SS-Two-Light',
          fontSize: 16,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget buildIncomeExpenseGraph() {
    // Determine the highest value between income and expense
    double maxIncome = incomeData.isNotEmpty
        ? incomeData.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0.0;
    double maxExpense = expenseData.isNotEmpty
        ? expenseData.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0.0;

    // Get the highest value for scaling the y-axis
    double highestValue = maxIncome > maxExpense ? maxIncome : maxExpense;

    // Round the highest value to the nearest multiple of 100 or 1000
    double maxY = highestValue <= 1000
        ? (highestValue / 100).ceil() * 100
        : (highestValue / 1000).ceil() * 1000;

    // Calculate interval for the y-axis
    double interval = maxY <= 1000 ? 100 : 1000;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,
            height: 300,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY, // Ensure scaling is correct
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: interval, // Use calculated interval
                      getTitlesWidget: (value, _) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'GE-SS-Two-Light',
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        List<String> labels;

                        // Determine labels for x-axis based on the period
                        switch (_selectedPeriod) {
                          case 'اسبوعي':
                            labels = [
                              'السبت',
                              'الأحد',
                              'الاثنين',
                              'الثلاثاء',
                              'الأربعاء',
                              'الخميس',
                              'الجمعة'
                            ];
                            break;
                          case 'شهري':
                            labels = [
                              '1 الأسبوع',
                              '2 الأسبوع',
                              '3 الأسبوع',
                              '4 الأسبوع'
                            ];
                            break;
                          case 'سنوي':
                            labels = [
                              'يناير',
                              'فبراير',
                              'مارس',
                              'أبريل',
                              'مايو',
                              'يونيو',
                              'يوليو',
                              'أغسطس',
                              'سبتمبر',
                              'أكتوبر',
                              'نوفمبر',
                              'ديسمبر'
                            ];
                            break;
                          default:
                            labels = [];
                        }

                        // Fetch the appropriate label for the x-axis value
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Text(
                            labels[index],
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'GE-SS-Two-Light',
                              color: Colors.grey,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  verticalInterval: 1,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: incomeData,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.4),
                    ),
                  ),
                  LineChartBarData(
                    spots: expenseData,
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'الدخل',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'GE-SS-Two-Light',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'الصرف',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'GE-SS-Two-Light',
                      color: Colors.grey,
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

  List<FlSpot> _generateIncomeData() {
    List<FlSpot> incomeSpots = [];
    Map<int, double> monthlyIncome = {}; // To accumulate monthly data

    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String? dateStr = transaction['TransactionDateTime'];
        if (dateStr != null) {
          DateTime transactionDate =
              DateTime.tryParse(dateStr) ?? DateTime.now();
          int month = transactionDate.month - 1;
          String subtype =
              transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
                  'غير معروف';
          String amountStr = transaction['Amount']?.toString() ?? '0.00';
          double amount =
              double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;

          if (['Deposit', 'WithdrawalReversal', 'Refund'].contains(subtype)) {
            monthlyIncome[month] = (monthlyIncome[month] ?? 0) + amount;
          }
        }
      }
    }

    for (int i = 0; i < 12; i++) {
      incomeSpots.add(FlSpot(i.toDouble(), monthlyIncome[i] ?? 0));
    }
    return incomeSpots;
  }

  List<FlSpot> _generateExpenseData() {
    List<FlSpot> expenseSpots = [];
    Map<int, double> monthlyExpense = {}; // To accumulate monthly data

    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String? dateStr = transaction['TransactionDateTime'];
        if (dateStr != null) {
          DateTime transactionDate =
              DateTime.tryParse(dateStr) ?? DateTime.now();
          int month = transactionDate.month - 1;
          String subtype =
              transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
                  'غير معروف';
          String amountStr = transaction['Amount']?.toString() ?? '0.00';
          double amount =
              double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;

          if ([
            'MoneyTransfer',
            'Withdrawal',
            'Purchase',
            'DepositReversal',
            'NotApplicable'
          ].contains(subtype)) {
            monthlyExpense[month] = (monthlyExpense[month] ?? 0) + amount;
          }
        }
      }
    }

    for (int i = 0; i < 12; i++) {
      expenseSpots.add(FlSpot(i.toDouble(), monthlyExpense[i] ?? 0));
    }
    return expenseSpots;
  }

  double calculateMinIncome() {
    double minIncome = double.infinity;
    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String subtype =
            transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
                'غير معروف';
        String amountStr = transaction['Amount']?.toString() ?? '0.00';
        double amount =
            double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;

        if (['Deposit', 'WithdrawalReversal', 'Refund'].contains(subtype)) {
          if (amount < minIncome) {
            minIncome = amount;
          }
        }
      }
    }
    return minIncome == double.infinity ? 0.0 : minIncome;
  }

  double calculateMaxIncome() {
    double maxIncome = double.negativeInfinity;
    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String subtype =
            transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
                'غير معروف';
        String amountStr = transaction['Amount']?.toString() ?? '0.00';
        double amount =
            double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;

        if (['Deposit', 'WithdrawalReversal', 'Refund'].contains(subtype)) {
          if (amount > maxIncome) {
            maxIncome = amount;
          }
        }
      }
    }
    return maxIncome == double.negativeInfinity ? 0.0 : maxIncome;
  }

  double calculateAvgIncome() {
    double totalIncome = 0.0;
    int count = 0;
    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String subtype =
            transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
                'غير معروف';
        String amountStr = transaction['Amount']?.toString() ?? '0.00';
        double amount =
            double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;

        if (['Deposit', 'WithdrawalReversal', 'Refund'].contains(subtype)) {
          totalIncome += amount;
          count++;
        }
      }
    }
    return count == 0 ? 0.0 : totalIncome / count;
  }

  double calculateMinExpense() {
    double minExpense = double.infinity;
    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String subtype =
            transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
                'غير معروف';
        String amountStr = transaction['Amount']?.toString() ?? '0.00';
        double amount =
            double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;

        if ([
          'MoneyTransfer',
          'Withdrawal',
          'Purchase',
          'DepositReversal',
          'NotApplicable'
        ].contains(subtype)) {
          if (amount < minExpense) {
            minExpense = amount;
          }
        }
      }
    }
    return minExpense == double.infinity ? 0.0 : minExpense;
  }

  double calculateMaxExpense() {
    double maxExpense = double.negativeInfinity;
    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String subtype =
            transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
                'غير معروف';
        String amountStr = transaction['Amount']?.toString() ?? '0.00';
        double amount =
            double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;

        if ([
          'MoneyTransfer',
          'Withdrawal',
          'Purchase',
          'DepositReversal',
          'NotApplicable'
        ].contains(subtype)) {
          if (amount > maxExpense) {
            maxExpense = amount;
          }
        }
      }
    }
    return maxExpense == double.negativeInfinity ? 0.0 : maxExpense;
  }

  double calculateAvgExpense() {
    double totalExpense = 0.0;
    int count = 0;
    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String subtype =
            transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
                'غير معروف';
        String amountStr = transaction['Amount']?.toString() ?? '0.00';
        double amount =
            double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;

        if ([
          'MoneyTransfer',
          'Withdrawal',
          'Purchase',
          'DepositReversal',
          'NotApplicable'
        ].contains(subtype)) {
          totalExpense += amount;
          count++;
        }
      }
    }
    return count == 0 ? 0.0 : totalExpense / count;
  }

//static part
  Widget buildStatisticsSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 239, 239, 239),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Minimum Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'الحد الأدنى',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Bold',
                    fontSize: 12,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CustomIcons.riyal,
                      size: 11,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 3),
                    Text(
                      formatNumberWithArabicComma(
                          _minIncome ?? 0.0), // Ensure it's not null
                      style: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                      textAlign: TextAlign
                          .right, // Align text to the right instead of RTL
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CustomIcons.riyal,
                      size: 11,
                      color: Colors.red[700],
                    ),
                    const SizedBox(width: 3),
                    Text(
                      formatNumberWithArabicComma(
                          _minExpense ?? 0.0), // Ensure it's not null
                      style: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 12,
                        color: Colors.red[700],
                      ),
                      textAlign: TextAlign
                          .right, // Align text to the right instead of RTL
                    ),
                  ],
                ),
              ],
            ),

            // Maximum Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'الحد الأعلى',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Bold',
                    fontSize: 12,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CustomIcons.riyal,
                      size: 11,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 3),
                    Text(
                      formatNumberWithArabicComma(
                          _maxIncome ?? 0.0), // Ensure it's not null
                      style: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                      textAlign: TextAlign
                          .right, // Align text to the right instead of RTL
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CustomIcons.riyal,
                      size: 11,
                      color: Colors.red[700],
                    ),
                    const SizedBox(width: 3),
                    Text(
                      formatNumberWithArabicComma(
                          _maxExpense ?? 0.0), // Ensure it's not null
                      style: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 12,
                        color: Colors.red[700],
                      ),
                      textAlign: TextAlign
                          .right, // Align text to the right instead of RTL
                    ),
                  ],
                ),
              ],
            ),

            // Average Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'المتوسط',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Bold',
                    fontSize: 12,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CustomIcons.riyal,
                      size: 11,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 3),
                    Text(
                      formatNumberWithArabicComma(
                          _filteredIncome ?? 0.0), // Ensure it's not null
                      style: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                      textAlign: TextAlign
                          .right, // Align text to the right instead of RTL
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CustomIcons.riyal,
                      size: 11,
                      color: Colors.red[700],
                    ),
                    const SizedBox(width: 3),
                    Text(
                      formatNumberWithArabicComma(
                          _filteredExpense ?? 0.0), // Ensure it's not null
                      style: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 12,
                        color: Colors.red[700],
                      ),
                      textAlign: TextAlign
                          .right, // Align text to the right instead of RTL
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Pie chart to show transaction categories
  Widget buildPieChart() {
    // if (!_isPieChartVisible) {
    //   return const Center(
    //     child: Text(
    //       'لا توجد عمليات للعرض',
    //       style: TextStyle(
    //         fontSize: 14,
    //         fontFamily: 'GE-SS-Two-Light',
    //         color: Colors.grey,
    //       ),
    //     ),
    //   );
    // }

    //Map<String, double> pieChartData = _calculateCategoryDataForPieChart();
    if (transactionCategories.isEmpty ||
        transactionCategories.values.every((value) => value == 0)) {
      return const Center(
        child: Text(
          'لا توجد عمليات صرف للفترة المختارة لعرض تصنيفاتها',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'GE-SS-Two-Light',
            color: Colors.grey,
          ),
        ),
      );
    }

    //List<Color> colors = generateDynamicGreenShades(transactionCategories.length);
    double total = transactionCategories.values.reduce((a, b) => a + b);

    return PieChart(
      PieChartData(
        sections: transactionCategories.entries.map((entry) {
          final index = transactionCategories.keys.toList().indexOf(entry.key);
          //final color = colors[index % colors.length];
          final value = entry.value;
          final percentage = (value / total) * 100;
          final color = percentage >= 80
              ? Colors.red[900]!
              : percentage >= 60
                  ? Colors.red[800]!
                  : percentage >= 50
                      ? Colors.red[700]!
                      : percentage >= 40
                          ? Colors.red[600]!
                          : percentage >= 30
                              ? Colors.red[500]!
                              : percentage >= 20
                                  ? Colors.red[400]!
                                  : percentage >= 10
                                      ? Colors.red[300]!
                                      : Colors.red[200]!;

          return PieChartSectionData(
            color: color,
            value: value,
            title: '%${percentage.toStringAsFixed(1)}',
            titlePositionPercentageOffset: 0.55,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontFamily: 'GE-SS-Two-Light',
              color: Colors.white,
            ),
            radius: _touchedIndex == index ? 60 : 50,
            badgeWidget: _buildBadge(entry.key, percentage),
            badgePositionPercentageOffset: 1.4,
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
      ),
    );
  }

  Widget buildPieChartWithBorder() {
    return Container(
      padding: const EdgeInsets.all(
          10.0), // Increase padding for more internal space
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(16.0), // Adjust the corner radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Shadow color
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.end, // Align children to the right
        children: [
          Text(
            'تصنيف عمليات الصرف',
            textAlign: TextAlign.right, // Align Arabic text correctly
            style: TextStyle(
              fontFamily: 'GE-SS-Two-Bold',
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(height: 0), // Add space between title and chart
          SizedBox(
            height: 285, // Increase the height of the pie chart box
            child: buildPieChart(), // Call the existing pie chart function
          ),
        ],
      ),
    );
  }

  // Badge widget to display category name and percentage outside each slice
  Widget _buildBadge(String category, double percentage) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          category,
          style: const TextStyle(
            fontSize: 10,
            fontFamily: 'GE-SS-Two-Light',
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // Generate dynamic colors based on the number of categories
// Generate dynamic green shades between the base colors
  List<Color> generateDynamicGreenShades(int count) {
    // Base colors to interpolate between
    List<Color> baseColors = [
      const Color(0xFFF4D968), // Yellowish-green
      const Color(0xFF92A662), // Light green
      const Color(0xFF2C8C68), // Medium green
      const Color(0xFF1C5B42), // Dark green
    ];

    // If the number of shades is less than or equal to the base colors, just use the base colors
    if (count <= baseColors.length) {
      return baseColors.sublist(0, count);
    }

    // Interpolate to create more shades
    List<Color> greenShades = [];
    double step = (baseColors.length - 1) / (count - 1);

    for (int i = 0; i < count; i++) {
      // Determine start and end colors for this step
      double position = i * step;
      int startIndex = position.floor();
      int endIndex = (startIndex + 1).clamp(0, baseColors.length - 1);
      double t = position - startIndex;

      // Interpolate between startIndex and endIndex
      Color startColor = baseColors[startIndex];
      Color endColor = baseColors[endIndex];

      int red = (startColor.red + (endColor.red - startColor.red) * t).toInt();
      int green =
          (startColor.green + (endColor.green - startColor.green) * t).toInt();
      int blue =
          (startColor.blue + (endColor.blue - startColor.blue) * t).toInt();

      greenShades.add(Color.fromARGB(255, red, green, blue));
    }

    return greenShades;
  }

  Widget buildBarChart() {
    Map<String, double> categoryData =
        _calculateCategoryExpenses(); // Calculate from real data

    return BarChart(
      BarChartData(
        barGroups: categoryData.entries.map((entry) {
          return BarChartGroupData(
            x: categoryData.keys.toList().indexOf(entry.key),
            barRods: [
              BarChartRodData(
                toY: entry.value,
                width: 15,
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (index, _) {
                String category = categoryData.keys.toList()[index.toInt()];
                return Text(category,
                    style: const TextStyle(
                        fontSize: 10, fontFamily: 'GE-SS-Two-Light'));
              },
            ),
          ),
        ),
      ),
    );
  }

// Example method to calculate real income and expense for line chart
  List<FlSpot> _generateSpotsForIncome() {
    // Generate spots based on transactions data
    List<FlSpot> incomeSpots = [];
    // Populate incomeSpots with real data points
    return incomeSpots;
  }

  List<FlSpot> _generateSpotsForExpense() {
    // Generate spots based on transactions data
    List<FlSpot> expenseSpots = [];
    // Populate expenseSpots with real data points
    return expenseSpots;
  }

// Example method to calculate category expenses for bar chart
  Map<String, double> _calculateCategoryExpenses() {
    Map<String, double> categoryExpenses = {};
    // Populate categoryExpenses with real data from widget.accounts
    return categoryExpenses;
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

    // Get today's date
    DateTime now = DateTime.now();

    // Calculate the start and end dates of the range (start of month to today)
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime today = DateTime(now.year, now.month, now.day);

    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        // Parse the transaction date
        String? dateStr = transaction['TransactionDateTime'];
        DateTime transactionDate =
            DateTime.tryParse(dateStr ?? '') ?? DateTime.now();

        // Filter transactions within the range
        if (transactionDate
                .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            transactionDate.isBefore(today.add(const Duration(days: 1)))) {
          // Determine the subtype and amount
          String subtype =
              transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
                  'غير معروف';
          String amountStr = transaction['Amount']?.toString() ?? '0.00';
          double amount =
              double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;

          // Classify as income or expense
          if (['Deposit', 'WithdrawalReversal', 'Refund'].contains(subtype)) {
            totalIncome += amount;
          } else if ([
            'MoneyTransfer',
            'Withdrawal',
            'Purchase',
            'DepositReversal',
            'NotApplicable'
          ].contains(subtype)) {
            totalExpense += amount;
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
          SlideTransition(
            position: _offsetAnimation,
            child: Stack(
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
                  top: 25,
                  right: 20,
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
                          text: widget.userName.split(' ').first,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontFamily: 'GE-SS-Two-Bold',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 80,
            left: 19,
            right: 19,
            child: Container(
              height: 610,
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
          Positioned(
            bottom: 150,
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
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SettingsPage(
                                userName: widget.userName,
                                phoneNumber: widget.phoneNumber,
                                accounts: widget.accounts),
                        transitionDuration: const Duration(seconds: 0),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                      ),
                      (route) => false,
                    );
                  }),
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
                        transitionDuration: const Duration(seconds: 0),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                      ),
                      (route) => false,
                    );
                  }),
                  buildBottomNavItem(
                    Icons.account_balance_outlined,
                    "الحسابات",
                    2,
                    isSelected: true,
                    onTap: () {
                      Navigator.push(
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
                      Icons.home,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 190,
            top: 765,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF2C8C68),
                shape: BoxShape.circle,
              ),
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

  // First Dashboard Layout
  Widget buildFirstDashboard(double totalIncome, double totalExpense) {
    Map<String, double> totals = calculateIncomeAndExpense(); // Updated call
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 80), // Additional top padding for centering

          Stack(
            children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CustomIcons.riyal,
                        size: 23,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _isBalanceVisible
                            ? formatNumberWithArabicComma(
                                double.parse(getTotalBalance()))
                            : getMaskedValue(),
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
              Positioned(
                top: -10,
                right: 0,
                child: IconButton(
                  icon: Icon(
                    _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey[800],
                    size: 24,
                  ),
                  onPressed: _toggleBalanceVisibility,
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),

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
                        const Icon(Icons.arrow_downward,
                            color: Colors.red, size: 24),
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
                            const Icon(
                              CustomIcons.riyal,
                              size: 14,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _isBalanceVisible
                                  ? formatNumberWithArabicComma(
                                      totals['expense']!)
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

                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.grey[300],
                    ),

                    Column(
                      children: [
                        const Icon(Icons.arrow_upward,
                            color: Colors.green, size: 24),
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
                            const Icon(
                              CustomIcons.riyal,
                              size: 14,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _isBalanceVisible
                                  ? formatNumberWithArabicComma(
                                      totals['income']!)
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
// Second Dashboard Layout
  Widget buildSecondDashboard() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildTimePeriodSelector(),
                const SizedBox(),
              ],
            ),
            if (_selectedPeriod == 'اسبوعي') buildWeekNavigationButtons(),
            if (_selectedPeriod == 'شهري') buildMonthNavigationButtons(),
            if (_selectedPeriod == 'سنوي') buildYearNavigationButtons(),
            const SizedBox(height: 10),
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(8.0, 25.0, 8.0, 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 350,
                    child: buildIncomeExpenseGraph(),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 15,
                  child: Text(
                    'تحليل الإنفاق',
                    style: TextStyle(
                      fontFamily: 'GE-SS-Two-Bold',
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            buildStatisticsSummary(),
            const SizedBox(height: 10),
            buildPieChartWithBorder(),
            const SizedBox(height: 10),
            buildCategoryLineChart(),
          ],
        ),
      ),
    );
  }

  // Method to filter transactions based on the selected period
  List<Map<String, dynamic>> _filterTransactionsByPeriod(
      List<dynamic> accounts) {
    List<Map<String, dynamic>> filteredTransactions = [];
    DateTime now = DateTime.now();
    DateTime selectedDate;

    // Determine the selected date based on the desired period
    if (_selectedPeriod == 'اسبوعي') {
      selectedDate = DateTime(2025, now.month - monthOffset, now.day);
    } else if (_selectedPeriod == 'شهري') {
      selectedDate = DateTime(2025, now.month - monthOffset);
    } else if (_selectedPeriod == 'سنوي') {
      selectedDate = DateTime(2025);
    } else {
      return filteredTransactions; // Return empty if no valid period
    }

    for (var account in accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String dateStr = transaction['TransactionDateTime'] ?? '';
        DateTime transactionDate = DateTime.tryParse(dateStr) ?? DateTime.now();

        // Filter based on the selected period
        if (_selectedPeriod == 'اسبوعي' &&
            transactionDate.year == selectedDate.year &&
            transactionDate.month == selectedDate.month &&
            _getWeekOfMonth(transactionDate.day) ==
                _getWeekOfMonth(selectedDate.day)) {
          filteredTransactions.add(transaction);
        } else if (_selectedPeriod == 'شهري' &&
            transactionDate.year == selectedDate.year &&
            transactionDate.month == selectedDate.month) {
          filteredTransactions.add(transaction);
        } else if (_selectedPeriod == 'سنوي' &&
            transactionDate.year == selectedDate.year) {
          filteredTransactions.add(transaction);
        }
      }
    }

    return filteredTransactions;
  }

// Method to calculate category data for the pie chart
  Map<String, double> _calculateCategoryDataForPieChart(
      String period, DateTime selectedDate) {
    // Define a cutoff date based on the current day and month in 2016
    DateTime now = DateTime.now();
    DateTime cutoffDate =
        DateTime(2025, now.month, now.day, now.hour, now.minute, now.second);

    // Aggregate by category
    Map<String, double> categoryTotals = {};

    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String dateStr = transaction['TransactionDateTime'] ?? '';
        DateTime transactionDate = DateTime.tryParse(dateStr) ?? DateTime.now();

        // Skip transactions beyond the cutoff date
        if (transactionDate.isAfter(cutoffDate)) {
          continue;
        }

        // Determine if the transaction falls within the selected period
        bool includeTransaction = false;
        if (period == 'اسبوعي' &&
            transactionDate.year == 2025 &&
            transactionDate.month == selectedDate.month &&
            _getWeekOfMonth(transactionDate.day) ==
                _getWeekOfMonth(selectedDate.day)) {
          includeTransaction = true;
        } else if (period == 'شهري' &&
            transactionDate.year == 2025 &&
            transactionDate.month == selectedDate.month) {
          includeTransaction = true;
        } else if (period == 'سنوي' && transactionDate.year == 2025) {
          includeTransaction = true;
        }

        if (includeTransaction) {
          String subtype =
              transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? '';
          // Consider only expense-related subtypes
          if (['MoneyTransfer', 'Withdrawal', 'Purchase', 'DepositReversal']
              .contains(subtype)) {
            String category = transaction['Category'] ??
                transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
                'غير مصنف';
            double amount =
                double.tryParse(transaction['Amount']?.toString() ?? '0') ??
                    0.0;

            DateTime? transactionDate =
                transaction['TransactionDateTime'] != null
                    ? DateTime.tryParse(transaction['TransactionDateTime'])
                    : null;
            print('Parsed Transaction Date: $transactionDate');
            print(
                'Category Totals: $category amount: $amount date: $transactionDate');
            if (amount > 0.0) {
              categoryTotals[category] =
                  (categoryTotals[category] ?? 0.0) + amount;
            }
          }
        }
      }
    }

    return categoryTotals;
  }
}
