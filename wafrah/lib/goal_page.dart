import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'success_plan_page.dart'; // Import SuccessPlanPage

class GoalPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final List<Map<String, dynamic>> accounts; // List of accounts with transactions

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
  final TextEditingController durationController = TextEditingController();

  bool isLoading = false;
  String outputMessage = ""; // Stores the output from Python

  @override
  void dispose() {
    goalController.dispose();
    durationController.dispose();
    super.dispose();
  }

  Future<void> _runFlaskAPI() async {
  setState(() {
    isLoading = true;
    outputMessage = ""; // Clear old results
  });

  try {
    final url = Uri.parse("https://flask-app.ngrok.io/run-script");

    // Prepare the transactions list
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

    // Check data before sending
    print("Sending to Flask: ${jsonEncode({
      "goal": double.parse(goalController.text),
      "duration_months": int.parse(durationController.text),
      "transactions": transactions,
    })}");

    // Send data to Flask API
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "goal": double.parse(goalController.text),
        "duration_months": int.parse(durationController.text),
        "transactions": transactions,
      }),
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
  final data = jsonDecode(response.body);

  if (data['success'] == true && data['data'] != null) {
    // Navigate to the success page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessPlanPage(
          userName: widget.userName,
          phoneNumber: widget.phoneNumber,
          resultData: data['data'], // Pass Python result
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
    print("Connection Error: $e");
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
            left: -18,
            top: 252,
            child: Container(
              width: 430,
              height: 205,
              color: const Color(0xFFF1F1F1),
              child: Column(
                children: [
                  const SizedBox(height: 55),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 130,
                        height: 28,
                        child: TextField(
                          controller: durationController,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'المدة (أشهر)',
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
                          controller: goalController,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'المبلغ المستهدف',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(color: Color(0xFFAEAEAE), width: 1),
                            ),
                          ),
                        ),
                      ),
                    ],
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
