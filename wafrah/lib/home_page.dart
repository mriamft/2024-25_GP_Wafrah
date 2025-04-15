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
import 'global_notification_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For secure storage

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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  Map<String, double> transactionCategories = {};
  final GlobalNotificationManager globalNotificationManager = GlobalNotificationManager();

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  String _selectedPeriod = 'شهري';
  double _filteredIncome = 0.0;
  double _filteredExpense = 0.0;

  int currentPage = 0; // Track the current dashboard
  final PageController _pageController = PageController();
  bool _isCirclePressed = false; // Track if the circle button is pressed
  bool _isBalanceVisible = true; // Default visibility state
  double _minIncome = double.infinity;
  double _maxIncome = double.negativeInfinity;
  double _minExpense = double.infinity;
  double _maxExpense = double.negativeInfinity;
  int _touchedIndex = -1;
List<String> selectedCategories = [];

  List<FlSpot> incomeData = [];
  List<FlSpot> expenseData = [];

  int weekOffset = 0;
  int monthOffset = 0;
  int yearOffset = 0;

  @override
  void initState() {
    super.initState();
    globalNotificationManager.start();

    // After fetching user data and if a saving plan exists, update the manager:
    loadUserPlan().then((planData) {
      if (planData != null) {
        globalNotificationManager.updateData(
          resultData: planData,
          accounts: widget.accounts,
        );
      } else {
        globalNotificationManager.clearData();
      }
    });
    print("Backend response: ${jsonEncode(widget.accounts)}");

    _loadVisibilityState(); // Load saved visibility state

    print('Transaction Categories33: $transactionCategories');

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(begin: const Offset(0, -1), end: const Offset(0, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
    updateDashboardData();
  }

  Future<Map<String, dynamic>?> loadUserPlan() async {
    try {
      final secureStorage = FlutterSecureStorage();
      String? planJson = await secureStorage.read(key: 'savings_plan');
      if (planJson != null) {
        return jsonDecode(planJson) as Map<String, dynamic>;
      } else {
        print('No plan found in secure storage');
        return null;
      }
    } catch (e) {
      print("Error loading plan from secure storage: $e");
      return null;
    }
  }

  Future<void> _loadVisibilityState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBalanceVisible = prefs.getBool('isBalanceVisible') ?? true;
    });
  }

  void navigateToSavingPlan() async {
    var savedPlan = await loadPlanFromSecureStorage();
    if (savedPlan != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => SavingPlanPage2(
            userName: widget.userName,
            phoneNumber: widget.phoneNumber,
            accounts: widget.accounts,
            resultData: savedPlan,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
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
    if (number == null) return '٠،٠٠';
    String formattedNumber = NumberFormat("#,##0.00", "ar").format(number);
    return formattedNumber.replaceAll('.', '،');
  }

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
    _saveVisibilityState(_isBalanceVisible);
  }

  Widget buildTimePeriodSelector() {
    return DropdownButton<String>(
      value: _selectedPeriod,
      items: ['اسبوعي', 'شهري', 'سنوي']
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
          updateDashboardData();
        });
      },
    );
  }

  void updateDashboardData() {
    DateTime now = DateTime.now();
    DateTime selectedDate = DateTime(2025, now.month - monthOffset, now.day);

    incomeData.clear();
    expenseData.clear();

    if (_selectedPeriod == 'سنوي') {
      _calculateMonthlyData(selectedDate);
      calculateStatistics('سنوي', selectedDate);
      transactionCategories = _calculateCategoryDataForPieChart('سنوي', selectedDate);
    } else if (_selectedPeriod == 'شهري') {
      _calculateWeeklyData(selectedDate);
      calculateStatistics('شهري', selectedDate);
      transactionCategories = _calculateCategoryDataForPieChart('شهري', selectedDate);
    } else if (_selectedPeriod == 'اسبوعي') {
      int startDay = ((4 - weekOffset) * 7) - 6;
      int endDay = (4 - weekOffset) * 7;
      DateTime weeklyDate = DateTime(selectedDate.year, selectedDate.month, startDay);
      _calculateDailyData(weeklyDate);
      calculateStatistics('اسبوعي', weeklyDate);
      transactionCategories = _calculateCategoryDataForPieChart('اسبوعي', weeklyDate);
    }
    setState(() {});
  }

  void calculateStatistics(String period, DateTime selectedDate) {
    DateTime now = DateTime.now();
    DateTime cutoffDate = DateTime(2025, now.month, now.day, now.hour, now.minute, now.second);

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
        if (transactionDate.isAfter(cutoffDate)) {
          continue;
        }
        if (period == 'اسبوعي' &&
            transactionDate.year == 2025 &&
            transactionDate.month == selectedDate.month &&
            _getWeekOfMonth(transactionDate.day) == _getWeekOfMonth(selectedDate.day)) {
          includeTransaction = true;
        } else if (period == 'شهري' &&
            transactionDate.year == 2025 &&
            transactionDate.month == selectedDate.month) {
          includeTransaction = true;
        } else if (period == 'سنوي' && transactionDate.year == 2025) {
          includeTransaction = true;
        }
        if (includeTransaction) {
          String subtype = transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? 'غير معروف';
          double amount = double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;
          if (['Deposit', 'WithdrawalReversal', 'Refund'].contains(subtype)) {
            totalIncome += amount;
            incomeCount++;
            _minIncome = amount < _minIncome ? amount : _minIncome;
            _maxIncome = amount > _maxIncome ? amount : _maxIncome;
          } else if (['MoneyTransfer', 'Withdrawal', 'Purchase', 'DepositReversal', 'NotApplicable'].contains(subtype)) {
            totalExpense += amount;
            expenseCount++;
            _minExpense = amount < _minExpense ? amount : _minExpense;
            _maxExpense = amount > _maxExpense ? amount : _maxExpense;
          }
        }
      }
    }

    _filteredIncome = incomeCount > 0 ? totalIncome / incomeCount : 0.0;
    _filteredExpense = expenseCount > 0 ? totalExpense / expenseCount : 0.0;
    _minIncome = _minIncome == double.infinity ? 0.0 : _minIncome;
    _maxIncome = _maxIncome == double.negativeInfinity ? 0.0 : _maxIncome;
    _minExpense = _minExpense == double.infinity ? 0.0 : _minExpense;
    _maxExpense = _maxExpense == double.negativeInfinity ? 0.0 : _maxExpense;

    setState(() {});
  }

  void _calculateWeeklyData(DateTime currentDate) {
    DateTime now = DateTime.now();
    DateTime cutoffDate = currentDate.month == now.month && currentDate.year == now.year
        ? DateTime(currentDate.year, currentDate.month, now.day)
        : DateTime(currentDate.year, currentDate.month + 1, 0);

    Map<int, double> weeklyIncome = {};
    Map<int, double> weeklyExpense = {};

    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String dateStr = transaction['TransactionDateTime'] ?? '';
        DateTime transactionDate = DateTime.tryParse(dateStr) ?? DateTime.now();
        if (transactionDate.year == currentDate.year &&
            transactionDate.month == currentDate.month &&
            transactionDate.isBefore(cutoffDate)) {
          int week = ((transactionDate.day - 1) / 7).floor();
          double amount = double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;
          String type = transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? '';
          if (['Deposit', 'WithdrawalReversal', 'Refund'].contains(type)) {
            weeklyIncome[week] = (weeklyIncome[week] ?? 0.0) + amount;
          } else if (['MoneyTransfer', 'Withdrawal', 'Purchase', 'DepositReversal', 'NotApplicable'].contains(type)) {
            weeklyExpense[week] = (weeklyExpense[week] ?? 0.0) + amount;
          }
        }
      }
    }

    incomeData = List.generate(4, (i) => FlSpot(i.toDouble(), weeklyIncome[i] ?? 0.0));
    expenseData = List.generate(4, (i) => FlSpot(i.toDouble(), weeklyExpense[i] ?? 0.0));

    print('Weekly Income Data: $weeklyIncome');
    print('Weekly Expense Data: $weeklyExpense');
  }

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
      return transactionDate.weekday - 1;
    } else if (_selectedPeriod == 'شهري') {
      return _getWeekOfMonth(transactionDate.day) - 1;
    } else if (_selectedPeriod == 'سنوي') {
      return transactionDate.month - 1;
    }
    return -1;
  }
