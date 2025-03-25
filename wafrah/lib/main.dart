import 'package:flutter/material.dart';
import 'dart:math';
import 'login_page.dart';
import 'info_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Add the navigator key
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/info': (context) => const InfoPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _dragValue = 0.0;
  final double buttonWidth = 308.0;
  final double circleSize = 40.0;
  final double startPositionOffset = 10.0;

  Color circleColor = const Color(0xFFD9D9D9);
  Color loginTextColor = const Color(0xFF2C8C68);
  bool isCirclePressed = false;
  bool isLoginPressed = false;

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
            child: const Column(
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
                    color: const Color(0xFF2C8C68),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: (1 - _dragValue).clamp(0.0, 1.0),
                      child: const Text(
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
                            builder: (context) => const InfoPage(),
                          ),
                        );
                        // Drag "ابدأ" for smooth transition
                        Future.delayed(const Duration(milliseconds: 300), () {
                          setState(() {
                            _dragValue = 0.0;
                          });
                        });
                      } else {
                        setState(() {
                          _dragValue = 0.0;
                        });
                      }
                    },
                    child: Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 4.0),
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
                    child: const Icon(
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
                    child: const Icon(
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
                    child: const Icon(
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: Text(
                    'سجل الدخول',
                    style: TextStyle(
                      fontSize: 16,
                      color: loginTextColor,
                      fontFamily: 'GE-SS-Two-Light',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'لديك حساب؟',
                  style: TextStyle(
                    fontSize: 16,
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
