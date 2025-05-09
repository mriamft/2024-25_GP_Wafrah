import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wafrah/saving_dis_page.dart';
import 'custom_icons.dart';

class UserPatternPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final List<Map<String, dynamic>> accounts;
  final Map<String, dynamic> resultData;
  final Map<String, dynamic> spendingData;
  final int durationMonths;
  final String startDate;

  const UserPatternPage({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [],
    required this.resultData,
    required this.spendingData,
    required this.startDate,
    required this.durationMonths,
  });

  @override
  _UserPatternPageState createState() => _UserPatternPageState();
}

class _UserPatternPageState extends State<UserPatternPage> {
  @override
  void initState() {
    super.initState();
    print("resultData: ${widget.resultData}"); 
  }

  final NumberFormat arabicNumberFormat = NumberFormat("#,##0.00", "ar");
  String cleanNumber(String number) {
    return number
        .replaceAll(',', '') // Remove thousands separator
        .replaceAll('،', '.') // Convert Arabic decimal separator to '.'
        .replaceAll(RegExp(r'[^0-9.]'), '') 
        .replaceAllMapped(RegExp(r'\.(?=.*\.)'), (match) => '');
  }

  Color _arrowColor = const Color(0xFF3D3D3D);
  bool _isPressed = false;
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'المطاعم':
        return Icons.restaurant;
      case 'التعليم':
        return Icons.school;
      case 'الصحة':
        return Icons.local_hospital;
      case 'تسوق':
        return Icons.shopping_bag;
      case 'البقالة':
        return Icons.local_grocery_store;
      case 'النقل':
        return Icons.directions_bus;
      case 'السفر':
        return Icons.flight;
      case 'المدفوعات الحكومية':
        return Icons.account_balance;
      case 'الترفيه':
        return Icons.gamepad_rounded;
      case 'الاستثمار':
        return Icons.trending_up;
      case 'الإيجار':
        return Icons.home;
      case 'القروض':
        return Icons.money;
      case 'التحويلات':
        return Icons.swap_horiz;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalIncome = widget.spendingData['TotalIncome'] ?? 0.0;

