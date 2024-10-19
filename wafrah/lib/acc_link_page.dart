import 'package:flutter/material.dart';

class AccLinkPage extends StatefulWidget {
  @override
  _AccLinkPageState createState() => _AccLinkPageState();
}

class _AccLinkPageState extends State<AccLinkPage> {
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
            left: 135,
            child: Text(
              'إضافة حساب بنكي',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily:
                    'GE-SS-Two-Bold', // Use the same font as the project
              ),
            ),
          ),

          // Instruction Text 1
          Positioned(
            top: 130,
            left: 28,
            child: Text(
              'الرجاء قراءة المعلومات التالية قبل أن تكمل إجراءات الربط',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold', // Same font as the project
              ),
            ),
          ),

          // Instruction Text 2
          Positioned(
            top: 152,
            left: 49,
            child: Container(
              width: 300, // Set width for better wrapping
              child: Text(
                'أنت الآن تسمح لنا بقراءة بياناتك المصرفية من حسابك البنكي، نقوم بذلك من خلال معايير الخدمات المصرفية المفتوحة والتي تسمح لنا بالحصول على معلوماتك وعرضها في وفرة دون معرفة بيانات اعتمادك البنكية (مثل كلمة السر لحسابك البنكي)',
                style: TextStyle(
                  color: Color(0xFF3D3D3D),
                  fontSize: 10,
                  fontFamily: 'GE-SS-Two-Light', // Same font as the project
                ),
                textAlign: TextAlign.right, // Align text to the right
              ),
            ),
          ),

          // Instruction Text 3
          Positioned(
            top: 260,
            left: 60,
            child: Text(
              'سوف نبدأ إجراءات الربط لجميع حساباتك البنكية عن طريق',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 12,
                fontFamily: 'GE-SS-Two-Light', // Same font as the project
              ),
            ),
          ),

          // Bar for bank information
          Positioned(
            top: 280,
            left: 21,
            child: Container(
              width: 330,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 35.0), // Add left padding
                  child: Text(
                    'ساما (البنك السعودي المركزي)',
                    style: TextStyle(
                      color: Color(0xFF3D3D3D),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'GE-SS-Two-Bold', // Same font as the project
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Submit Button
          Positioned(
            bottom: 40, // Adjust position as needed
            left: 40,
            child: SizedBox(
              width: 274,
              height: 47,
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
                  'الاستمرار في اجراءات الربط',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily:
                        'GE-SS-Two-Light', // Use the same font as the project
                  ),
                ),
              ),
            ),
          ),

          // First SAAMA Image
          Positioned(
            left: 315,
            top: 290.5,
            child: Image.asset(
              'assets/images/SAMA_logo.png', // Ensure this is the correct image path
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }
}
