import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'transactions_page.dart';
import 'saving_plan_page.dart';
import 'banks_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
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
  int currentPage = 0;
  final PageController _pageController = PageController();
  bool _isCirclePressed = false;
  // To track toggle visibility
  bool _isBalanceVisible = true;
  double _minIncome = double.infinity;
  double _maxIncome = double.negativeInfinity;
  double _minExpense = double.infinity;
  double _maxExpense = double.negativeInfinity;
  int _touchedIndex = -1;
 
//2024 instead of 2016
  int getMappedYear(DateTime date) {
    if (date.year == 2016) {
      return 2024;
    } else if (date.year == 2017) {
      return 2025;
    }
    return date.year;
  }
 
  @override
  @override
  void initState() {
    super.initState();
    _loadVisibilityState();
 
    // Log the transaction categories to verify the data
    print('Transaction Categories33: $transactionCategories');
 
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: const Offset(0, 0))
            .animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
 
    // Start the welcoming when the page is opened
    _controller.forward();
 
    updateDashboardData();
  }
 
  // Load the saved visibility state
  Future<void> _loadVisibilityState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBalanceVisible =
          prefs.getBool('isBalanceVisible') ?? true; // Default is true
    });
  }
 
  // Save the visibility state
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
 
//cover the balance data for security
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
          updateDashboardData(); // Refresh data based on selected period
        });
      },
    );
  }
 
  List<FlSpot> incomeData = [];
  List<FlSpot> expenseData = [];
 
  void updateDashboardData() {
    DateTime now = DateTime.now();
    DateTime selectedDate = DateTime(2016, now.month - monthOffset, now.day);
 
    // Clear existing data
    incomeData.clear();
    expenseData.clear();
 
    if (_selectedPeriod == 'سنوي') {
      _calculateMonthlyData(selectedDate);
      calculateStatistics('سنوي', selectedDate);
      transactionCategories =
          _calculateCategoryDataForPieChart('سنوي', selectedDate);
    } else if (_selectedPeriod == 'شهري') {
      _calculateWeeklyData(selectedDate);
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
        DateTime(2016, now.month, now.day, now.hour, now.minute, now.second);
 
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
            transactionDate.year == 2016 &&
            transactionDate.month == selectedDate.month &&
            _getWeekOfMonth(transactionDate.day) ==
                _getWeekOfMonth(selectedDate.day)) {
          includeTransaction = true;
        } else if (period == 'شهري' &&
            transactionDate.year == 2016 &&
            transactionDate.month == selectedDate.month) {
          includeTransaction = true;
        } else if (period == 'سنوي' && transactionDate.year == 2016) {
          includeTransaction = true;
        }
 
        if (includeTransaction) {
          String subtype =
              transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
                  'غير معروف';
          double amount =
              double.tryParse(transaction['Amount']?['Amount'] ?? '0') ?? 0.0;
 
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
    // Create a cutoff date only for the current month and year in 2016
    DateTime cutoffDate;
    if (currentDate.month == now.month && currentDate.year == 2016) {
      cutoffDate =
          DateTime(2016, now.month, now.day, now.hour, now.minute, now.second);
    } else {
      cutoffDate = DateTime(2016, currentDate.month + 1, 0);
    }
 
    Map<int, double> weeklyIncome = {for (int i = 0; i < 4; i++) i: 0.0};
    Map<int, double> weeklyExpense = {for (int i = 0; i < 4; i++) i: 0.0};
 
    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String dateStr = transaction['TransactionDateTime'] ?? '';
        DateTime transactionDate = DateTime.tryParse(dateStr) ?? DateTime.now();
 
        if (transactionDate.year == 2016 &&
            transactionDate.month == currentDate.month &&
            transactionDate.isBefore(cutoffDate)) {
          int week = ((transactionDate.day - 1) / 7).floor();
          double amount =
              double.tryParse(transaction['Amount']['Amount'] ?? '0') ?? 0.0;
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
 
    // Update chart data with calculated values
    incomeData.clear();
    expenseData.clear();
    for (int i = 0; i < 4; i++) {
      incomeData.add(FlSpot(i.toDouble(), weeklyIncome[i] ?? 0.0));
      expenseData.add(FlSpot(i.toDouble(), weeklyExpense[i] ?? 0.0));
    }
 
    setState(() {});
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
 
// Monthly data calculation
  void _calculateMonthlyData(DateTime currentDate) {
    // Define the current date and a cutoff date based on the current month
    DateTime now = DateTime.now();
    DateTime cutoffDate = DateTime(2016, now.month, 1, now.hour, now.minute, now.second)
            .subtract(const Duration(days: 1));
 
    Map<int, double> monthlyIncome = {for (int i = 0; i < 12; i++) i: 0.0};
    Map<int, double> monthlyExpense = {for (int i = 0; i < 12; i++) i: 0.0};
 
    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String dateStr = transaction['TransactionDateTime'] ?? '';
        DateTime transactionDate = DateTime.tryParse(dateStr) ?? DateTime.now();
 
        if (transactionDate.year == 2016 &&
            transactionDate.isBefore(cutoffDate)) {
          int month = transactionDate.month - 1;
          double amount =
              double.tryParse(transaction['Amount']['Amount'] ?? '0') ?? 0.0;
          String type =
              transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? '';
 
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
 
    incomeData.clear();
    expenseData.clear();
 
    for (int i = 0; i < 12; i++) {
      if (i < now.month - 1) {
        // months before the current month
        incomeData.add(FlSpot(i.toDouble(), monthlyIncome[i] ?? 0.0));
        expenseData.add(FlSpot(i.toDouble(), monthlyExpense[i] ?? 0.0));
      } else {
        // current and future months
        incomeData.add(FlSpot(i.toDouble(), 0.0));
        expenseData.add(FlSpot(i.toDouble(), 0.0));
      }
    }
 
    setState(() {});
  }
 
  int weekOffset = 0;
  int monthOffset = 0;
  int yearOffset = 0;
 
  void _calculateDailyData(DateTime currentDate) {
    DateTime now = DateTime.now();
    DateTime cutoffDate = (currentDate.month == now.month)
        ? DateTime(2016, now.month, now.day, now.hour, now.minute, now.second)
        : DateTime(2016, currentDate.month + 1, 1, now.hour, now.minute,
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
 
        if (transactionDate.year == 2016 &&
            transactionDate.month == currentDate.month &&
            transactionDate.day >= startDay &&
            transactionDate.day <= endDay &&
            transactionDate.isBefore(cutoffDate)) {
          int day = transactionDate.day;
          double amount =
              double.tryParse(transaction['Amount']['Amount'] ?? '0') ?? 0.0;
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
        DateTime(2016, DateTime.now().month - monthOffset, 1);
    String monthName = getMonthName(currentDate.month);
    return '$monthName 2024 - الأسبوع $currentWeek';
  }
 
  Widget buildDailyNavigationButtons() {
    bool disableLeft = weekOffset >= 3; // Reached the beginning of the month
    bool disableRight = weekOffset <= 0; // Reached the current week in the current month
 
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
    DateTime selectedDate = DateTime(2016, now.month - monthOffset, 1);
    bool isCurrentMonth =
        selectedDate.month == now.month && selectedDate.year == now.year;
 
    // Getting the current week number based on today's date
    int currentWeekInMonth = ((now.day - 1) / 7).floor() + 1;
    int displayedWeek = 4 - weekOffset;
 
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
    DateTime targetMonth = DateTime(2016, DateTime.now().month - monthOffset);
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
          getLocalizedMonthName(
              displayedMonth),
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
 
  String getCurrentYear() {
    int baseYear = 2016 - yearOffset;
    return getMappedYear(DateTime(baseYear)).toString();
  }
 
  Widget buildYearNavigationButtons() {
    DateTime now = DateTime.now();
    int mappedYear = getMappedYear(DateTime(2016 - yearOffset));
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: 250,
            padding: const EdgeInsets.all(8.0),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 400,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 25,
                      interval: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontFamily: 'GE-SS-Two-Light',
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
 
                        // Determine the labels based on the selected period
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
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Transform.rotate(
                              angle: _selectedPeriod == 'سنوي'
                                  ? -0.4
                                  : 0.0,
                              child: Text(
                                labels[index],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'GE-SS-Two-Light',
                                  color: Colors.grey[600],
                                ),
                              ),
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
                  horizontalInterval: 50,
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
                        show: true, color: Colors.green.withOpacity(0.4)),
                  ),
                  LineChartBarData(
                    spots: expenseData,
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                        show: true, color: Colors.red.withOpacity(0.3)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Legend for Income
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'الدخل',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'GE-SS-Two-Light',
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Legend for Expense
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'الصرف',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'GE-SS-Two-Light',
                      color: Colors.grey[800],
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
    Map<int, double> monthlyIncome = {};
 
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
          String amountStr = transaction['Amount']?['Amount'] ?? '0.00';
          double amount = double.tryParse(amountStr) ?? 0.0;
 
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
          DateTime transactionDate =
              DateTime.tryParse(dateStr) ?? DateTime.now();
          int month = transactionDate.month - 1;
          String subtype =
              transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
                  'غير معروف';
          String amountStr = transaction['Amount']?['Amount'] ?? '0.00';
          double amount = double.tryParse(amountStr) ?? 0.0;
 
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
        String amountStr = transaction['Amount']?['Amount'] ?? '0.00';
        double amount = double.tryParse(amountStr) ?? 0.0;
 
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
        String amountStr = transaction['Amount']?['Amount'] ?? '0.00';
        double amount = double.tryParse(amountStr) ?? 0.0;
 
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
        String amountStr = transaction['Amount']?['Amount'] ?? '0.00';
        double amount = double.tryParse(amountStr) ?? 0.0;
 
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
        String amountStr = transaction['Amount']?['Amount'] ?? '0.00';
        double amount = double.tryParse(amountStr) ?? 0.0;
 
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
        String amountStr = transaction['Amount']?['Amount'] ?? '0.00';
        double amount = double.tryParse(amountStr) ?? 0.0;
 
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
        String amountStr = transaction['Amount']?['Amount'] ?? '0.00';
        double amount = double.tryParse(amountStr) ?? 0.0;
 
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
                Text(
                  '${_minIncome.toStringAsFixed(2)} ر.س',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Light',
                    fontSize: 12,
                    color: Colors.green[700],
                  ),
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  '${_minExpense.toStringAsFixed(2)} ر.س',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Light',
                    fontSize: 12,
                    color: Colors.red[700],
                  ),
                  textDirection: TextDirection.rtl,
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
                Text(
                  '${_maxIncome.toStringAsFixed(2)} ر.س',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Light',
                    fontSize: 12,
                    color: Colors.green[700],
                  ),
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  '${_maxExpense.toStringAsFixed(2)} ر.س',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Light',
                    fontSize: 12,
                    color: Colors.red[700],
                  ),
                  textDirection: TextDirection.rtl,
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
                Text(
                  '${_filteredIncome.toStringAsFixed(2)} ر.س',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Light',
                    fontSize: 12,
                    color: Colors.green[700],
                  ),
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  '${_filteredExpense.toStringAsFixed(2)} ر.س',
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Light',
                    fontSize: 12,
                    color: Colors.red[700],
                  ),
                  textDirection: TextDirection.rtl,
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
            title: '${percentage.toStringAsFixed(1)}%',
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
          10.0),
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
        crossAxisAlignment:
            CrossAxisAlignment.end,
        children: [
          Text(
            'تصنيف عمليات الصرف',
            textDirection: TextDirection.rtl,
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
 
 
  Widget buildBarChart() {
    Map<String, double> categoryData =
        _calculateCategoryExpenses();
 
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
 
// Masked display for hidden values
  String getMaskedValue() => '****';
 
  // Calculate total balance
  String getTotalBalance() {
    // Initialize sum to zero
    double totalBalance = widget.accounts.fold(0.0, (sum, account) {
      // For each account, add its balance to the sum
      return sum + double.parse(account['Balance'] ?? '0');
    });
    return totalBalance.toStringAsFixed(2);
  }

  Map<String, double> calculateIncomeAndExpense() {
    // Initialize income and expense to zero
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    // Get current date
    DateTime now = DateTime.now();
    int mappedYear = now.year == 2024
        ? 2016
        : now.year == 2025
            ? 2017
            : now.year;
 
    DateTime startOfMonth = DateTime(mappedYear, now.month, 1);
    DateTime today = DateTime(mappedYear, now.month, now.day);
 
    // Loop through accounts
    for (var account in widget.accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        // Parse transaction date
        String? dateStr = transaction['TransactionDateTime'];
        DateTime transactionDate =
            DateTime.tryParse(dateStr ?? '') ?? DateTime.now();
 
        // Filter transactions
        if (transactionDate
                .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            transactionDate.isBefore(today.add(const Duration(days: 1)))) {
          String subtype =
              transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
                  'غير معروف';
          String amountStr = transaction['Amount']?['Amount'] ?? '0.00';
          double amount = double.tryParse(amountStr) ?? 0.0;
 
          // Group and sum income and expenses
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
                          text: widget.userName
                              .split(' ')
                              .first,
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
                    offset:
                        const Offset(0, -5),
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
                        transitionDuration:
                            const Duration(seconds: 0),
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
                        transitionDuration:
                            const Duration(seconds: 0),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                      ),
                      (route) => false,
                    );
                  }),
 
                  buildBottomNavItem(
                      Icons.account_balance_outlined, "الحسابات", 2,
                      isSelected: true, onTap: () {
                    Navigator.push(
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
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SavingPlanPage(
                          userName: widget.userName,
                          phoneNumber: widget.phoneNumber,
                          accounts: widget.accounts,
                        ),
                        transitionDuration:
                            const Duration(seconds: 0),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                      ),
                      (route) => false,
                    );
                  }),
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
                  _isCirclePressed =
                      false;
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
        ],
      ),
    );
  }
