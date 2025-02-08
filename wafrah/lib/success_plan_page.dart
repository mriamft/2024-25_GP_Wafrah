import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'saving_plan_page2.dart'; // Import SavingPlanPage2

class SuccessPlanPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final Map<String, dynamic> resultData;
  final List<Map<String, dynamic>> accounts; // List of accounts with transactions

  const SuccessPlanPage(
      {super.key, required this.userName, required this.phoneNumber, required this.accounts, 
      required this.resultData,});

  @override
  _SuccessPlanPageState createState() => _SuccessPlanPageState();
}

class _SuccessPlanPageState extends State<SuccessPlanPage> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Icon "check_circle_outline_rounded"
          const Positioned(
            left: 126,
            top: 123,
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 142,
              color: Color(0xFF2C8C68),
            ),
          ),

          // Text "تم إنشاء الخطة بنجاح"
          const Positioned(
            left: 76,
            top: 279,
            child: Text(
              "تم إنشاء الخطة بنجاح",
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF3D3D3D),
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),

          // Icons "repeat_rounded", "visibility_outlined", and "outlined_flag_rounded"
          const Positioned(
            left: 331,
            top: 372,
            child: Icon(
              Icons.repeat_rounded,
              size: 28,
              color: Color(0xFF6C6C6C),
            ),
          ),
          const Positioned(
            left: 331,
            top: 422,
            child: Icon(
              Icons.visibility_outlined,
              size: 28,
              color: Color(0xFF6C6C6C),
            ),
          ),
          const Positioned(
            left: 331,
            top: 470,
            child: Icon(
              Icons.outlined_flag_rounded,
              size: 28,
              color: Color(0xFF6C6C6C),
            ),
          ),

          // Right-aligned Text "فعل الاستقطاع الشهري للمداومة على التقدم نحو هدفك"
          const Positioned(
            left: 47,
            top: 375,
            child: Text(
              "فعل الاستقطاع الشهري للمداومة على التقدم نحو\nهدفك",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6C6C6C),
                fontFamily: 'GE-SS-Two-Light',
              ),
            ),
          ),

          // Right-aligned Text "راقب تقدمك في خطة الادخار معنا"
          const Positioned(
            left: 125,
            top: 429,
            child: Text(
              "راقب تقدمك في خطة الادخار معنا",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6C6C6C),
                fontFamily: 'GE-SS-Two-Light',
              ),
            ),
          ),

          // Right-aligned Text "سوف نذكرك بشكل دوري, مما يضمن تقدمك الفعال"
          const Positioned(
            left: 38,
            top: 480,
            child: Text(
              "سوف نذكرك بشكل دوري, مما يضمن تقدمك الفعال",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6C6C6C),
                fontFamily: 'GE-SS-Two-Light',
              ),
            ),
          ),

          // Button for "استمرار"
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
                // Navigate to SavingPlanPage2
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SavingPlanPage2(
                      userName: widget.userName, // Pass userName
                      phoneNumber: widget.phoneNumber,
                      accounts: widget.accounts,
                      resultData: widget.resultData,
                    ), // Updated route
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
                    'صفحة الخطة',
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
