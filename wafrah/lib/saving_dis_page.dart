import 'package:flutter/material.dart';
import 'success_plan_page.dart'; // Import SuccessPlanPage
import 'custom_icons.dart';

class SavingDisPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final Map<String, dynamic> resultData; // Declare it as a class-level field
  final List<Map<String, dynamic>> accounts; // List of accounts with transactions
  final String startDate;

  const SavingDisPage({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [],
    required this.resultData, // Include it as a parameter in the constructor
    required this.startDate,
  });

  @override
  _SavingDisPageState createState() => _SavingDisPageState();
}

class _SavingDisPageState extends State<SavingDisPage> {
  Color _arrowColor = const Color(0xFF3D3D3D);
  bool _isPressed = false;

  // Define all possible categories
  final List<String> allCategories = [
    'المطاعم',
    'التعليم',
    'الصحة',
    'تسوق',
    'البقالة',
    'النقل',
    'السفر',
    'المدفوعات الحكومية',
    'الترفيه',
    'الاستثمار',
    'الإيجار',
    'القروض',
    'الراتب',
    'التحويلات',
  ];

  // Normalized discretionaryRatios
  late Map<String, int> discretionaryRatios;

  // Normalized CategorySavings
  late Map<String, double> categorySavings;

  late Map<String, int> initialDiscretionaryRatios; // Store initial ratios
  late Map<String, double> initialCategorySavings; // Store initial savings
  late final Map<String, TextEditingController> controllers = {
    for (var category in allCategories)
      category: TextEditingController(
        text:
            ((widget.resultData['discretionaryRatios']?[category] ?? 0) as int)
                .toString(),
      ),
  };

  @override
  void initState() {
    super.initState();

    // Extract discretionaryRatios and CategorySavings from resultData
    Map<String, dynamic> rawRatios =
        widget.resultData['discretionaryRatios'] ?? {};
    Map<String, dynamic> rawSavings =
        widget.resultData['CategorySavings'] ?? {};

    // Ensure all categories exist, setting missing ones to 0
    discretionaryRatios = {
      for (var category in allCategories)
        category: (rawRatios[category] ?? 0).toInt(), // Convert to int
    };

    categorySavings = {
      for (var category in allCategories)
        category: (rawSavings[category] ?? 0.0).toDouble(), // Convert to double
    };

print("Saving dis");
print(widget.startDate);
    // Store initial values for resetting later
    initialDiscretionaryRatios = Map.from(discretionaryRatios);
    initialCategorySavings = Map.from(categorySavings);
  }

