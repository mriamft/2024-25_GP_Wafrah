import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:wafrah/OTP_page.dart';
import 'package:wafrah/forget_pass_page.dart';
import 'package:wafrah/signup_page.dart' as signup;
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool showErrorNotification = false;
  String errorMessage = '';
  Color notificationColor =
      const Color(0xFFC62C2C); // Default notification color

  Color _arrowColor = Colors.white; // Default color for the arrow
  Color _buttonColor = Colors.white; // Default color for the button
  Color _signupColor = Colors.white; // Default color for the signup text

  bool _isPasswordVisible = false;


  // Show notification method
  void showNotification(String message,
      {Color color = const Color(0xFFC62C2C)}) {
    setState(() {
      errorMessage = message;
      notificationColor = color; // Set notification color dynamically
      showErrorNotification = true;
    });

    Timer(const Duration(seconds: 10), () {
      setState(() {
        showErrorNotification = false;
      });
    });
  }

  // Handle login logic with API call
  Future<void> handleLogin() async {
    String phoneNumber = phoneNumberController.text.trim();
    String password = passwordController.text.trim();

    if (phoneNumber.isEmpty || password.isEmpty) {
      showNotification('حدث خطأ ما\nلم تقم بملء جميع الحقول');
      return;
    }

    try {
      // Send request to the server to validate login
      final url = Uri.parse('https://514b-212-57-208-72.ngrok-free.app/login');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({'phoneNumber': phoneNumber, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['success']) {
          String userName =
              responseBody['userName']; // Fetch full name from server

          // Send OTP for final verification after login
          sendOTP(phoneNumber, password, userName);
        } else {
          showNotification('رقم الجوال أو رمز المرور غير صحيحين');
        }
      } else {
        showNotification('حدث خطأ ما\nفشل في عملية تسجيل الدخول');
      }
    } catch (error) {
      showNotification('حدث خطأ ما\nفشل في عملية تسجيل الدخول');
    }
  }

  // Method to send OTP to the user and navigate to OTPPage
  Future<void> sendOTP(
      String phoneNumber, String password, String fullName) async {
    final url = Uri.parse('https://514b-212-57-208-72.ngrok-free.app/send-otp');
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
            firstName: fullName.split(' ')[0],
            lastName:
                fullName.split(' ').length > 1 ? fullName.split(' ')[1] : '',
            password: password,
            isSignUp: false,
            isForget: false,
          ),
        ),
      );
    } else {
      showNotification('فشل في إرسال رمز التحقق');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                // Back Arrow Icon
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
                  left: 140,
                  top: 161,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 90,
                    height: 82,
                  ),
                ),

                // Phone Number Input Field with Gradient Bar
                Positioned(
                  left: 24,
                  right: 24,
                  top: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextField(
                        controller: phoneNumberController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+\-() ]'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          hintText: '(+966555555555) رقم الجوال',
                          hintStyle: TextStyle(
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
                ),
// Password Input Field with Toggle Visibility (Icon Adjusted Slightly)
Positioned(
  left: 24,
  right: 24,
  top: 380,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      TextField(
        controller: passwordController,
        obscureText: !_isPasswordVisible, // Toggle visibility based on state
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: 'رمز المرور',
          hintStyle: const TextStyle(
            fontFamily: 'GE-SS-Two-Light',
            fontSize: 14,
            color: Colors.white,
          ),
          border: InputBorder.none,
          prefixIcon: Transform.translate(
            offset: const Offset(8, -5), // Move right (8) and up (-5)
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
          contentPadding: const EdgeInsets.only(left: 10), // Adjust content padding if needed
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
),

                // Login Button
                Positioned(
                  left: (MediaQuery.of(context).size.width - 308) / 2,
                  top: 650,
                  child: GestureDetector(
                    onTap: handleLogin,
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
                          'تسجيل',
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

                // Sign Up Text
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTapDown: (_) {
                          setState(() {
                            _signupColor = const Color(0xFFB0B0B0);
                          });
                        },
                        onTapUp: (_) {
                          setState(() {
                            _signupColor = Colors.white;
                          });
                        },
                        onTapCancel: () {
                          setState(() {
                            _signupColor = Colors.white;
                          });
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const signup.SignUpPage()),
                          );
                        },
                        child: Text(
                          'سجل الآن',
                          style: TextStyle(
                            color: _signupColor,
                            fontFamily: 'GE-SS-Two-Light',
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ليس لديك حساب؟',
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

          // Forgot Password Text
          Positioned(
            left: 25,
            top: 440,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgetPassPage(),
                  ),
                );
              },
              child: const Text(
                'هل نسيت كلمة المرور؟',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'GE-SS-Two-Light',
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
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
    );
  }
}
