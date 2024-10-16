import 'package:flutter/material.dart';
import 'package:wafrah/OTP_page.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'otp_service.dart'; // Import the OTP service

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final OTPService _otpService = OTPService(); // Initialize OTP service

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool showErrorNotification = false;
  String errorMessage = '';

  bool _isArrowPressed = false;
  bool _isLoginButtonPressed = false;
  bool _isLoginTextPressed = false;

  // Show notification method
  void showNotification(String message, {Color color = const Color(0xFFC62C2C)}) {
    setState(() {
      errorMessage = message;
      showErrorNotification = true;
    });

    Timer(Duration(seconds: 10), () {
      setState(() {
        showErrorNotification = false;
      });
    });
  }

  // Method to validate password complexity
  bool validatePassword(String password) {
    final RegExp passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
    );
    return passwordRegExp.hasMatch(password);
  }

  // Check if the phone number exists in the database
  Future<bool> phoneNumberExists(String phoneNumber) async {
    final url = Uri.parse('https://3f89-82-167-111-148.ngrok-free.app/checkPhoneNumber');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({'phoneNumber': phoneNumber}),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['exists'];
    } else {
      showNotification('حدث خطأ ما\nفشل في التحقق من رقم الجوال');
      return false;
    }
  }

  // Method to handle sign-up logic and send OTP
  void handleSignUp() async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String phoneNumber = phoneNumberController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (firstName.isEmpty || lastName.isEmpty || phoneNumber.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showNotification('حدث خطأ ما\nلم تقم بملء جميع الحقول');
      return;
    }

    if (await phoneNumberExists(phoneNumber)) {
      showNotification('حدث خطأ ما\nرقم الجوال موجود مسبقاً');
      return;
    }

    if (password != confirmPassword) {
      showNotification('حدث خطأ ما\nرمز المرور غير متطابق');
      return;
    }

    if (!validatePassword(password)) {
      showNotification(
          'حدث خطأ ما\nرمز المرور لا يحقق الشروط: 8 خانات على الأقل، حرف صغير، حرف كبير، رقم ورمز خاص');
      return;
    }

    // If everything is valid, send OTP to user's phone
    await _otpService.sendOTP(phoneNumber);

    // Navigate to the OTP page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPPage(
          phoneNumber: phoneNumber,
          firstName: firstName,
          lastName: lastName,
          password: password,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2A996F), Color(0xFF09462F)],
              ),
            ),
            child: Stack(
              children: [
                // Other widgets and styling here...

                // "تسجيل الدخول" button logic
                Positioned(
                  left: (MediaQuery.of(context).size.width - 308) / 2,
                  top: 662,
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isLoginButtonPressed = true),
                    onTapUp: (_) {
                      setState(() => _isLoginButtonPressed = false);
                      handleSignUp();
                    },
                    onTapCancel: () => setState(() => _isLoginButtonPressed = false),
                    child: Container(
                      width: 308,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _isLoginButtonPressed ? Colors.grey[300] : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'تسجيل الدخول',
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
                // Other widgets...
              ],
            ),
          ),
          if (showErrorNotification)
            Positioned(
              top: 23,
              left: 4,
              child: Container(
                width: 353,
                height: 57,
                decoration: BoxDecoration(
                  color: Color(0xFFC62C2C),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Text(
                        errorMessage,
                        style: TextStyle(
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
    );
  }
}
