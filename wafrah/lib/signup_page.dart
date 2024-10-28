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
  final TextEditingController confirmPasswordController = TextEditingController();

  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  final ScrollController _scrollController = ScrollController();

  bool showErrorNotification = false;
  String errorMessage = '';
  Color notificationColor = const Color(0xFFC62C2C); // Default red color

  bool _isArrowPressed = false;
  bool _isLoginButtonPressed = false;
  bool _isLoginTextPressed = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // State variables to track password criteria
  bool isLengthValid = false;
  bool isNumberValid = false;
  bool isLowercaseValid = false;
  bool isUppercaseValid = false;
  bool isSymbolValid = false;

  // Set this to true in initState
  bool showPasswordInstructions = true;

  void showNotification(String message, {Color color = const Color(0xFFC62C2C)}) {
    setState(() {
      errorMessage = message;
      notificationColor = color;
      showErrorNotification = true;
    });

    Timer(const Duration(seconds: 10), () {
      setState(() {
        showErrorNotification = false;
      });
    });
  }

  bool validatePassword(String password) {
    final RegExp passwordRegExp =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  void validatePasswordInput(String password) {
    setState(() {
      isLengthValid = password.length >= 8;
      isNumberValid = password.contains(RegExp(r'\d'));
      isLowercaseValid = password.contains(RegExp(r'[a-z]'));
      isUppercaseValid = password.contains(RegExp(r'[A-Z]'));
      isSymbolValid = password.contains(RegExp(r'[!@#\$&*~]'));
    });
  }

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

    if (password != confirmPassword) {
      showNotification('حدث خطأ ما\nرمز المرور غير متطابق');
      return;
    }

    if (!validatePassword(password)) {
      showNotification(
          'حدث خطأ ما\nرمز المرور لا يحقق الشروط: 8 خانات على الأقل، حرف صغير، حرف كبير، رقم ورمز خاص');
      return;
    }

    try {
      final url = Uri.parse('https://your-backend-api.com/register');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPPage(
              phoneNumber: phoneNumber,
              firstName: firstName,
              lastName: lastName,
              password: password,
              isSignUp: true,
              isForget: false,
            ),
          ),
        );
      } else {
        showNotification('حدث خطأ ما\nفشل في إنشاء الحساب');
      }
    } catch (e) {
      showNotification('حدث خطأ ما\nفشل في الاتصال بالخادم');
    }
  }

  @override
  void initState() {
    super.initState();
    showPasswordInstructions = true;

    // Add listeners to ensure smooth scrolling to the desired location when fields are focused
    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent / 0.5, // Adjust this value if needed
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });

    confirmPasswordFocusNode.addListener(() {
      if (confirmPasswordFocusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent / 0.3, // Adjust this value if needed
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures the screen resizes when the keyboard appears
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Hide the keyboard when tapping outside
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
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
                      Positioned(
                        top: 235,
                        left: 24,
                        right: 24,
                        child: _buildInputField(
                          hintText: 'الاسم الأول',
                          controller: firstNameController,
                        ),
                      ),
                      Positioned(
                        top: 300,
                        left: 24,
                        right: 24,
                        child: _buildInputField(
                          hintText: 'الاسم الأخير',
                          controller: lastNameController,
                        ),
                      ),
                      Positioned(
                        top: 365,
                        left: 24,
                        right: 24,
                        child: _buildInputField(
                          hintText: '(+966555555555) رقم الجوال',
                          controller: phoneNumberController,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        top: 430,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildInputField(
                              hintText: 'رمز المرور',
                              controller: passwordController,
                              focusNode: passwordFocusNode,
                              obscureText: !_isPasswordVisible,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 30.0),
                                child: IconButton(
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
                              ),
                              onChanged: validatePasswordInput,
                            ),
                            const SizedBox(height: 10), // Space between inputs
                            _buildInputField(
                              hintText: 'تأكيد رمز المرور',
                              controller: confirmPasswordController,
                              focusNode: confirmPasswordFocusNode,
                              obscureText: !_isConfirmPasswordVisible,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 30.0),
                                child: IconButton(
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
                              ),
                            ),
                            const SizedBox(height: 10), // Space between input fields and instructions
                            if (showPasswordInstructions)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'الرجاء اختيار رمز مرور يحقق الشروط التالية:',
                                    textAlign: TextAlign.right,
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
                                  _buildCriteriaText('أن يحتوي على حرف صغير.', isLowercaseValid),
                                  _buildCriteriaText('أن يحتوي على حرف كبير.', isUppercaseValid),
                                  _buildCriteriaText('أن يحتوي على رمز خاص.', isSymbolValid),
                                ],
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: (MediaQuery.of(context).size.width - 308) / 2,
                        top: 662,
                        child: GestureDetector(
                          onTapDown: (_) => setState(() => _isLoginButtonPressed = true),
                          onTap: () async {
                            setState(() => _isLoginButtonPressed = false);
                            signUp();
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
                              onTapDown: (_) => setState(() => _isLoginTextPressed = true),
                              onTapUp: (_) {
                                setState(() => _isLoginTextPressed = false);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                );
                              },
                              onTapCancel: () => setState(() => _isLoginTextPressed = false),
                              child: Text(
                                'سجل الدخول',
                                style: TextStyle(
                                  color: _isLoginTextPressed ? Colors.grey : Colors.white,
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
                        color: notificationColor,
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
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
    FocusNode? focusNode,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Function(String)? onChanged,
    Widget? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textAlign: TextAlign.right,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontFamily: 'GE-SS-Two-Light',
              fontSize: 14,
              color: Colors.white,
            ),
            border: InputBorder.none,
            prefixIcon: prefixIcon,
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
