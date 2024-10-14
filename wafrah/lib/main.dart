import 'package:flutter/material.dart';
import 'dart:math';
import 'signup_page.dart'; // Ensure you have this import
import 'login_page.dart'; // Import the LoginPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _dragValue = 0.0;
  final double buttonWidth = 308.0;
  final double circleSize = 40.0;
  final double startPositionOffset = 10.0;

  Color circleColor = Color(0xFFD9D9D9);
  Color loginTextColor = Color(0xFF2C8C68);
  bool isCirclePressed = false;
  bool isLoginPressed = false;

  void _onCirclePressed() {
    setState(() {
      isCirclePressed = true;
    });
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        isCirclePressed = false;
      });
    });
  }

  void _onLoginPressed() {
    setState(() {
      isLoginPressed = true;
    });
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        isLoginPressed = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            left: size.width * -0.60,
            top: -375,
            child: Transform.rotate(
              angle: 23.22 * pi / 180,
              child: Image.asset(
                'assets/images/splash_image.png',
                width: 582.3,
                height: 1066.83,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.4,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'حقق',
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.black,
                    fontFamily: 'GE-SS-Two-Bold',
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'أهدافك',
                  style: TextStyle(
                    fontSize: 50,
                    color: Color(0xFF2C8C68),
                    fontFamily: 'GE-SS-Two-Bold',
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'المالية',
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.black,
                    fontFamily: 'GE-SS-Two-Bold',
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: (size.width - buttonWidth) / 2,
            top: 640,
            child: Stack(
              children: [
                Container(
                  width: buttonWidth,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Color(0xFF2C8C68),
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
                    child: Opacity(
                      opacity: (1 - _dragValue).clamp(0.0, 1.0),
                      child: Text(
                        'ابدأ',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: 'GE-SS-Two-Light',
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: startPositionOffset +
                      _dragValue *
                          (buttonWidth - circleSize - startPositionOffset),
                  top: 6,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _dragValue -= details.primaryDelta! /
                            (buttonWidth - circleSize - startPositionOffset);
                        _dragValue = _dragValue.clamp(0.0, 1.0);
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      if (_dragValue == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpPage(),
                          ),
                        );
                      }
                    },
                    onTapDown: (_) {
                      _onCirclePressed();
                    },
                    child: Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        color: isCirclePressed ? Colors.grey : circleColor,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFF2C8C68),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 17,
                  child: Opacity(
                    opacity: (1 - _dragValue).clamp(0.0, 1.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
                Positioned(
                  left: 26,
                  top: 17,
                  child: Opacity(
                    opacity: (0.7 - _dragValue).clamp(0.0, 1.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
                Positioned(
                  left: 34,
                  top: 17,
                  child: Opacity(
                    opacity: (0.5 - _dragValue).clamp(0.0, 1.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _onLoginPressed();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LoginPage(), // Navigate to LoginPage
                      ),
                    );
                  },
                  child: Text(
                    'سجل الدخول',
                    style: TextStyle(
                      fontSize: 13,
                      color: isLoginPressed
                          ? Colors.black.withOpacity(0.5)
                          : loginTextColor,
                      fontFamily: 'GE-SS-Two-Light',
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'لديك حساب؟',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.7),
                    fontFamily: 'GE-SS-Two-Light',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// SignUpPage implementation
class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Sign Up Page'),
      ),
    );
  }
}