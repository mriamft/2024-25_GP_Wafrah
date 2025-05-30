import 'package:flutter/material.dart';
import 'package:wafrah/login_page.dart';
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
  Color notificationColor = const Color(0xFFC62C2C);

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // State variables to track password criteria 
  bool isLengthValid = false;
  bool isNumberValid = false;
  bool isLowercaseValid = false;
  bool isUppercaseValid = false;
  bool isSymbolValid = false;

  bool isConfirmPasswordMatching = true;
  bool confirmPasswordClicked = false;

  Timer? _notificationTimer; 

  @override
  void dispose() {
    _notificationTimer?.cancel(); 
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Show notification method 
  void showNotification(String message,
      {Color color = const Color(0xFFC62C2C)}) {
    if (mounted) {
      setState(() {
        errorMessage = message;
        notificationColor = color;
        showErrorNotification = true;
      });

      _notificationTimer?.cancel();
      _notificationTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            showErrorNotification = false;
          });
        }
      });
    }
  }

  // validate the Password Input if it is satisfy the critira
  void validatePasswordInput(String password) {
    setState(() {
      isLengthValid = password.length >= 8;
      isNumberValid = password.contains(RegExp(r'\d'));
      isLowercaseValid = password.contains(RegExp(r'[a-z]'));
      isUppercaseValid = password.contains(RegExp(r'[A-Z]'));
      isSymbolValid = password.contains(RegExp(r'[!@#\$&*~]'));
    });
  }

  //Check if the passwords matched
  void validateConfirmPassword(String confirmPassword) {
    setState(() {
      isConfirmPasswordMatching = confirmPassword == passwordController.text;
    });
  }

  bool isValidPassword(String password) {
    return isLengthValid &&
        isNumberValid &&
        isLowercaseValid &&
        isUppercaseValid &&
        isSymbolValid;
  }

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

    if (!isValidPassword(password)) {
      showNotification(
          ':حدث خطأ ما\nرمز المرور لا يحقق الشروط ');
      return;
    }

    resetPassword(widget.phoneNumber, password);
  }

  // Update the passowrd in tha database
  Future<void> resetPassword(String phoneNumber, String newPassword) async {
    final url =
        Uri.parse('https://login-service.ngrok.io/forget-password');

    final response = await http.post(
      url,  
      headers: {"Content-Type": "application/json"},
      body:
          json.encode({'phoneNumber': phoneNumber, 'newPassword': newPassword}),
    );

    if (response.statusCode == 200) {
      showNotification('تم تحديث كلمة السر بنجاح',
          color: const Color(0xFF0FBE7C));
      await Future.delayed(const Duration(seconds: 2));
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

  Widget _buildInputField({
    required double top,
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? prefixIcon,
    Function(String)? onChanged,
    Function()? onTap,
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
            obscureText: obscureText,
            onChanged: onChanged,
            onTap: onTap,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'GE-SS-Two-Light',
                fontSize: 14,
                color: Colors.white,
              ),
              prefixIcon: prefixIcon,
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
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),

            // Logo Image
            Positioned(
              left: 140,
              top: 102,
              child: Image.asset(
                'assets/images/logo.png',
                width: 129,
                height: 116,
              ),
            ),

            // Title
            const Positioned(
              top: 230,
              left: 100,
              child: Text(
                'تغيير كلمة المرور',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'GE-SS-Two-Bold',
                ),
              ),
            ),

            // Password Input Fields
            _buildInputField(
              top: 280,
              hintText: 'رمز المرور',
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              prefixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              onChanged: (value) {
                validatePasswordInput(value);
                if (confirmPasswordClicked) {
                  validateConfirmPassword(confirmPasswordController.text);
                }
              },
            ),

            _buildInputField(
              top: 350,
              hintText: 'تأكيد رمز المرور',
              controller: confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              prefixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              onChanged: validateConfirmPassword,
              onTap: () {
                setState(() {
                  confirmPasswordClicked = true;
                });
              },
            ),

            // Confirm Password Mismatch Warning
            if (confirmPasswordClicked && !isConfirmPasswordMatching)
              const Positioned(
                left: 24,
                right: 24,
                top: 411,
                child: Text(
                  'رمز مرور غير متطابق',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'GE-SS-Two-Light',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC62C2C),
                  ),
                ),
              ),

            // Password Instructions
            Positioned(
              left: 24,
              right: 10,
              top: 448,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'الرجاء اختيار رمز مرور يحقق الشروط التالية:',
                    style: TextStyle(
                      fontFamily: 'GE-SS-Two-Light',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
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
                  _buildCriteriaText('أن يحتوي على رمز خاص.', isSymbolValid),
                ],
              ),
            ),

            Positioned(
              left: (MediaQuery.of(context).size.width - 308) / 2,
              top: 570,
              child: GestureDetector(
                onTap: handleNext,
                child: Container(
                  width: 308,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
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

            // Notification
            if (showErrorNotification)
              Positioned(
                top: 23,
                left: 19,
                child: Container(
                  width: 353,
                  height: 57,
                  decoration: BoxDecoration(
                    color: notificationColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      // Wrap the Text widget with Expanded
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'GE-SS-Two-Light',
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow
                              .ellipsis, // Add this line for overflow handling
                        ),
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

  Widget _buildCriteriaText(String text, bool isValid) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontFamily: 'GE-SS-Two-Light',
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: isValid ? Colors.white : const Color(0xFFC62C2C),
        height: 1.21,
      ),
    );
  }
}