  void _onArrowTap() {
    setState(() {
      _arrowColor = Colors.grey;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _arrowColor = const Color(0xFF3D3D3D);
      });
      Navigator.pop(context);
    });
  }

  // Calculate total percentage
  double _calculateTotalPercentage() {
    return discretionaryRatios.values.reduce((a, b) => a + b).toDouble();
  }

  // Update percentage when slider is changed
  void _updateCategoryPercentage(String category, double value) {
    setState(() {
      discretionaryRatios[category] = value.toInt();

      // Recalculate the amount based on the new percentage
      double totalSavingsGoal =
          widget.resultData["SavingsGoal"]?.toDouble() ?? 0.0;
      categorySavings[category] = (totalSavingsGoal * (value / 100)).toDouble();
    });
  }

  void _resetCategoryDistribution() {
    setState(() {
      // Reset to the initial values
      discretionaryRatios = Map.from(initialDiscretionaryRatios);
      categorySavings = Map.from(initialCategorySavings);
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalPercentage = _calculateTotalPercentage();
    bool isTotalValid = totalPercentage == 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          Positioned(
            top: 60,
            right: 15,
            child: GestureDetector(
              onTap: _onArrowTap,
              child: Icon(
                Icons.arrow_forward_ios,
                color: _arrowColor,
                size: 28,
              ),
            ),
          ),
          const Positioned(
            top: 58,
            left: 150,
            child: Text(
              'توزيع خطة الإدخار',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),
          const Positioned(
            left: 28,
            top: 114,
            child: Text(
              'قمنا بتوزيع خطة الإدخار الخاصة بك على هذا الشكل بناءً على \nالنمط المدروس من قبلنا',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const Positioned(
            left: 63,
            top: 152,
            child: Text(
              ' :اذا كنت تريد تعديل هذا التوزيع \n'
              '. قم بسحب المؤشر إلى اليمين أو اليسار أو إدخال النسبة المئوية لكل فئة  \n\n'
                            '. هذه النسب والمبالغ هي لكامل الخطة على مدى كل أشهر الخطة  \n'

               ,
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 10,
                fontFamily: 'GE-SS-Two-Light',
              ),
              textAlign: TextAlign.right,
            ),
          ),

          // Icon as Button
          Positioned(
            left: 22,
            top: 236,
            child: GestureDetector(
              onTap: _resetCategoryDistribution,
              child: const Icon(
                Icons.restart_alt_rounded,
                color: Color(0xFF3D3D3D),
                size: 28,
              ),
            ),
          ),

          // Scrollable Categories Container
          Positioned(
            top: 265,
            left: 0,
            right: 0,
            bottom: 145,
            child: SingleChildScrollView(
              child: Column(
                children: discretionaryRatios.keys.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Container(
                      width: 352,
                      height: 55,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 260,
                            top: 19,
                            child: SizedBox(
                              width: 80,
                              child: Text(
                                category == 'المدفوعات الحكومية'
                                    ? 'المدفوعات\nالحكومية'
                                    : category,
                                style: const TextStyle(
                                  color: Color(0xFF3D3D3D),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'GE-SS-Two-Bold',
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 130,
                            top: 26,
                            child: SizedBox(
                              width: 160,
                              height: 4,
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(3.14),
                                child: Slider(
                                  value:
                                      discretionaryRatios[category]!.toDouble(),
                                  min: 0,
                                  max: 100,
                                  divisions: 100,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _updateCategoryPercentage(
                                          category, newValue);
                                      controllers[category]!.text = newValue
                                          .toInt()
                                          .toString(); // Sync text
                                    });
                                  },
                                  activeColor: const Color(0xFF2C8C68),
                                  inactiveColor: const Color(0xFF838383),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 95,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFF8D8D8D)),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 35,
                                    height: 34,
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'GE-SS-Two-Light',
                                        color: Color(0xFF3D3D3D),
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      controller: TextEditingController(
                                        text:
                                            '%${discretionaryRatios[category]}', // Display the percentage with %
                                      ),
                                      onChanged: (value) {
                                        // Remove the % sign before parsing
                                        String sanitizedValue =
                                            value.replaceAll('%', '').trim();
                                        double? newValue =
                                            double.tryParse(sanitizedValue);

                                        if (newValue != null &&
                                            newValue >= 0 &&
                                            newValue <= 100) {
                                          setState(() {
                                            // Update the ratio and synchronize other components
                                            discretionaryRatios[category] =
                                                newValue.toInt();
                                            double totalSavingsGoal = widget
                                                    .resultData["SavingsGoal"]
                                                    ?.toDouble() ??
                                                0.0;
                                            categorySavings[category] =
                                                (totalSavingsGoal *
                                                        (newValue / 100))
                                                    .toDouble();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 24,
                            top: 16,
                            child: Text(
                              categorySavings[category]!.toStringAsFixed(
                                  0), // Display category savings
                              style: const TextStyle(
                                color: Color(0xFF3D3D3D),
                                fontSize: 17,
                                fontFamily: 'GE-SS-Two-Bold',
                              ),
                            ),
                          ),
                          const Positioned(
  left: 3,
  top: 19,
  child: Icon(
    CustomIcons.riyal, // Riyal symbol
    size: 14, // Adjust size if needed
    color: Color(0xFF3D3D3D),
  ),
),

                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Warning message
          if (!isTotalValid)
            Positioned(
              left: 122,
            top: 245,
              child: Text(
                'مجموع النسب لا يساوي ١٠٠%! نسبتك الحالية هي ${totalPercentage.toInt()}%',
                style: const TextStyle(
                  color: Color(0xFFDD2C35),
                  fontSize: 11,
                  fontFamily: 'GE-SS-Two-Light',
                ),
                textAlign: TextAlign.right, // Proper alignment for Arabic
                textDirection: TextDirection.rtl, // Ensure RTL text flow
              ),
            ),

          Positioned(
            left: 61,
            top: 710,
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
                if (isTotalValid) {
                  // Create a copy of resultData and update it with the latest user input
                  Map<String, dynamic> updatedResultData =
                      Map.from(widget.resultData);

                  // Update the discretionaryRatios and CategorySavings in the resultData
                  updatedResultData['discretionaryRatios'] =
                      Map.from(discretionaryRatios);
                  updatedResultData['CategorySavings'] =
                      Map.from(categorySavings);
                  updatedResultData['DurationMonths'] = widget.resultData['DurationMonths'];
                  updatedResultData["startDate"] = widget.startDate;
                  print("Updated resultData before navigation: $updatedResultData");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuccessPlanPage(
                        userName: widget.userName,
                        phoneNumber: widget.phoneNumber,
                        accounts: widget.accounts,
                        resultData: updatedResultData, // Pass the updated data
                      ),
                    ),
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 274,
                height: 45,
                decoration: BoxDecoration(
                  color: isTotalValid
                      ? const Color(0xFF3D3D3D)
                      : const Color(0xFF838383),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: isTotalValid && !_isPressed
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [], // No shadow if total is not valid
                ),
                child: Center(
                  child: Text(
                    'حفظ',
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
}


