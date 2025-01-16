import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final TextEditingController durationController = TextEditingController();
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
    durationController.dispose();
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
                      // Duration input bar
                      SizedBox(
                        width: 86,
                        height: 28,
                        child: TextField(
                          controller: durationController,
                          textAlign: TextAlign.right,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Only allow numbers
                          ],
                          decoration: InputDecoration(
                            prefixText: 'سنة ',
                            prefixStyle: const TextStyle(
                              color: Color(0xFF878787),
                              fontFamily: 'GE-SS-Two-Light',
                              fontSize: 10,
                            ),
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
                      // Goal input bar
                      SizedBox(
                        width: 86,
                        height: 28,
                        child: TextField(
                          controller: goalController,
                          textAlign: TextAlign.right,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Only allow numbers
                          ],
                          decoration: InputDecoration(
                            prefixText: 'ريال ',
                            prefixStyle: const TextStyle(
                              color: Color(0xFF878787),
                              fontFamily: 'GE-SS-Two-Light',
                              fontSize: 10,
                            ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoalPage(
                      userName: widget.userName,
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
