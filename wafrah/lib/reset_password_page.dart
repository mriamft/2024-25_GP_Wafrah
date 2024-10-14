import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  Color _arrowColor = Color(0xFF3D3D3D); // Default arrow color

  void _onArrowTap() {
    setState(() {
      _arrowColor = Colors.grey; // Change color on press
    });
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _arrowColor = Color(0xFF3D3D3D); // Reset color after a short delay
      });
      Navigator.pop(context); // Navigate back to settings page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Back Arrow
          Positioned(
            top: 60,
            right: 15,
            child: GestureDetector(
              onTap: _onArrowTap, // Change this to the new method
              child: Icon(
                Icons.arrow_forward_ios,
                color: _arrowColor, // Use the dynamic color
                size: 28,
              ),
            ),
          ),

          // Title
          Positioned(
            top: 58,
            left: 110,
            child: Text(
              'إعادة تعيين رمز المرور',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily:
                    'GE-SS-Two-Bold', // Use the same font as the project
              ),
            ),
          ),

          // Current Password Input
          Positioned(
            top: 135,
            left: 24,
            child: Container(
              width: 325,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                textAlign: TextAlign.right, // Align text to the right
                style: TextStyle(
                  fontFamily:
                      'GE-SS-Two-Light', // Use the same font as the project
                ),
                decoration: InputDecoration(
                  hintText: 'رمز المرور الحالي',
                  hintStyle: TextStyle(
                    color: Color(0xFF888888),
                    fontFamily: 'GE-SS-Two-Light', // Same font for hint
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
          ),

          // New Password Input
          Positioned(
            top: 205,
            left: 24,
            child: Container(
              width: 325,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                textAlign: TextAlign.right, // Align text to the right
                style: TextStyle(
                  fontFamily:
                      'GE-SS-Two-Light', // Use the same font as the project
                ),
                decoration: InputDecoration(
                  hintText: 'رمز المرور الجديد',
                  hintStyle: TextStyle(
                    color: Color(0xFF888888),
                    fontFamily: 'GE-SS-Two-Light', // Same font for hint
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
          ),

          // Confirm New Password Input
          Positioned(
            top: 275,
            left: 24,
            child: Container(
              width: 325,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                textAlign: TextAlign.right, // Align text to the right
                style: TextStyle(
                  fontFamily:
                      'GE-SS-Two-Light', // Use the same font as the project
                ),
                decoration: InputDecoration(
                  hintText: 'تأكيد رمز المرور الجديد',
                  hintStyle: TextStyle(
                    color: Color(0xFF888888),
                    fontFamily: 'GE-SS-Two-Light', // Same font for hint
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
          ),

          // Instructions Text
          Positioned(
            top: 330,
            left: 100, // Adjust this position as needed
            child: Container(
              width: 345, // Width for the instructions text
              child: Column(
                children: [
                  Text(
                    'الرجاء اختيار رمز مرور يحقق الشروط التالية:',
                    style: TextStyle(
                      color: Color(0xFF838383),
                      fontSize: 9,
                      fontFamily:
                          'GE-SS-Two-Light', // Use the same font as the project
                    ),
                    textAlign: TextAlign.right, // Align text to the right
                  ),
                  SizedBox(height: 5),
                  Text(
                    'أن يتكون من 8 خانات على الأقل.\n'
                    'أن يحتوي على رقم.\n'
                    'أن يحتوي على حرف صغير.\n'
                    'أن يحتوي على حرف كبير.\n'
                    'أن يحتوي على رمز خاص.',
                    style: TextStyle(
                      color: Color(0xFF838383),
                      fontSize: 9,
                      fontFamily:
                          'GE-SS-Two-Light', // Use the same font as the project
                    ),
                    textAlign: TextAlign.right, // Align text to the right
                  ),
                ],
              ),
            ),
          ),

          // Submit Button
          Positioned(
            bottom: 40, // Adjust position as needed
            left: (MediaQuery.of(context).size.width - 220) / 2,
            child: SizedBox(
              width: 220,
              height: 38,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3D3D3D), // Background color
                  foregroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100), // Rounded corners
                  ),
                  shadowColor: Colors.black, // Shadow color
                  elevation: 5, // Shadow elevation
                ),
                onPressed: () {
                  // Add your reset logic here
                },
                child: Text(
                  'تعديل',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily:
                        'GE-SS-Two-Light', // Use the same font as the project
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