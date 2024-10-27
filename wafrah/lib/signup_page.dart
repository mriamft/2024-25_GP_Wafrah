import 'package:flutter/material.dart';
import 'package:wafrah/OTP_page.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:wafrah/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool showErrorNotification = false;
  String errorMessage = '';
  Color notificationColor = const Color(0xFFC62C2C); // Default red color

  bool _isArrowPressed = false;
  bool _isLoginButtonPressed = false;
  bool _isLoginTextPressed = false;

  // State variables to track password criteria
  bool isLengthValid = false;
  bool isNumberValid = false;
  bool isLowercaseValid = false;
  bool isUppercaseValid = false;
  bool isSymbolValid = false;

  // Show notification method
  void showNotification(String message,
      {Color color = const Color(0xFFC62C2C)}) {
    setState(() {
      errorMessage = message;
      notificationColor = color; // Set the dynamic color
      showErrorNotification = true;
    });

    Timer(const Duration(seconds: 10), () {
      setState(() {
        showErrorNotification = false;
      });
    });
  }

  // Method to validate password complexity
  bool validatePassword(String password) {
    final RegExp passwordRegExp =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  // Check if the phone number exists in the database
  Future<bool> phoneNumberExists(String phoneNumber) async {
    final url =
        Uri.parse('https://0813-78-95-248-162.ngrok-free.app/checkPhoneNumber');
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

  // Method to send OTP to the user
  Future<void> sendOTP(String phoneNumber, String firstName, String lastName,
      String password) async {
    final url = Uri.parse('https://0813-78-95-248-162.ngrok-free.app/send-otp');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({'phoneNumber': phoneNumber}),
    );

    if (response.statusCode == 200) {
      // Navigate to OTP page after OTP is sent
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPPage(
            phoneNumber: phoneNumber,
            firstName: firstName,
            lastName: lastName,
            password: password,
            isSignUp: true, // This indicates a new user sign-up
            isForget: false,
          ),
        ),
      );
    } else {
      showNotification('فشل إرسال رمز التحقق، حاول مجددًا بعد قليل');
    }
  }

  // Method to handle sign-up logic
  void signUp() async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String phoneNumber = phoneNumberController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        phoneNumber.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
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

    // If valid, send OTP before adding the user
    sendOTP(phoneNumber, firstName, lastName, password);
  }

  // Updated method to validate password complexity
  void validatePasswordInput(String password) {
    setState(() {
      isLengthValid = password.length >= 8;
      isNumberValid = password.contains(RegExp(r'\d'));
      isLowercaseValid = password.contains(RegExp(r'[a-z]'));
      isUppercaseValid = password.contains(RegExp(r'[A-Z]'));
      isSymbolValid = password.contains(RegExp(r'[!@#\$&*~]'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
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
                  onChanged: validatePasswordInput, // Validate on change
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'الرجاء اختيار رمز مرور يحقق الشروط التالية:',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'GE-SS-Two-Light',
                          fontSize: 9,
                          fontWeight: FontWeight.bold, // Make text bold
                          color: Colors.white,
                          height: 1.21,
                        ),
                      ),
                      _buildCriteriaText(
                          'أن يتكون من 8 خانات على الأقل.', isLengthValid),
                      _buildCriteriaText('أن يحتوي على رقم.', isNumberValid),
                      _buildCriteriaText(
                          'أن يحتوي على حرف صغير.', isLowercaseValid),
                      _buildCriteriaText(
                          'أن يحتوي على حرف كبير.', isUppercaseValid),
                      _buildCriteriaText(
                          'أن يحتوي على رمز خاص.', isSymbolValid),
                    ],
                  ),
                ),
                Positioned(
                  left: (MediaQuery.of(context).size.width - 308) / 2,
                  top: 662,
                  child: GestureDetector(
                    onTapDown: (_) =>
                        setState(() => _isLoginButtonPressed = true),
                    onTapUp: (_) {
                      setState(() => _isLoginButtonPressed = false);
                      signUp();
                    },
                    onTapCancel: () =>
                        setState(() => _isLoginButtonPressed = false),
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
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
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
                        onTapDown: (_) =>
                            setState(() => _isLoginTextPressed = true),
                        onTapUp: (_) {
                          setState(() => _isLoginTextPressed = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        onTapCancel: () =>
                            setState(() => _isLoginTextPressed = false),
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
                      const SizedBox(width: 4),
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
    );
  }

  Widget _buildInputField({
    required double top,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Function(String)? onChanged,
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
            onChanged: onChanged, // Validate on change
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

  Widget _buildCriteriaText(String text, bool isValid) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontFamily: 'GE-SS-Two-Light',
        fontSize: 9,
        fontWeight: FontWeight.bold, // Make text bold
        color: isValid
            ? Colors.white
            : const Color(0xFFC62C2C), // Change color based on validity
        height: 1.21,
      ),
    );
  }
}