Widget buildCategoryLineChart() {
  // Predefined mapping of category names to colors.
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

  // Calculate the list of all categories with nonzero totals from your transactionCategories.
  List<String> allUsedCategories = transactionCategories.entries
      .where((entry) => entry.value > 0)
      .map((entry) => entry.key)
      .toList();

  // If no category is selected yet, default to all used categories.
  if (selectedCategories.isEmpty) {
    selectedCategories = List.from(allUsedCategories);
  }

  // Build filter chips with colored borders and selected backgrounds.
  Widget categoryFilterChips = SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: allUsedCategories.map((cat) {
        bool isSelected = selectedCategories.contains(cat);
        // Determine the color for the category.
        Color chipColor = categoryColors[cat] ?? Colors.grey;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: FilterChip(
            label: Text(
              cat,
              style: const TextStyle(fontFamily: 'GE-SS-Two-Light'),
            ),
            backgroundColor: Colors.white,
            selectedColor: chipColor.withOpacity(0.3), // light tint when selected
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: chipColor), // border in category color
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedCategories.add(cat);
                } else {
                  selectedCategories.remove(cat);
                }
              });
            },
          ),
        );
      }).toList(),
    ),
  );

  // Determine the number of intervals and x-axis labels based on the period.
  int numIntervals;
  List<String> xAxisLabels;
  if (_selectedPeriod == 'اسبوعي') {
    numIntervals = 7;
    xAxisLabels = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
  } else if (_selectedPeriod == 'شهري') {
    numIntervals = 4;
    xAxisLabels = ['الأسبوع 1', 'الأسبوع 2', 'الأسبوع 3', 'الأسبوع 4'];
  } else if (_selectedPeriod == 'سنوي') {
    numIntervals = 12;
    xAxisLabels = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
  } else {
    numIntervals = 0;
    xAxisLabels = [];
  }

  // Map each selected category to its color.
  Map<String, Color> filteredCategoryColors = {};
  for (var cat in selectedCategories) {
    filteredCategoryColors[cat] = categoryColors[cat] ?? Colors.grey;
  }

  // Use the same cutoff logic as before.
  DateTime now = DateTime.now();
  DateTime selectedDate = DateTime(2025, now.month - monthOffset, now.day);

  // Compute the maximum Y value across the selected categories.
  double computedMaxY = 0;
  for (var cat in selectedCategories) {
    List<double> catValues = _calculateCategoryData(_selectedPeriod, selectedDate, cat);
    for (var value in catValues) {
      if (value > computedMaxY) computedMaxY = value;
    }
  }
  if (computedMaxY > 0) computedMaxY *= 1.1;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      categoryFilterChips,
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
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
          height: 300,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: computedMaxY,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
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
                    getTitlesWidget: (value, meta) {
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
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((touchedSpot) {
                      // Map bar index to category using the order in filteredCategoryColors.
                      List<String> dispCats = filteredCategoryColors.keys.toList();
                      String catName = dispCats[touchedSpot.barIndex];
                      return LineTooltipItem(
                        '$catName: ${touchedSpot.y.toStringAsFixed(2)}',
                        const TextStyle(
                          fontSize: 12,
                          fontFamily: 'GE-SS-Two-Light',
                          color: Colors.black,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              // Generate a line for each selected category.
              lineBarsData: filteredCategoryColors.entries.map((entry) {
                String cat = entry.key;
                Color lineColor = entry.value;
                List<double> catValues = _calculateCategoryData(_selectedPeriod, selectedDate, cat);
                List<FlSpot> spots = [];
                for (int i = 0; i < catValues.length; i++) {
                  spots.add(FlSpot(i.toDouble(), catValues[i]));
                }
                return LineChartBarData(
                  spots: spots,
                  isCurved: false,
                  color: lineColor,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (FlSpot spot, double percent, LineChartBarData barData, int index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: lineColor,
                        strokeWidth: 0,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: lineColor.withOpacity(0.4),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    ],
  );
}
/// Returns a list of double values representing expense totals for the given [category]
/// grouped according to the [period] over the [selectedDate] timeline.
///
/// For period:
/// - 'سنوي': Groups by month (0 to currentMonth-1)
/// - 'شهري': Groups by week within the month (0 to 3)
/// - 'اسبوعي': Groups by day within the selected week
List<double> _calculateCategoryData(String period, DateTime selectedDate, String category) {
  // We'll accumulate totals in different buckets.
  if (period == 'سنوي') {
    // Yearly: Group by month. (Mimic _calculateMonthlyData)
    DateTime now = DateTime.now();
    DateTime cutoffDate = DateTime(now.year, now.month, now.day);
    Map<int, double> monthlyTotals = {};
    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var tx in transactions) {
        String dateStr = tx['TransactionDateTime'] ?? '';
        DateTime? txDate = DateTime.tryParse(dateStr);
        if (txDate == null) continue;
        // Skip transactions after the cutoff.
        if (txDate.isAfter(cutoffDate)) continue;
        // Only consider transactions in the given year.
        if (txDate.year != selectedDate.year) continue;
        String txCategory = tx['Category'] ??
            tx['SubTransactionType']?.replaceAll('KSAOB.', '') ??
            'غير مصنف';
        // Only process expense transactions.
        if (!['MoneyTransfer', 'Withdrawal', 'Purchase', 'DepositReversal', 'NotApplicable']
            .contains(tx['SubTransactionType']?.replaceAll('KSAOB.', '') ?? '')) {
          continue;
        }
        // Only add if the transaction category matches.
        if (txCategory != category) continue;
        int monthIndex = txDate.month - 1;
        monthlyTotals[monthIndex] = (monthlyTotals[monthIndex] ?? 0.0) +
            (double.tryParse(tx['Amount']?.toString() ?? '0') ?? 0.0);
      }
    }
    int currentMonthIndex = now.month - 1;
    List<double> result = List.filled(currentMonthIndex + 1, 0.0);
    for (int i = 0; i <= currentMonthIndex; i++) {
      result[i] = monthlyTotals[i] ?? 0.0;
    }
    return result;
  } else if (period == 'شهري') {
    // Monthly: Group by week in the month. (Mimic _calculateWeeklyData)
    DateTime now = DateTime.now();
    // If we're in the current month, cutoff is today; otherwise, use the end of the month.
    DateTime cutoffDate = (selectedDate.month == now.month && selectedDate.year == now.year)
        ? DateTime(selectedDate.year, selectedDate.month, now.day)
        : DateTime(selectedDate.year, selectedDate.month + 1, 0);
    Map<int, double> weeklyTotals = {};
    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var tx in transactions) {
        String dateStr = tx['TransactionDateTime'] ?? '';
        DateTime? txDate = DateTime.tryParse(dateStr);
        if (txDate == null) continue;
        if (txDate.isAfter(cutoffDate)) continue;
        if (!(txDate.year == selectedDate.year && txDate.month == selectedDate.month))
          continue;
        String txCategory = tx['Category'] ??
            tx['SubTransactionType']?.replaceAll('KSAOB.', '') ??
            'غير مصنف';
        if (!['MoneyTransfer', 'Withdrawal', 'Purchase', 'DepositReversal', 'NotApplicable']
            .contains(tx['SubTransactionType']?.replaceAll('KSAOB.', '') ?? '')) {
          continue;
        }
        if (txCategory != category) continue;
        int weekIndex = ((txDate.day - 1) / 7).floor(); // gives 0, 1, 2, or 3
        weeklyTotals[weekIndex] = (weeklyTotals[weekIndex] ?? 0.0) +
            (double.tryParse(tx['Amount']?.toString() ?? '0') ?? 0.0);
      }
    }
    // There are 4 weeks in a month.
    List<double> result = List.filled(4, 0.0);
    for (int i = 0; i < 4; i++) {
      result[i] = weeklyTotals[i] ?? 0.0;
    }
    return result;
  } else if (period == 'اسبوعي') {
    // Weekly: Group by day in the selected week. (Mimic _calculateDailyData)
    DateTime now = DateTime.now();
    // Determine cutoff: if we're in current month, cutoff is now; otherwise, last day of the month.
    DateTime cutoffDate = (selectedDate.month == now.month)
        ? DateTime(2025, now.month, now.day, now.hour, now.minute, now.second)
        : DateTime(2025, selectedDate.month + 1, 1, now.hour, now.minute, now.second)
            .subtract(const Duration(days: 1));
    // The income/expense logic used weekOffset to determine the selected week.
    int selectedWeek = 4 - (weekOffset % 4);
    int startDay = (selectedWeek - 1) * 7 + 1;
    int endDay = selectedWeek * 7;
    Map<int, double> dailyTotals = { for (int i = startDay; i <= endDay; i++) i: 0.0 };
    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var tx in transactions) {
        String dateStr = tx['TransactionDateTime'] ?? '';
        DateTime? txDate = DateTime.tryParse(dateStr);
        if (txDate == null) continue;
        // Only consider transactions in 2025 for the current selected month and within the selected week.
        if (!(txDate.year == 2025 &&
            txDate.month == selectedDate.month &&
            txDate.day >= startDay &&
            txDate.day <= endDay))
          continue;
        if (!txDate.isBefore(cutoffDate)) continue;
        String txCategory = tx['Category'] ??
            tx['SubTransactionType']?.replaceAll('KSAOB.', '') ??
            'غير مصنف';
        if (!['MoneyTransfer', 'Withdrawal', 'Purchase', 'DepositReversal', 'NotApplicable']
            .contains(tx['SubTransactionType']?.replaceAll('KSAOB.', '') ?? '')) {
          continue;
        }
        if (txCategory != category) continue;
        int day = txDate.day;
        dailyTotals[day] = (dailyTotals[day] ?? 0) +
            (double.tryParse(tx['Amount']?.toString() ?? '0') ?? 0.0);
      }
    }
    // Construct a list for each day (x coordinate 0-based)
    List<double> result = [];
    for (int i = startDay; i <= endDay; i++) {
      result.add(dailyTotals[i] ?? 0.0);
    }
    return result;
  }
  return [];
}


  void _calculateMonthlyData(DateTime currentDate) {
    DateTime now = DateTime.now();
    DateTime cutoffDate = DateTime(now.year, now.month, now.day);

    Map<int, double> monthlyIncome = {};
    Map<int, double> monthlyExpense = {};

    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String dateStr = transaction['TransactionDateTime'] ?? '';
        DateTime transactionDate = DateTime.tryParse(dateStr) ?? DateTime.now();
        if (transactionDate.isBefore(cutoffDate) || transactionDate.isAtSameMomentAs(cutoffDate)) {
          if (transactionDate.year == currentDate.year) {
            int month = transactionDate.month - 1;
            double amount = double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;
            String type = transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? '';
            if (['Deposit', 'WithdrawalReversal', 'Refund'].contains(type)) {
              monthlyIncome[month] = (monthlyIncome[month] ?? 0.0) + amount;
            } else if (['MoneyTransfer', 'Withdrawal', 'Purchase', 'DepositReversal', 'NotApplicable'].contains(type)) {
              monthlyExpense[month] = (monthlyExpense[month] ?? 0.0) + amount;
            }
          }
        }
      }
    }

    incomeData = List.generate(12, (i) => FlSpot(i.toDouble(), monthlyIncome[i] ?? 0.0));
    expenseData = List.generate(12, (i) => FlSpot(i.toDouble(), monthlyExpense[i] ?? 0.0));

    int currentMonthIndex = now.month - 1;
    incomeData = incomeData.where((spot) => spot.x <= currentMonthIndex.toDouble()).toList();
    expenseData = expenseData.where((spot) => spot.x <= currentMonthIndex.toDouble()).toList();

    setState(() {});
  }

  void _calculateDailyData(DateTime currentDate) {
    DateTime now = DateTime.now();
    DateTime cutoffDate = (currentDate.month == now.month)
        ? DateTime(2025, now.month, now.day, now.hour, now.minute, now.second)
        : DateTime(2025, currentDate.month + 1, 1, now.hour, now.minute, now.second).subtract(const Duration(days: 1));

    int selectedWeek = 4 - (weekOffset % 4);
    int startDay = (selectedWeek - 1) * 7 + 1;
    int endDay = selectedWeek * 7;

    Map<int, double> dailyIncome = { for (int i = startDay; i <= endDay; i++) i: 0.0 };
    Map<int, double> dailyExpense = { for (int i = startDay; i <= endDay; i++) i: 0.0 };

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
          double amount = double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;
          String type = transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? '';
          if (['Deposit', 'WithdrawalReversal', 'Refund'].contains(type)) {
            dailyIncome[day] = (dailyIncome[day] ?? 0.0) + amount;
          } else if (['MoneyTransfer', 'Withdrawal', 'Purchase', 'DepositReversal', 'NotApplicable'].contains(type)) {
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
    DateTime currentDate = DateTime(2025, DateTime.now().month - monthOffset, 1);
    String monthName = getMonthName(currentDate.month);
    return '$monthName 2025 - الأسبوع $currentWeek';
  }

  Widget buildDailyNavigationButtons() {
    bool disableLeft = weekOffset >= 3;
    bool disableRight = weekOffset <= 0;
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

  String getMonthName(int month) {
    switch (month) {
      case 1: return 'يناير';
      case 2: return 'فبراير';
      case 3: return 'مارس';
      case 4: return 'أبريل';
      case 5: return 'مايو';
      case 6: return 'يونيو';
      case 7: return 'يوليو';
      case 8: return 'أغسطس';
      case 9: return 'سبتمبر';
      case 10: return 'أكتوبر';
      case 11: return 'نوفمبر';
      case 12: return 'ديسمبر';
      default: return '';
    }
  }

  Widget buildWeekNavigationButtons() {
    DateTime now = DateTime.now();
    DateTime selectedDate = DateTime(2025, now.month - monthOffset, 1);
    bool isCurrentMonth = selectedDate.month == now.month && selectedDate.year == now.year;
    int currentWeekInMonth = ((now.day - 1) / 7).floor() + 1;
    int displayedWeek = 4 - weekOffset;
    bool disableLeft = displayedWeek == 1;
    bool disableRight = isCurrentMonth ? (displayedWeek >= currentWeekInMonth) : (displayedWeek == 4);
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
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int displayedMonth = currentMonth - monthOffset;
    bool disableLeft = displayedMonth == 1;
    bool disableRight = displayedMonth == currentMonth;
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
          getLocalizedMonthName(displayedMonth),
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

  Widget buildYearNavigationButtons() {
    DateTime now = DateTime.now();
    DateTime modifiedDate = DateTime(now.year);
    int mappedYear = getMappedYear(modifiedDate);
    return Center(
      child: Text(
        mappedYear.toString(),
        style: TextStyle(
          fontFamily: 'GE-SS-Two-Light',
          fontSize: 16,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  int getMappedYear(DateTime date) {
    if (date.year == 2025) {
      return 2025;
    } else if (date.year == 2025) {
      return 2025;
    }
    return date.year;
  }

  // ----------------------------
  // UPDATED: buildIncomeExpenseGraph()
  // ----------------------------
  Widget buildIncomeExpenseGraph() {
    double maxIncome = incomeData.isNotEmpty
        ? incomeData.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0.0;
    double maxExpense = expenseData.isNotEmpty
        ? expenseData.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0.0;
    double highestValue = maxIncome > maxExpense ? maxIncome : maxExpense;
    double maxY = highestValue <= 1000
        ? (highestValue / 100).ceil() * 100
        : (highestValue / 1000).ceil() * 1000;
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
                maxY: maxY,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: interval,
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
lineTouchData: LineTouchData(
  enabled: true,
  touchTooltipData: LineTouchTooltipData(
    tooltipRoundedRadius: 8,
    tooltipPadding: const EdgeInsets.all(8),
    getTooltipItems: (touchedSpots) {
      return touchedSpots.map((touchedSpot) {
        // Use the available 'color' property from LineChartBarData
        final barData = touchedSpot.bar as LineChartBarData;
        final barColor = barData.color ?? Colors.white;
        final seriesName = touchedSpot.barIndex == 0 ? 'الدخل' : 'الصرف';
        return LineTooltipItem(
          '$seriesName: ${touchedSpot.y.toStringAsFixed(2)}',
          TextStyle(
            color: barColor,
            fontSize: 12,
            fontFamily: 'GE-SS-Two-Light',
          ),
        );
      }).toList();
    },
  ),
),
                lineBarsData: [
                  LineChartBarData(
                    spots: incomeData,
                    isCurved: false,
                    color: Colors.green,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.4),
                    ),
                  ),
                  LineChartBarData(
                    spots: expenseData,
                    isCurved: false,
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
                  Container(width: 10, height: 10, color: Colors.green),
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
                  Container(width: 10, height: 10, color: Colors.red),
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
  // ----------------------------
  // END UPDATED: buildIncomeExpenseGraph()
  // ----------------------------

  List<FlSpot> _generateIncomeData() {
    List<FlSpot> incomeSpots = [];
    Map<int, double> monthlyIncome = {};
    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String? dateStr = transaction['TransactionDateTime'];
        if (dateStr != null) {
          DateTime transactionDate = DateTime.tryParse(dateStr) ?? DateTime.now();
          int month = transactionDate.month - 1;
          String subtype = transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? 'غير معروف';
          double amount = double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;
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
    Map<int, double> monthlyExpense = {};
    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String? dateStr = transaction['TransactionDateTime'];
        if (dateStr != null) {
          DateTime transactionDate = DateTime.tryParse(dateStr) ?? DateTime.now();
          int month = transactionDate.month - 1;
          String subtype = transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? 'غير معروف';
          double amount = double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;
          if (['MoneyTransfer', 'Withdrawal', 'Purchase', 'DepositReversal', 'NotApplicable'].contains(subtype)) {
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
        String subtype = transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? 'غير معروف';
        double amount = double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;
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
        String subtype = transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? 'غير معروف';
        double amount = double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;
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
        String subtype = transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? 'غير معروف';
        double amount = double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;
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
        String subtype = transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? 'غير معروف';
        double amount = double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;
        if (['MoneyTransfer', 'Withdrawal', 'Purchase', 'DepositReversal', 'NotApplicable'].contains(subtype)) {
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
        String subtype = transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? 'غير معروف';
        double amount = double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;
        if (['MoneyTransfer', 'Withdrawal', 'Purchase', 'DepositReversal', 'NotApplicable'].contains(subtype)) {
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
        String subtype = transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? 'غير معروف';
        double amount = double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;
        if (['MoneyTransfer', 'Withdrawal', 'Purchase', 'DepositReversal', 'NotApplicable'].contains(subtype)) {
          totalExpense += amount;
          count++;
        }
      }
    }
    return count == 0 ? 0.0 : totalExpense / count;
  }

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
                      formatNumberWithArabicComma(_minIncome),
                      style: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                      textAlign: TextAlign.right,
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
                      formatNumberWithArabicComma(_minExpense),
                      style: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 12,
                        color: Colors.red[700],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
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
                      formatNumberWithArabicComma(_maxIncome),
                      style: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                      textAlign: TextAlign.right,
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
                      formatNumberWithArabicComma(_maxExpense),
                      style: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 12,
                        color: Colors.red[700],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
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
                      formatNumberWithArabicComma(_filteredIncome),
                      style: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                      textAlign: TextAlign.right,
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
                      formatNumberWithArabicComma(_filteredExpense),
                      style: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 12,
                        color: Colors.red[700],
                      ),
                      textAlign: TextAlign.right,
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

  Widget buildPieChart() {
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

    double total = transactionCategories.values.reduce((a, b) => a + b);

    return PieChart(
      PieChartData(
        sections: transactionCategories.entries.map((entry) {
          final index = transactionCategories.keys.toList().indexOf(entry.key);
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
              _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
      ),
    );
  }

  Widget buildPieChartWithBorder() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'تصنيف عمليات الصرف',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'GE-SS-Two-Bold',
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 0),
          SizedBox(
            height: 285,
            child: buildPieChart(),
          ),
        ],
      ),
    );
  }

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

  List<Color> generateDynamicGreenShades(int count) {
    List<Color> baseColors = [
      const Color(0xFFF4D968),
      const Color(0xFF92A662),
      const Color(0xFF2C8C68),
      const Color(0xFF1C5B42),
    ];

    if (count <= baseColors.length) {
      return baseColors.sublist(0, count);
    }

    List<Color> greenShades = [];
    double step = (baseColors.length - 1) / (count - 1);
    for (int i = 0; i < count; i++) {
      double position = i * step;
      int startIndex = position.floor();
      int endIndex = (startIndex + 1).clamp(0, baseColors.length - 1);
      double t = position - startIndex;
      Color startColor = baseColors[startIndex];
      Color endColor = baseColors[endIndex];
      int red = (startColor.red + (endColor.red - startColor.red) * t).toInt();
      int green = (startColor.green + (endColor.green - startColor.green) * t).toInt();
      int blue = (startColor.blue + (endColor.blue - startColor.blue) * t).toInt();
      greenShades.add(Color.fromARGB(255, red, green, blue));
    }
    return greenShades;
  }

  Widget buildBarChart() {
    Map<String, double> categoryData = _calculateCategoryExpenses();
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
                return Text(category, style: const TextStyle(fontSize: 10, fontFamily: 'GE-SS-Two-Light'));
              },
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateSpotsForIncome() {
    List<FlSpot> incomeSpots = [];
    return incomeSpots;
  }

  List<FlSpot> _generateSpotsForExpense() {
    List<FlSpot> expenseSpots = [];
    return expenseSpots;
  }

  Map<String, double> _calculateCategoryExpenses() {
    Map<String, double> categoryExpenses = {};
    return categoryExpenses;
  }

  String getMaskedValue() => '****';

  String getTotalBalance() {
    double totalBalance = widget.accounts.fold(0.0, (sum, account) {
      return sum + double.parse(account['Balance'] ?? '0');
    });
    return totalBalance.toStringAsFixed(2);
  }

  Map<String, double> calculateIncomeAndExpense() {
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime today = DateTime(now.year, now.month, now.day);
    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String? dateStr = transaction['TransactionDateTime'];
        DateTime transactionDate = DateTime.tryParse(dateStr ?? '') ?? DateTime.now();
        if (transactionDate.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            transactionDate.isBefore(today.add(const Duration(days: 1)))) {
          String subtype = transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? 'غير معروف';
          double amount = double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;
          if (['Deposit', 'WithdrawalReversal', 'Refund'].contains(subtype)) {
            totalIncome += amount;
          } else if (['MoneyTransfer', 'Withdrawal', 'Purchase', 'DepositReversal', 'NotApplicable'].contains(subtype)) {
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
                  buildBottomNavItem(Icons.settings_outlined, "إعدادات", 0, onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SettingsPage(userName: widget.userName, phoneNumber: widget.phoneNumber, accounts: widget.accounts),
                        transitionDuration: const Duration(seconds: 0),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                      ),
                      (route) => false,
                    );
                  }),
                  buildBottomNavItem(Icons.credit_card, "سجل المعاملات", 1, onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            TransactionsPage(userName: widget.userName, phoneNumber: widget.phoneNumber, accounts: widget.accounts),
                        transitionDuration: const Duration(seconds: 0),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
                              BanksPage(userName: widget.userName, phoneNumber: widget.phoneNumber, accounts: widget.accounts),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  buildBottomNavItem(Icons.calendar_today, "خطة الإدخار", 3, onTap: navigateToSavingPlan),
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
                            : [const Color(0xFF2C8C68), const Color(0xFF8FD9BD)],
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

  Widget buildDot(int pageIndex) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: currentPage == pageIndex ? const Color(0xFF2C8C68) : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

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

  Widget buildFirstDashboard(double totalIncome, double totalExpense) {
    Map<String, double> totals = calculateIncomeAndExpense();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
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
                            ? formatNumberWithArabicComma(double.parse(getTotalBalance()))
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
                    Column(
                      children: [
                        const Icon(Icons.arrow_downward, color: Colors.red, size: 24),
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
                            const Icon(CustomIcons.riyal, size: 14, color: Colors.black),
                            const SizedBox(width: 5),
                            Text(
                              _isBalanceVisible
                                  ? formatNumberWithArabicComma(totals['expense']!)
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
                        const Icon(Icons.arrow_upward, color: Colors.green, size: 24),
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
                            const Icon(CustomIcons.riyal, size: 14, color: Colors.black),
                            const SizedBox(width: 5),
                            Text(
                              _isBalanceVisible
                                  ? formatNumberWithArabicComma(totals['income']!)
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

  List<Map<String, dynamic>> _filterTransactionsByPeriod(List<dynamic> accounts) {
    List<Map<String, dynamic>> filteredTransactions = [];
    DateTime now = DateTime.now();
    DateTime selectedDate;
    if (_selectedPeriod == 'اسبوعي') {
      selectedDate = DateTime(2025, now.month - monthOffset, now.day);
    } else if (_selectedPeriod == 'شهري') {
      selectedDate = DateTime(2025, now.month - monthOffset);
    } else if (_selectedPeriod == 'سنوي') {
      selectedDate = DateTime(2025);
    } else {
      return filteredTransactions;
    }
    for (var account in accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String dateStr = transaction['TransactionDateTime'] ?? '';
        DateTime transactionDate = DateTime.tryParse(dateStr) ?? DateTime.now();
        if (_selectedPeriod == 'اسبوعي' &&
            transactionDate.year == selectedDate.year &&
            transactionDate.month == selectedDate.month &&
            _getWeekOfMonth(transactionDate.day) == _getWeekOfMonth(selectedDate.day)) {
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

  Map<String, double> _calculateCategoryDataForPieChart(String period, DateTime selectedDate) {
    DateTime now = DateTime.now();
    DateTime cutoffDate = DateTime(2025, now.month, now.day, now.hour, now.minute, now.second);
    Map<String, double> categoryTotals = {};
    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String dateStr = transaction['TransactionDateTime'] ?? '';
        DateTime transactionDate = DateTime.tryParse(dateStr) ?? DateTime.now();
        if (transactionDate.isAfter(cutoffDate)) {
          continue;
        }
        bool includeTransaction = false;
        if (period == 'اسبوعي' &&
            transactionDate.year == 2025 &&
            transactionDate.month == selectedDate.month &&
            _getWeekOfMonth(transactionDate.day) == _getWeekOfMonth(selectedDate.day)) {
          includeTransaction = true;
        } else if (period == 'شهري' &&
            transactionDate.year == 2025 &&
            transactionDate.month == selectedDate.month) {
          includeTransaction = true;
        } else if (period == 'سنوي' && transactionDate.year == 2025) {
          includeTransaction = true;
        }
        if (includeTransaction) {
          String subtype = transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? '';
          if (['MoneyTransfer', 'Withdrawal', 'Purchase', 'DepositReversal'].contains(subtype)) {
            String category = transaction['Category'] ?? transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? 'غير مصنف';
            double amount = double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;
            if (amount > 0.0) {
              categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
            }
          }
        }
      }
    }
    return categoryTotals;
  }
}
