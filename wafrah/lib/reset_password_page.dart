import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Add this import for HTTP requests
import 'dart:convert'; // Add this for JSON handling

class ResetPasswordPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;

  const ResetPasswordPage(
      {super.key, required this.userName, required this.phoneNumber});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  Color _arrowColor = const Color(0xFF3D3D3D); // Default arrow color
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _showErrorNotification = false;
  String _errorMessage = '';

  void _onArrowTap() {
    setState(() {
      _arrowColor = Colors.grey; // Change color on press
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _arrowColor =
            const Color(0xFF3D3D3D); // Reset color after a short delay
      });
      Navigator.pop(context); // Navigate back to settings page
    });
  }

  // Method to validate password complexity
  bool validatePassword(String password) {
    final RegExp passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
    );
    return passwordRegExp.hasMatch(password);
  }

  Future<void> _resetPassword() async {
    final String currentPassword = _currentPasswordController.text;
    final String newPassword = _newPasswordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = "يجب ملء جميع الحقول";
        _showErrorNotification = true;
      });
      return;
    }

    if (!validatePassword(newPassword)) {
      setState(() {
        _errorMessage =
            'رمز المرور لا يحقق الشروط: 8 خانات على الأقل، حرف صغير، حرف كبير، رقم ورمز خاص';
        _showErrorNotification = true;
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = "كلمات المرور الجديدة غير متطابقة";
        _showErrorNotification = true;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'https://edda-82-167-111-148.ngrok-free.app/reset-password'), // Change to your API endpoint
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'phoneNumber': widget.phoneNumber,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _errorMessage = "تم تعديل كلمة المرور بنجاح";
          _showErrorNotification = true;
        });
      } else {
        setState(() {
          _errorMessage = "فشل تعديل كلمة المرور";
          _showErrorNotification = true;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = "خطأ في الاتصال بالخادم";
        _showErrorNotification = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Back Arrow
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

          // Title
          const Positioned(
            top: 58,
            left: 110,
            child: Text(
              'إعادة تعيين رمز المرور',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
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
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _currentPasswordController,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'GE-SS-Two-Light',
                ),
                obscureText: true, // Obscure text for password input
                decoration: const InputDecoration(
                  hintText: 'رمز المرور الحالي',
                  hintStyle: TextStyle(
                    color: Color(0xFF888888),
                    fontFamily: 'GE-SS-Two-Light',
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
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _newPasswordController,
                textAlign: TextAlign.right,
                obscureText: true, // Obscure text for password input
                style: const TextStyle(
                  fontFamily: 'GE-SS-Two-Light',
                ),
                decoration: const InputDecoration(
                  hintText: 'رمز المرور الجديد',
                  hintStyle: TextStyle(
                    color: Color(0xFF888888),
                    fontFamily: 'GE-SS-Two-Light',
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
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _confirmPasswordController,
                textAlign: TextAlign.right,
                obscureText: true, // Obscure text for password input
                style: const TextStyle(
                  fontFamily: 'GE-SS-Two-Light',
                ),
                decoration: const InputDecoration(
                  hintText: 'تأكيد رمز المرور الجديد',
                  hintStyle: TextStyle(
                    color: Color(0xFF888888),
                    fontFamily: 'GE-SS-Two-Light',
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
            left: 100,
            child: SizedBox(
              width: 345,
              child: const Column(
                children: [
                  Text(
                    'الرجاء اختيار رمز مرور يحقق الشروط التالية:',
                    style: TextStyle(
                      color: Color(0xFF838383),
                      fontSize: 9,
                      fontFamily: 'GE-SS-Two-Light',
                    ),
                    textAlign: TextAlign.right,
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
                      fontFamily: 'GE-SS-Two-Light',
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),

          // Submit Button
          Positioned(
            bottom: 40,
            left: (MediaQuery.of(context).size.width - 220) / 2,
            child: SizedBox(
              width: 220,
              height: 38,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D3D3D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  shadowColor: Colors.black,
                  elevation: 5,
                ),
                onPressed: () {
                  _resetPassword(); // Call the reset password function
                },
                child: const Text(
                  'تعديل',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'GE-SS-Two-Light',
                  ),
                ),
              ),
            ),
          ),

          // Error/Confirmation Message
          if (_showErrorNotification)
            Positioned(
              bottom: 100,
              left: (MediaQuery.of(context).size.width - 300) / 2,
              child: Text(
                _errorMessage,
                style: const TextStyle(
                  color: Colors.red, // Display error message in red
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
