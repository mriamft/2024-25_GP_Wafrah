import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wafrah/session_manager.dart';
import 'package:wafrah/user_pattern_page.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class GoalPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final List<Map<String, dynamic>> accounts;

  const GoalPage({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [],
  });

  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  Color _arrowColor = const Color(0xFF3D3D3D);
  final TextEditingController goalController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  //final TextEditingController endDateController = TextEditingController();

  bool isLoading = false;
  String outputMessage = "";
  String selectedOption = "duration"; // Default selection

  Color _notificationColor = const Color(0xFFC62C2C);
  Timer? _notificationTimer;
  bool _showNotification = false;
  String _notificationMessage = '';

  @override
  void initState() {
    super.initState();
    SessionManager.startTracking(context);
  }

  // Show notification method
  void showNotification(String message, {Color color = Colors.red}) {
    setState(() {
      _notificationMessage =
          "حدث خطأ ما \nهدفك غير منطقي للفترة المحددة، حاول اختيار هدف آخر"; // Fixed message
      _notificationColor = color;
      _showNotification = true;
    });

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showNotification = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    goalController.dispose();
    startDateController.dispose();
    durationController.dispose();
    //endDateController.dispose();
    SessionManager.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Prevents selecting past dates
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF2C8C68),
            colorScheme: const ColorScheme.light(primary: Color(0xFF2C8C68)),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  bool _isFormValid() {
    final isGoalFilled = goalController.text.isNotEmpty;
    final isStartDateFilled = startDateController.text.isNotEmpty;
    final isDurationFilled = durationController.text.isNotEmpty;
    //final isEndDateFilled = endDateController.text.isNotEmpty;

    return isGoalFilled && (isDurationFilled);
  }

  void _onDurationChanged(String value) {
    setState(() {
      durationController.text = value;
      if (value.isNotEmpty) {
        //endDateController.clear(); // Clear end date if duration is filled
      }
    });
  }

  /*void _onEndDateChanged(String value) {
    setState(() {
      endDateController.text = value;
      if (value.isNotEmpty) {
        durationController.clear(); // Clear duration if end date is filled
      }
    });
  }*/

  Future<void> _runFlaskAPI() async {
    setState(() {
      isLoading = true;
      outputMessage = "";
    });

    try {
      double durationInMonths = 0;
      if (durationController.text.isNotEmpty) {
        durationInMonths = double.parse(durationController.text);
      }
      /*else if (endDateController.text.isNotEmpty) {
        final startDate = DateTime.parse(startDateController.text);
        final endDate = DateTime.parse(endDateController.text);
        durationInMonths =
            (endDate.difference(startDate).inDays / 30).ceilToDouble();
      }*/

      final goal = double.parse(goalController.text);
      final startDate = startDateController.text;

      final savingsUrl = Uri.parse("https://flask-app.ngrok.io/run-script");

      List<Map<String, dynamic>> transactions = [];
      for (var account in widget.accounts) {
        if (account.containsKey('transactions')) {
          for (var transaction in account['transactions']) {
            transactions.add({
              "TransactionId": transaction["TransactionId"],
              "Date": transaction["TransactionDateTime"],
              "TransactionType": transaction["SubTransactionType"],
              "TransactionInformation": transaction["TransactionInformation"],
              "Amount": transaction["Amount"],
              "Category": transaction["Category"]
            });
          }
        }
      }

      final String todayOverride = "2025-05-15";

      // Call the savings API
      final savingsResponse = await http.post(
        savingsUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "goal": goal,
          "duration_months": durationInMonths,
          "transactions": transactions,
          "start_date": startDate,
          "today": todayOverride
        }),
      );

      // ✅ Print response for debugging
      print("🔹 Savings API Response: ${savingsResponse.body}");

      if (savingsResponse.statusCode != 200) {
        throw "⚠️ Server Error: ${savingsResponse.statusCode}";
      }

      final savingsData = jsonDecode(savingsResponse.body);

      // ✅ Check if API returned success: false
      if (savingsData.containsKey('success') &&
          savingsData['success'] == false) {
        showNotification(
            "حدث خطأ ما \nهدفك غير منطقي للفترة المحددة، حاول اختيار هدف آخر");
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Proceed only if savings plan is valid
      final spendingUrl =
          Uri.parse("https://flask-app.ngrok.io/category-spending-summary");

      final spendingResponse = await http.post(
        spendingUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "start_date": startDate,
          "duration_months": durationInMonths,
          "transactions": transactions,
        }),
      );

      if (spendingResponse.statusCode != 200) {
        throw "⚠️ Server Error: ${spendingResponse.statusCode}";
      }

      final spendingData = jsonDecode(spendingResponse.body);
      if (spendingData.containsKey('success') &&
          spendingData['success'] == false) {
        showNotification("⚠️ حدث خطأ أثناء استرجاع بيانات الإنفاق.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Navigate to UserPatternPage if both responses are valid
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserPatternPage(
            userName: widget.userName,
            phoneNumber: widget.phoneNumber,
            accounts: widget.accounts,
            resultData: savingsData['data'],
            spendingData: spendingData['data'],
            startDate: startDate,
            durationMonths: durationInMonths.toInt(),
          ),
        ),
      );
    } catch (e) {
      showNotification("⚠️ فشل الاتصال بالخادم: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            left: 190,
            child: Text(
              'خطة الإدخار',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),
          const Positioned(
            left: 55,
            top: 130,
            child: Text(
              ' لإنشاء خطة ادخار، يجب تحديد المبلغ الذي ترغب في ادخاره، المدة الزمنية • \n'
              '  التي ستقوم فيها بالادخار \n'
              '.يمكنك اختيار تحديد تاريخ الانتهاء أو تحديد المدة بالأشهر • \n'
              '  .في حالة اختيار تاريخ الانتهاء، سيتم تقريب أي جزء من الشهر إلى شهر كامل • \n',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 10,
                fontFamily: 'GE-SS-Two-Light',
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Positioned(
            left: -18,
            top: 252,
            child: Container(
              width: 430,
              height: 400,
              color: const Color(0xFFF9F9F9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  '*',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'الهدف',
                                  style: TextStyle(
                                    color: Color(0xFF3D3D3D),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'GE-SS-Two-Bold',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 150,
                              height: 28,
                              child: TextField(
                                style: const TextStyle(
                                  fontFamily: 'GE-SS-Two-Light',
                                ),
                                controller: goalController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Only allow digits
                                ],
                                decoration: InputDecoration(
                                  hintText: 'ريال',
                                  hintStyle: const TextStyle(
                                    fontFamily: 'GE-SS-Two-Light',
                                    height: 0.8,
                                    color: Color(0xFFAEAEAE),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF2C8C68), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF2C8C68), width: 2),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  '*',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'تاريخ البداية',
                                  style: TextStyle(
                                    color: Color(0xFF3D3D3D),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'GE-SS-Two-Bold',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 150,
                              height: 28,
                              child: TextField(
                                style: const TextStyle(
                                  fontFamily:
                                      'GE-SS-Two-Light', // Set input font family
                                ),
                                controller: startDateController,
                                readOnly: true,
                                textAlign: TextAlign.right,
                                onTap: () =>
                                    _selectDate(context, startDateController),
                                decoration: InputDecoration(
                                  hintText: 'تاريخ البدء',
                                  hintStyle: const TextStyle(
                                    fontFamily:
                                        'GE-SS-Two-Light', // Set hint font family
                                    height:
                                        0.8, // Adjust height to move hint down
                                    color: Color(
                                        0xFFAEAEAE), // Optional: hint color
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF2C8C68),
                                        width: 1), // Changed to #2C8C68
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF2C8C68),
                                        width: 2), // Changed to #2C8C68
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(right: 45.0),
                    child: Text(
                      "المدة المرغوبة بالأشهر",
                      style: TextStyle(
                        color: Color(0xFF3D3D3D),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'GE-SS-Two-Bold',
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 50.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 28,
                          child: TextField(
                            style: const TextStyle(
                              fontFamily: 'GE-SS-Two-Light',
                            ),
                            controller: durationController,
                            enabled: selectedOption == "duration",
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly, // Only allow digits
                            ],
                            onChanged: _onDurationChanged,
                            decoration: InputDecoration(
                              hintText: 'أشهر',
                              hintStyle: const TextStyle(
                                fontFamily: 'GE-SS-Two-Light',
                                height: 0.8,
                                color: Color(0xFFAEAEAE),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                    color: Color(0xFF2C8C68), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                    color: Color(0xFF2C8C68), width: 2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        /*Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'تاريخ النهاية',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'GE-SS-Two-Light',
                              ),
                            ),
                            Radio<String>(
                              value: "end_date",
                              groupValue: selectedOption,
                              activeColor: const Color(
                                  0xFF2C8C68), // Circular button color
                              onChanged: (value) {
                                setState(() {
                                  selectedOption = value!;
                                  durationController.clear(); // Clear duration
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 150,
                          height: 28,
                          child: TextField(
                            style: const TextStyle(
                              fontFamily:
                                  'GE-SS-Two-Light', // Set input font family
                            ),
                            controller: endDateController,
                            enabled: selectedOption == "end_date",
                            readOnly: true,
                            textAlign: TextAlign.right,
                            onTap: selectedOption == "end_date"
                                ? () => _selectDate(context, endDateController)
                                : null,
                            onChanged: _onEndDateChanged,
                            decoration: InputDecoration(
                              hintText: 'تاريخ النهاية',
                              hintStyle: const TextStyle(
                                fontFamily:
                                    'GE-SS-Two-Light', // Set hint font family
                                height: 0.8, // Adjust height to move hint down
                                color:
                                    Color(0xFFAEAEAE), // Optional: hint color
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                    color: Color(0xFF2C8C68),
                                    width: 1), // Changed to #2C8C68
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                    color: Color(0xFF2C8C68),
                                    width: 2), // Changed to #2C8C68
                              ),
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 280.0), // Adjust the padding to move left
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: !_isFormValid(),
                          child: const Text(
                            'لم تقم بملء جميع الحقول',
                            style: TextStyle(
                              color: Color(0xFFDD2C35),
                              fontSize: 10,
                              fontFamily: 'GE-SS-Two-Light',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 350,
            left: 205,
            child: Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
          Positioned(
            left: 61,
            bottom: 40, // Adjust position if needed
            child: GestureDetector(
              onTap: _isFormValid() && !isLoading ? _runFlaskAPI : null,
              child: Container(
                width: 274,
                height: 45,
                decoration: BoxDecoration(
                  color: _isFormValid()
                      ? const Color(0xFF3D3D3D)
                      : const Color(0xFF6D6D6D),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Center(
                  child: Text(
                    'استمرار',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'GE-SS-Two-Light'),
                  ),
                ),
              ),
            ),
          ),
          // Loading overlay
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(
                            0xFF69BA9C), // Match the color used in AccLinkPage
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "يتم الآن معالجة البيانات", // Loading message
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'GE-SS-Two-Bold',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