    double totalSpending = widget.spendingData['TotalSpending'] ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          Positioned(
            top: 60,
            right: 15,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _arrowColor = Colors.grey;
                });
                Future.delayed(const Duration(milliseconds: 100), () {
                  setState(() {
                    _arrowColor = const Color(0xFF3D3D3D);
                  });
                  Navigator.pop(context);
                });
              },
              child: Icon(
                Icons.arrow_forward_ios,
                color: _arrowColor,
                size: 28,
              ),
            ),
          ),
          const Positioned(
            top: 58,
            left: 65,
            child: Text(
              'نمط الإنفاق والدخل الخاص بك',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),
          Positioned(
            left: 83,
            top: 200,
            child: Container(
              width: 228,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'مجموع الصرف لفترة ${widget.durationMonths} أشهر',
                      style: const TextStyle(
                        color: Color(0xFF535353),
                        fontSize: 11,
                        fontFamily: 'GE-SS-Two-Light',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CustomIcons.riyal, 
                          size: 14, 
                          color: Color(0xFF3D3D3D),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          arabicNumberFormat.format(totalSpending),
                          style: const TextStyle(
                            color: Color(0xFF3D3D3D),
                            fontSize: 32,
                            fontFamily: 'GE-SS-Two-Bold',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 83,
            top: 280, 
            child: Container(
              width: 228,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'مجموع الدخل لفترة ${widget.durationMonths} أشهر',
                      style: const TextStyle(
                        color: Color(0xFF535353),
                        fontSize: 11,
                        fontFamily: 'GE-SS-Two-Light',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CustomIcons.riyal, 
                          size: 14,
                          color: Color(0xFF3D3D3D),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          arabicNumberFormat.format(totalIncome),
                          style: const TextStyle(
                            color: Color(0xFF3D3D3D),
                            fontSize: 32,
                            fontFamily: 'GE-SS-Two-Bold',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 30,
            top: 114,
            child: Text(
              'هذا النمط يعتمد على إنفاقك ودخلك في نفس الفترة الزمنية  \nللسنوات السابقة',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Positioned(
            top: 360,
            left: 20,
            right: 20,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 30, bottom: 30),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 25,
                  runSpacing: 55,
                  children: _buildCategoryCircles(),
                ),
              ),
            ),
          ),
          Positioned(
            top: 710,
            left: 61,
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _isPressed = true;
                });
              },
              onTapUp: (_) {
                setState(() {
                  _isPressed = false;
                });
              },
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SavingDisPage(
                      userName: widget.userName,
                      phoneNumber: widget.phoneNumber,
                      accounts: widget.accounts,
                      startDate: widget.startDate,
                      resultData: widget.resultData,
                    ),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 274,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF3D3D3D),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: _isPressed
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    'الإنتقال الى الصفحة التالية',
                    style: TextStyle(
                      color: _isPressed ? Colors.grey[300] : Colors.white,
                      fontSize: 16,
                      fontFamily: 'GE-SS-Two-Light',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryCircles() {
    double totalSpending = widget.spendingData['TotalSpending'] ?? 0.0;
    List<Map<String, dynamic>> categories =
        widget.spendingData['CategorySpending'] != null
            ? (widget.spendingData['CategorySpending'] as Map<String, dynamic>)
                .entries
                .map((entry) => {
                      'title': entry.key,
                      'icon': _getCategoryIcon(entry.key),
                      'percentage': widget.spendingData['CategoryPercentages']
                                  ?[entry.key] !=
                              null
                          ? double.parse(widget
                              .spendingData['CategoryPercentages']![entry.key]!
                              .toStringAsFixed(1))
                          : 0.0 
                    })
                .toList()
            : [];

    double totalCalculatedSpending = 0.0;
    double largestAmount = 0.0;
    String? largestCategory;

    // Convert percentages to amounts & track the largest category
    for (var cat in categories) {
      double calculatedAmount = (cat['percentage'] / 100) * totalSpending;
      cat['amount'] = calculatedAmount.toStringAsFixed(2);

      totalCalculatedSpending += calculatedAmount;

      if (calculatedAmount > largestAmount) {
        largestAmount = calculatedAmount;
        largestCategory = cat['title'];
      }
    }

    double roundingDifference = totalSpending - totalCalculatedSpending;
    if (largestCategory != null) {
      for (var cat in categories) {
        if (cat['title'] == largestCategory) {
          cat['amount'] = (double.parse(cat['amount']) + roundingDifference)
              .toStringAsFixed(2);
          break;
        }
      }
    }

    // Sort by percentage descending order
    categories.sort((a, b) =>
        (b['percentage'] as double).compareTo(a['percentage'] as double));
    for (var cat in categories) {
      cat['percentage'] =
          '${(cat['percentage'] as double).toStringAsFixed(1)}%';
    }

    return categories.map((cat) {
      return _buildCategoryCircleItem(
        icon: cat['icon'] as IconData,
        label: cat['title'] as String,
        amount: cat['amount'] as String,
        percentage: cat['percentage'] as String,
      );
    }).toList();
  }

  Widget _buildCategoryCircleItem({
    required IconData icon,
    required String label,
    required String amount,
    required String percentage,
  }) {
    double progressValue = 0.1;
    if (percentage.endsWith('%')) {
      final numeric = percentage.substring(0, percentage.length - 1);
      final parsed = double.tryParse(numeric.trim());
      if (parsed != null) {
        progressValue = parsed / 100.0;
      }
      percentage =
          '%$numeric'; 
    }

    double angle = -math.pi / 2 + 2 * math.pi * progressValue;

    double center = 65;
    double radius = 83;
    double offsetX = center + radius * math.cos(angle);
    double offsetY = center + radius * math.sin(angle);
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.transparent,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFEB5757)),
              strokeWidth: 5,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFEB5757), size: 25),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFEB5757),
                  fontFamily: 'GE-SS-Two-Light',
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CustomIcons.riyal, 
                    size: 14, 
                    color: Color(0xFF3D3D3D),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    arabicNumberFormat.format(double.tryParse(
                            amount.replaceAll(',', '').replaceAll('،', '.')) ??
                        0.0),
                    style: const TextStyle(
                      color: Color(0xFF3D3D3D),
                      fontSize: 18,
                      fontFamily: 'GE-SS-Two-Bold',
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: offsetX - 16,
            top: offsetY - 8,
            child: Text(
              percentage,
              style: const TextStyle(
                color: Color(0xFF535353),
                fontSize: 12,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
