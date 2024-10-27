import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wafrah/login_page.dart'; // Import the login page
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PassConfirmationPage extends StatefulWidget {
  const PassConfirmationPage({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  _PassConfirmationPage createState() => _PassConfirmationPage();
}

class _PassConfirmationPage extends State<PassConfirmationPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool showErrorNotification = false;
  String errorMessage = '';
  Color notificationColor =
      const Color(0xFFC62C2C); // Default notification color

  Color _arrowColor = Colors.white; // Default color for the arrow
  Color _buttonColor = Colors.white; // Default color for the button

  // Show notification method
  void showNotification(String message,
      {Color color = const Color(0xFFC62C2C)}) {
    setState(() {
      errorMessage = message;
      notificationColor = color; // Set notification color dynamically
      showErrorNotification = true;
    });

    Timer(const Duration(seconds: 5), () {
      setState(() {
        showErrorNotification = false;
      });
    });
  }

  // Handle next button press
  void handleNext() {
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      showNotification('حدث خطأ ما\nلم تقم بملء جميع الحقول');
      return;
    }

    if (password != confirmPassword) {
      showNotification('حدث خطأ ما\nرمز المرور غير متطابق');
      return;
    }

    // Validate password strength
    if (!isValidPassword(password)) {
      showNotification(
          'حدث خطأ ما\nرمز المرور لا يحقق الشروط: 8 خانات على الأقل، حرف صغير، حرف كبير، رقم ورمز خاص');
      return;
    }

    // Make API call to update the password in the database
    resetPassword(widget.phoneNumber, password); // Use widget.phoneNumber
  }

  bool isValidPassword(String password) {
    final regex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    return regex.hasMatch(password);
  }

  Future<void> resetPassword(String phoneNumber, String newPassword) async {
    final url =
        Uri.parse('https://0813-78-95-248-162.ngrok-free.app/reset-password');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'phoneNumber': phoneNumber,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      // Show success notification
      showNotification('تم تحديث كلمة السر بنجاح', color: Colors.grey);

      // Wait for a moment to allow the user to see the notification
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to the Login Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } else {
      showNotification('فشل في تحديث كلمة السر', color: Colors.red);
    }
  }

  // Build input field method
  Widget _buildInputField({
    required double top,
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Positioned(
      left: 24,
      right: 24,
      top: top,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: controller,
            textAlign: TextAlign.right,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'GE-SS-Two-Light',
                fontSize: 14,
                color: Colors.white,
              ),
              border: InputBorder.none,
            ),
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
          ),
          const SizedBox(height: 5),
          Container(
            width: 313,
            height: 2.95,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF60B092), Colors.white],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A996F), Color(0xFF09462F)],
          ),
        ),
        child: Stack(
          children: [
            // Back Arrow
            Positioned(
              top: 60,
              right: 15,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                onTapDown: (_) {
                  setState(() {
                    _arrowColor = Colors.grey;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _arrowColor = Colors.white;
                  });
                },
                onTapCancel: () {
                  setState(() {
                    _arrowColor = Colors.white;
                  });
                },
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: _arrowColor,
                  size: 28,
                ),
              ),
            ),

            // Logo Image
            Positioned(
              left: 118,
              top: 102,
              child: Image.asset(
                'assets/images/logo.png',
                width: 129,
                height: 116,
              ),
            ),

            // Title
            const Positioned(
              top: 263,
              left: 75,
              child: Text(
                'تغيير كلمة المرور',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'GE-SS-Two-Bold', // Same font as the project
                ),
              ),
            ),

            // Password Input Fields
            _buildInputField(
              top: 320,
              hintText: 'رمز المرور',
              controller: passwordController,
              obscureText: true,
            ),
            _buildInputField(
              top: 400,
              hintText: 'تأكيد رمز المرور',
              controller: confirmPasswordController,
              obscureText: true,
            ),

            // Password Instructions
            Positioned(
              left: 24,
              right: 10,
              top: 465,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  'الرجاء اختيار رمز مرور يحقق الشروط التالية:\n'
                  'أن يتكون من 8 خانات على الأقل.\n'
                  'أن يحتوي على رقم.\n'
                  'أن يحتوي على حرف صغير.\n'
                  'أن يحتوي على حرف كبير.\n'
                  'أن يحتوي على رمز خاص.',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Light',
                    fontSize: 9,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 1.21,
                  ),
                ),
              ),
            ),

            // Next Button
            Positioned(
              left: (MediaQuery.of(context).size.width - 308) / 2,
              top: 570,
              child: GestureDetector(
                onTap: handleNext,
                onTapDown: (_) {
                  setState(() {
                    _buttonColor = const Color(0xFFB0B0B0);
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _buttonColor = Colors.white;
                  });
                },
                onTapCancel: () {
                  setState(() {
                    _buttonColor = Colors.white;
                  });
                },
                child: Container(
                  width: 308,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _buttonColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'تغيير',
                      style: TextStyle(
                        color: Color(0xFF3D3D3D),
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Error Notification
            if (showErrorNotification)
              Positioned(
                top: 23,
                left: 4,
                child: Container(
                  width: 353,
                  height: 57,
                  decoration: BoxDecoration(
                    color: notificationColor, // Use dynamic color
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'GE-SS-Two-Light',
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