//switch bwtween dashboard 1 and 2
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
 
  // First Dashboard
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
                      const Text(
                        'ر.س',
                        style: TextStyle(
                          fontFamily: 'GE-SS-Two-Light',
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _isBalanceVisible
                            ? getTotalBalance() // Visible
                            : getMaskedValue(), // Hidden
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
                            const Text(
                              'ر.س',
                              style: TextStyle(
                                fontFamily: 'GE-SS-Two-Light',
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _isBalanceVisible
                                  ? totals['expense']!.toStringAsFixed(2)
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
                            const Text(
                              'ر.س',
                              style: TextStyle(
                                fontFamily: 'GE-SS-Two-Light',
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _isBalanceVisible
                                  ? totals['income']!.toStringAsFixed(2)
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
                    height: 290,
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
 
    if (_selectedPeriod == 'اسبوعي') {
      selectedDate = DateTime(2016, now.month - monthOffset, now.day);
    } else if (_selectedPeriod == 'شهري') {
      selectedDate = DateTime(2016, now.month - monthOffset);
    } else if (_selectedPeriod == 'سنوي') {
      selectedDate = DateTime(2016);
    } else {
      return filteredTransactions; // Return empty if no valid period
    }
 
    for (var account in accounts) {
      var transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        String dateStr = transaction['TransactionDateTime'] ?? '';
        DateTime transactionDate = DateTime.tryParse(dateStr) ?? DateTime.now();
 
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
    DateTime now = DateTime.now();
    DateTime cutoffDate =
        DateTime(2016, now.month, now.day, now.hour, now.minute, now.second);
 
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
            transactionDate.year == 2016 &&
            transactionDate.month == selectedDate.month &&
            _getWeekOfMonth(transactionDate.day) ==
                _getWeekOfMonth(selectedDate.day)) {
          includeTransaction = true;
        } else if (period == 'شهري' &&
            transactionDate.year == 2016 &&
            transactionDate.month == selectedDate.month) {
          includeTransaction = true;
        } else if (period == 'سنوي' && transactionDate.year == 2016) {
          includeTransaction = true;
        }
 
        if (includeTransaction) {
          String subtype =
              transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ?? '';
          // Consider only expenses
          if (['MoneyTransfer', 'Withdrawal', 'Purchase', 'DepositReversal']
              .contains(subtype)) {
            String category = transaction['Category'] ??
                transaction['SubTransactionType']?.replaceAll('KSAOB.', '') ??
                'غير مصنف';
            double amount =
                double.tryParse(transaction['Amount']?['Amount'] ?? '0.0') ??
                    0.0;
            DateTime? transactionDate =
                transaction['TransactionDateTime'] != null
                    ? DateTime.tryParse(transaction['TransactionDateTime'])
                    : null;
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