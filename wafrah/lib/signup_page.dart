import 'package:flutter/material.dart';
import 'package:wafrah/OTP_page.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:wafrah/login_page.dart';
import 'package:wafrah/home_page.dart'; // Import HomePage for navigation

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
    final url = Uri.parse('https://534b-82-167-111-148.ngrok-free.app/checkPhoneNumber');
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

  // Method to hash the password
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Method to handle sign-up logic
  void signUp() async {
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

    // Send data to backend
    final url = Uri.parse('https://534b-82-167-111-148.ngrok-free.app/adduser');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'userName': '$firstName $lastName', // Store full name
        'phoneNumber': phoneNumber,
        'password': password
      }),
    );

    if (response.statusCode == 200) {
      showNotification('تم تسجيل الدخول بنجاح', color: Colors.grey);

      // Redirect to HomePage after successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userName: '$firstName $lastName', phoneNumber:phoneNumber), // Pass full name
        ),
      );
    } else {
      showNotification('حدث خطأ ما\nفشل في عملية التسجيل');
    }
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
                Positioned(
                  top: 60,
                  right: 15,
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isArrowPressed = true),
                    onTapUp: (_) {
                      setState(() => _isArrowPressed = false);
                      Navigator.pop(context);
                    },
                    onTapCancel: () => setState(() => _isArrowPressed = false),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: _isArrowPressed ? Colors.grey : Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                Positioned(
                  left: 140,
                  top: 130,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 90,
                    height: 82,
                  ),
                ),
                _buildInputField(
                  top: 235,
                  hintText: 'الاسم الأول',
                  controller: firstNameController,
                ),
                _buildInputField(
                  top: 300,
                  hintText: 'الاسم الأخير',
                  controller: lastNameController,
                ),
                _buildInputField(
                  top: 365,
                  hintText: '(+966555555555) رقم الجوال',
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
                ),
                _buildInputField(
                  top: 430,
                  hintText: 'رمز المرور',
                  controller: passwordController,
                  obscureText: true,
                ),
                _buildInputField(
                  top: 495,
                  hintText: 'تأكيد رمز المرور',
                  controller: confirmPasswordController,
                  obscureText: true,
                ),
                Positioned(
                  left: 24,
                  right: 10,
                  top: 570,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
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
                Positioned(
                  left: (MediaQuery.of(context).size.width - 308) / 2,
                  top: 662,
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isLoginButtonPressed = true),
                    onTapUp: (_) {
                      setState(() => _isLoginButtonPressed = false);
                      signUp();
                    },
                    onTapCancel: () => setState(() => _isLoginButtonPressed = false),
                    child: Container(
                      width: 308,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _isLoginButtonPressed
                            ? Colors.grey[300]
                            : Colors.white,
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
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTapDown: (_) => setState(() => _isLoginTextPressed = true),
                        onTapUp: (_) {
                          setState(() => _isLoginTextPressed = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                        onTapCancel: () => setState(() => _isLoginTextPressed = false),
                        child: Text(
                          'سجل الدخول',
                          style: TextStyle(
                            color: _isLoginTextPressed
                                ? Colors.grey
                                : Colors.white,
                            fontFamily: 'GE-SS-Two-Light',
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'لديك حساب؟',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontFamily: 'GE-SS-Two-Light',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
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
                  color: Color(0xFFC62C2C), // Red background
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

  Widget _buildInputField({
    required double top,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
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
            keyboardType: keyboardType,
            obscureText: obscureText,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontFamily: 'GE-SS-Two-Light',
                fontSize: 14,
                color: Colors.white,
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(color: Colors.white),
            cursorColor: Colors.white,
          ),
          SizedBox(height: 5),
          Container(
            width: 313,
            height: 2.95,
            decoration: BoxDecoration(
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
}
