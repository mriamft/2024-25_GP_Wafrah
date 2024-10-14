import 'package:flutter/material.dart';
import 'home_page.dart'; // Import the home_page.dart file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Color _arrowColor = Colors.white; // Default color for the arrow
  Color _buttonColor = Colors.white; // Default color for the button
  Color _signupColor = Colors.white; // Default color for the signup text

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Allows the body to resize when the keyboard appears
      body: Container(
        decoration: BoxDecoration(
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
                  Navigator.pop(context); // Navigate back to splash page
                },
                onTapDown: (_) {
                  setState(() {
                    _arrowColor = Colors.grey; // Darker color on press
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _arrowColor = Colors.white; // Reset color after press
                  });
                },
                onTapCancel: () {
                  setState(() {
                    _arrowColor =
                        Colors.white; // Reset color if tap is canceled
                  });
                },
                child: Icon(
                  Icons.arrow_forward_ios, // Right arrow
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
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'رقم الجوال',
                      hintStyle: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      border: InputBorder.none, // No default border
                    ),
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white, // White cursor
                  ),
                  // Custom Gradient Line
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
            ),

            // Password Input Field with Gradient Bar
            Positioned(
              left: 24,
              right: 24,
              top: 380,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    obscureText: true, // Hide password
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'رمز المرور',
                      hintStyle: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      border: InputBorder.none, // No default border
                    ),
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white, // White cursor
                  ),
                  // Custom Gradient Line
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
            ),

            // Login Button
            Positioned(
              left: (MediaQuery.of(context).size.width - 308) / 2,
              top: 650,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomePage()), // Navigate to home page
                  );
                },
                onTapDown: (_) {
                  setState(() {
                    _buttonColor = Color(0xFFB0B0B0); // Darker color on press
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _buttonColor = Colors.white; // Reset color after press
                  });
                },
                onTapCancel: () {
                  setState(() {
                    _buttonColor =
                        Colors.white; // Reset color if tap is canceled
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
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'تسجيل',
                      style: TextStyle(
                        color: Color(0xFF3D3D3D),
                        fontFamily: 'GE-SS-Two-Light', // Light font
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
                  // "سجل الآن" text
                  GestureDetector(
                    onTapDown: (_) {
                      setState(() {
                        _signupColor =
                            Color(0xFFB0B0B0); // Darker color on press
                      });
                    },
                    onTapUp: (_) {
                      setState(() {
                        _signupColor = Colors.white; // Reset color after press
                      });
                    },
                    onTapCancel: () {
                      setState(() {
                        _signupColor =
                            Colors.white; // Reset color if tap is canceled
                      });
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SignUpPage()), // Navigate to sign-up page
                      );
                    },
                    child: Text(
                      'سجل الآن',
                      style: TextStyle(
                        color: _signupColor,
                        fontFamily: 'GE-SS-Two-Light', // Light font
                        fontSize: 14,
                        decoration: TextDecoration.underline, // Underline
                        decorationColor: Colors.white, // White underline
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  // "ليس لديك حساب؟" text
                  Text(
                    'ليس لديك حساب؟',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontFamily: 'GE-SS-Two-Light', // Light font
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for SignUpPage
class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Sign Up Page')),
    );
  }
}