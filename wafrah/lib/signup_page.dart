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
  bool isPasswordMatch = true; // Add this under existing state variables
  bool showErrorNotification = false;
  String errorMessage = '';
  Color notificationColor = const Color(0xFFC62C2C); // Default red color

  bool _isArrowPressed = false;
  bool _isLoginButtonPressed = false;
  bool _isLoginTextPressed = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  Timer? _notificationTimer;

  // State variables to track password criteria
  bool isLengthValid = false;
  bool isNumberValid = false;
  bool isLowercaseValid = false;
  bool isUppercaseValid = false;
  bool isSymbolValid = false;

  // State for phone number validation
  bool isPhoneNumberValid = true;

  void validateConfirmPassword(String confirmPassword) {
    setState(() {
      isPasswordMatch = passwordController.text == confirmPassword;
    });
  }

  // Show notification method
  void showNotification(String message,
      {Color color = const Color(0xFFC62C2C)}) {
    setState(() {
      errorMessage = message;
      notificationColor = color;
      showErrorNotification = true;
    });

    // Cancel any previous timer to prevent multiple timers from stacking
    _notificationTimer?.cancel();
    _notificationTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          showErrorNotification = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel(); // Safely cancel the timer if active

    // Dispose text controllers to avoid memory leaks
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // Method to validate password complexity

  // Check if the phone number exists in the database
  Future<bool> phoneNumberExists(String phoneNumber) async {
    final url =
        Uri.parse('https://9b08-94-96-163-36.ngrok-free.app/checkPhoneNumber');
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

  // Method to validate phone number format
  void validatePhoneNumber(String phoneNumber) {
    setState(() {
      isPhoneNumberValid = RegExp(r'^\+9665\d{8}$').hasMatch(phoneNumber);
    });
  }

  // Method to hash the password
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Method to send OTP to the user
  Future<void> sendOTP(String phoneNumber, String firstName, String lastName,
      String password) async {
    final url = Uri.parse('https://9b08-94-96-163-36.ngrok-free.app/send-otp');
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

    if (!validatePasswordInput(password)) {
      showNotification('حدث خطأ ما\nرمز المرور لا يحقق الشروط المذكورة');
      return;
    }

    // If valid, send OTP before adding the user
    sendOTP(phoneNumber, firstName, lastName, password);
  }

  // Updated method to validate password complexity
  bool validatePasswordInput(String password) {
    bool isValid = false;

    setState(() {
      isLengthValid = password.length >= 8;

      isNumberValid = password.contains(RegExp(r'\d'));

      isLowercaseValid = password.contains(RegExp(r'[a-z]'));

      isUppercaseValid = password.contains(RegExp(r'[A-Z]'));

      isSymbolValid = password.contains(RegExp(r'[!@#\$&*~]'));

      // Check if all conditions are met

      isValid = isLengthValid &&
          isNumberValid &&
          isLowercaseValid &&
          isUppercaseValid &&
          isSymbolValid;
    });

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  left: -1, // Adjusted x position
                  top: -99, // Adjusted y position
                  child: Opacity(
                    opacity: 0.05, // 15% opacity
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 509,
                      height: 470,
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 15,
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isArrowPressed = true),
                    onTapUp: (_) {
                      setState(() => _isArrowPressed = false);
                      Navigator.pop(context); // Navigate to the previous page
                    },
                    onTapCancel: () => setState(() => _isArrowPressed = false),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: _isArrowPressed ? Colors.grey : Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                _buildInputField(
                  top: 140,
                  hintText: 'الاسم الأول',
                  controller: firstNameController,
                  onChanged: (value) {
                    firstNameController.text =
                        value.replaceAll(RegExp(r'[^a-zA-Zأ-ي]'), '');
                    firstNameController.selection = TextSelection.fromPosition(
                        TextPosition(offset: firstNameController.text.length));
                  },
                ),
                _buildInputField(
                  top: 200,
                  hintText: 'الاسم الأخير',
                  controller: lastNameController,
                  onChanged: (value) {
                    lastNameController.text =
                        value.replaceAll(RegExp(r'[^a-zA-Zأ-ي]'), '');
                    lastNameController.selection = TextSelection.fromPosition(
                        TextPosition(offset: lastNameController.text.length));
                  },
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  top: 260,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextField(
                        controller: phoneNumberController,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) => validatePhoneNumber(value),
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          hintText: '(+966555555555) رقم الجوال',
                          hintStyle: TextStyle(
                            fontFamily: 'GE-SS-Two-Light',
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        cursorColor: Colors.white,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 313,
                        height: 2.95,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isPhoneNumberValid
                                ? [const Color(0xFF60B092), Colors.white]
                                : [Colors.red, Colors.red],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                      if (!isPhoneNumberValid)
                        const Text(
                          'صيغة خاطئة',
                          style: TextStyle(
                            fontFamily: 'GE-SS-Two-Light',
                            fontSize: 12,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.right,
                        ),
                    ],
                  ),
                ),
                _buildInputField(
                  top: 320,
                  hintText: 'رمز المرور',
                  controller: passwordController,
                  obscureText:
                      !_isPasswordVisible, // Toggle visibility based on state
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(
                        left:
                            5.0), // Adjust padding to move icon slightly right
                    child: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  onChanged: validatePasswordInput, // Validate on change
                ),
                _buildInputField(
                  top: 380,
                  hintText: 'تأكيد رمز المرور',
                  controller: confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  onChanged: (value) =>
                      validateConfirmPassword(value), // Add this to validate
                ),
                if (!isPasswordMatch)
                  const Positioned(
                    left: 24,
                    right: 24,
                    top: 435, // Adjust position to place under the input bar
                    child: Text(
                      'رمز مرور غير متطابق',
                      style: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 12,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                Positioned(
                  left: 24,
                  right: 10,
                  top: 460,
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
              left: 19,
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
    Widget? prefixIcon, // Update this to prefixIcon
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
              prefixIcon: prefixIcon, // Update this to prefixIcon
            ),
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
          ),
          const SizedBox(height: 5),
          Container(
            width: 313,
            height: 2.95,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    controller == confirmPasswordController && !isPasswordMatch
                        ? [Colors.red, Colors.red]
                        : [const Color(0xFF60B092), Colors.white],
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
