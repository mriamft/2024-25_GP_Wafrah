import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wafrah/saving_dis_page.dart';
import 'success_plan_page.dart'; // Import SuccessPlanPage

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
  final TextEditingController endDateController = TextEditingController();

  bool isLoading = false;
  String outputMessage = "";
  String selectedOption = "duration"; // Default selection

  @override
  void dispose() {
    goalController.dispose();
    startDateController.dispose();
    durationController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF2C8C68),
            colorScheme: ColorScheme.light(primary: const Color(0xFF2C8C68)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _runFlaskAPI() async {
    setState(() {
      isLoading = true;
      outputMessage = "";
    });

    try {
      double durationInMonths = 0;
      if (selectedOption == "duration") {
        durationInMonths = double.parse(durationController.text);
      } else if (selectedOption == "end_date") {
        final startDate = DateTime.parse(startDateController.text);
        final endDate = DateTime.parse(endDateController.text);
        durationInMonths = (endDate.difference(startDate).inDays / 30).ceilToDouble();
      }

      final url = Uri.parse("https://flask-app.ngrok.io/run-script");
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

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "goal": double.parse(goalController.text),
          "duration_months": durationInMonths,
          "transactions": transactions,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SavingDisPage(
                userName: widget.userName,
                phoneNumber: widget.phoneNumber,
                accounts: widget.accounts,
                resultData: data['data'],
              ),
            ),
          );
        } else {
          setState(() {
            outputMessage = "⚠️ API Error: ${data['message'] ?? 'Unknown error occurred.'}";
          });
        }
      } else {
        setState(() {
          outputMessage = "⚠️ Server Error: HTTP ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        outputMessage = "⚠️ Failed to connect to the server: $e";
      });
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
          Positioned(
            left: 1,
            top: 252,
            child: Container(
              width: 430,
              height: 320,
              color: const Color(0xFFF9F9F9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.only(right: 30.0),
                    child: Text(
                      'المدة المرغوبة أو تاريخ الانتهاء',
                      style: TextStyle(
                        color: Color(0xFF3D3D3D),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'GE-SS-Two-Bold',
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 50.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 130,
                          height: 28,
                          child: TextField(
                            controller: goalController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              hintText: 'ريال',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(color: Color(0xFFAEAEAE), width: 1),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 130,
                          height: 28,
                          child: TextField(
                            controller: startDateController,
                            readOnly: true,
                            textAlign: TextAlign.right,
                            onTap: () => _selectDate(context, startDateController),
                            decoration: InputDecoration(
                              hintText: 'تاريخ البدء',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(color: Color(0xFFAEAEAE), width: 1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text("المدة (أشهر)",
                                style: TextStyle(fontSize: 12, fontFamily: 'GE-SS-Two-Bold')),
                            Radio<String>(
                              value: "duration",
                              groupValue: selectedOption,
                              onChanged: (value) {
                                setState(() {
                                  selectedOption = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 130,
                          height: 28,
                          child: TextField(
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'المدة (أشهر)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(color: Color(0xFFAEAEAE), width: 1),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text("تاريخ النهاية",
                                style: TextStyle(fontSize: 12, fontFamily: 'GE-SS-Two-Bold')),
                            Radio<String>(
                              value: "end_date",
                              groupValue: selectedOption,
                              onChanged: (value) {
                                setState(() {
                                  selectedOption = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 130,
                          height: 28,
                          child: TextField(
                            controller: endDateController,
                            readOnly: true,
                            textAlign: TextAlign.right,
                            onTap: () => _selectDate(context, endDateController),
                            decoration: InputDecoration(
                              hintText: 'تاريخ النهاية',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(color: Color(0xFFAEAEAE), width: 1),
                              ),
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
          Positioned(
            left: 61,
            top: 710,
            child: GestureDetector(
              onTap: isLoading ? null : _runFlaskAPI,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 274,
                height: 45,
                decoration: BoxDecoration(
                  color: isLoading ? Colors.grey : const Color(0xFF3D3D3D),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'استمرار',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'GE-SS-Two-Light'),
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