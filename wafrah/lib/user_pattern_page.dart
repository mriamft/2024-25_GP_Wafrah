import 'dart:math' as math;
import 'package:flutter/material.dart';

// Adjust this import based on where your SavingDisPage file is located:
import 'package:wafrah/saving_dis_page.dart';

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
    print("resultData: ${widget.resultData}"); // ✅ Print resultData in console
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
      return Icons.help_outline; // Default icon if category is missing
  }
}

  @override
  Widget build(BuildContext context) {
    double totalSpending = widget.spendingData['CategorySpending'] != null
    ? (widget.spendingData['CategorySpending'] as Map<String, dynamic>)
        .entries
        .where((entry) => entry.key != 'الراتب') // ✅ Exclude income category
        .fold(0.0, (sum, entry) => sum + (entry.value as double))
    : 0.0;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Back arrow
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

          // Page Title
          const Positioned(
            top: 58,
            left: 110,
            child: Text(
              'نمط الإنفاق الخاص بك',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),

          // Spending Summary Rectangle
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
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        'مجموع الصرف لفترة ${widget.durationMonths} أشهر',
                      style: TextStyle(
                        color: Color(0xFF535353),
                        fontSize: 11,
                        fontFamily: 'GE-SS-Two-Light',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ريال',
                          style: TextStyle(
                            color: Color(0xFF3D3D3D),
                            fontSize: 11,
                            fontFamily: 'GE-SS-Two-Light',
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          totalSpending.toStringAsFixed(2),
                          style: TextStyle(
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

          // Explanation text at the top
          const Positioned(
            left: 28,
            top: 114,
            child: Text(
              'هذا النمط يعتمد على إنفاقك في نفس الفترة الزمنية للسنوات \nالسابقة',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
              textAlign: TextAlign.right,
            ),
          ),

          // Scrollable Category Circles
          Positioned(
            top: 300,
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
                  spacing: 60,
                  runSpacing: 55,
                  children: _buildCategoryCircles(),
                ),
              ),
            ),
          ),

          // Next Page Button
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
                      startDate : widget.startDate,
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

  /// Builds the list of “circle” widgets based on your categories.
  List<Widget> _buildCategoryCircles() {
  // Compute total spending excluding "الراتب"
  double totalSpending = widget.spendingData['CategorySpending'] != null
      ? (widget.spendingData['CategorySpending'] as Map<String, dynamic>)
          .entries
          .where((entry) => entry.key != 'الراتب')
          .fold(0.0, (sum, entry) => sum + (entry.value as double))
      : 0.0;

  final categories = widget.spendingData['CategorySpending'] != null
      ? (widget.spendingData['CategorySpending'] as Map<String, dynamic>)
          .entries
          .where((entry) => entry.key != 'الراتب') // ✅ Exclude "الراتب"
          .map((entry) => {
                'title': entry.key,
                'icon': _getCategoryIcon(entry.key), // ✅ Assign correct icon
                'amount': entry.value.toStringAsFixed(2),
                'percentage': totalSpending > 0
                    ? ((entry.value / totalSpending) * 100).toStringAsFixed(1) + '%'
                    : '0.0%' // Avoid division by zero
              })
          .toList()
      : [];

  return categories.map((cat) {
    return _buildCategoryCircleItem(
      icon: cat['icon'] as IconData,
      label: cat['title'] as String,
      amount: cat['amount'] as String,
      percentage: cat['percentage'] as String,
    );
  }).toList();
}


  /// Builds a single circular widget (with the arc, icon, spending, etc.)
  /// The percentage text is placed at the end of the circular arc, **outside** the circle.
  Widget _buildCategoryCircleItem({
    required IconData icon,
    required String label,
    required String amount,
    required String percentage,
  }) {
    // 1) Convert "10%" => 0.10, "8%" => 0.08, etc.
    double progressValue = 0.1;
    if (percentage.endsWith('%')) {
      final numeric = percentage.substring(0, percentage.length - 1);
      final parsed = double.tryParse(numeric.trim());
      if (parsed != null) {
        progressValue = parsed / 100.0;
      }
    }

    // 2) For a 130×130 circle, the center is at (65, 65).
    //    CircularProgressIndicator starts at -90° (top), so angle offset is -pi/2
    //    The endpoint moves clockwise by (progressValue * 2*pi).
    double angle = -math.pi / 2 + 2 * math.pi * progressValue;

    // Center point in the 130x130 container
    double center = 65;
    // Increase this radius > 65 to ensure the percentage text sits outside the circle
    // The stroke is 5px, so let's push the label out a bit further, e.g. 75.
    double radius = 83;

    // 3) Convert from polar to Cartesian for label position
    double offsetX = center + radius * math.cos(angle);
    double offsetY = center + radius * math.sin(angle);

    // 4) Build the widget with a Stack so we can absolutely position the label
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Gray circle background
          Container(
            width: 130,
            height: 130,
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

          // The green progress indicator
          SizedBox(
            width: 130,
            height: 130,
            child: CircularProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.transparent,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFEB5757)),
              strokeWidth: 5,
            ),
          ),

          // Icon + label + spending in the center
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
                  const Text(
                    'ريال',
                    style: TextStyle(
                      color: Color(0xFF3D3D3D),
                      fontSize: 11,
                      fontFamily: 'GE-SS-Two-Light',
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    amount,
                    style: const TextStyle(
                      color: Color(0xFF3D3D3D),
                      fontSize: 20,
                      fontFamily: 'GE-SS-Two-Bold',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 5) The percentage text placed at the arc endpoint, outside the circle
          Positioned(
            // Adjust these offsets so the text is visually centered around the arc end
            left: offsetX - 12,
            top: offsetY - 8,
            child: Text(
              percentage,
              style: const TextStyle(
                color: Color(0xFF535353),
                fontSize: 16,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
