import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'success_plan_page.dart'; // Import SuccessPlanPage

class GoalPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;

  const GoalPage(
      {super.key, required this.userName, required this.phoneNumber});

  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  Color _arrowColor = const Color(0xFF3D3D3D);

  // Use two controllers for start and end date
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController goalController = TextEditingController();

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

  bool _isPressed = false;

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    goalController.dispose();
    super.dispose();
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
          // Rectangle and Input Fields
          Positioned(
            left: -18,
            top: 252,
            child: Container(
              width: 430,
              height: 183,
              color: const Color(0xFFF1F1F1),
              child: Column(
                children: [
                  const SizedBox(height: 55),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 68),
                        child: Text(
                          'المدة المرغوبة',
                          style: TextStyle(
                            color: Color(0xFF3D3D3D),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GE-SS-Two-Bold',
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 60),
                        child: Text(
                          'المبلغ المستهدف',
                          style: TextStyle(
                            color: Color(0xFF3D3D3D),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GE-SS-Two-Bold',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Start Date input bar
                      SizedBox(
                        width: 130, // Increase the width
                        height: 28,
                        child: TextField(
                          controller: startDateController,
                          textAlign: TextAlign.right,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: 'تاريخ البدء',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                  color: Color(0xFFAEAEAE), width: 1),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9F9F9),
                          ),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      // End Date input bar
                      SizedBox(
                        width: 130, // Increase the width
                        height: 28,
                        child: TextField(
                          controller: endDateController,
                          textAlign: TextAlign.right,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: 'تاريخ الانتهاء',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                  color: Color(0xFFAEAEAE), width: 1),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9F9F9),
                          ),
                          style: const TextStyle(fontSize: 10),
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
                // Navigate to SuccessPlanPage instead of GoalPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SuccessPlanPage(
                      userName: widget.userName, // Pass userName
                      phoneNumber: widget.phoneNumber,
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
                    'استمرار',
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
