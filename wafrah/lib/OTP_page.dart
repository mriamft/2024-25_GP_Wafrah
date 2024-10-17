import 'package:flutter/material.dart';
import 'dart:async';

class OTPPage extends StatefulWidget {
  final String phoneNumber;
  final String firstName; // Added
  final String lastName; // Added
  final String password; // Added

  OTPPage({
    required this.phoneNumber,
    required this.firstName, // Added
    required this.lastName, // Added
    required this.password, // Added
  });

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final TextEditingController otpController = TextEditingController();
  bool canResend = false;
  late Timer _timer;
  int resendTimeLeft = 180; // 3 minutes in seconds

  @override
  void initState() {
    super.initState();
    startResendOTPCountdown(); // Start countdown on page load
  }

  void startResendOTPCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (resendTimeLeft > 0) {
          resendTimeLeft--;
        } else {
          canResend = true;
          _timer.cancel(); // Stop the timer when it reaches 0
        }
      });
    });
  }

  // Method to verify OTP without Firebase authentication
  void verifyOTP() {
    String otp = otpController.text.trim();

    if (otp.isNotEmpty) {
      // Add your custom OTP verification logic here
      // Navigate to the home page after successful OTP verification
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showErrorSnackBar('Please enter the OTP.');
    }
  }

  // Snackbar to show error messages
  void _showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Method to resend OTP if 3 minutes have passed (without Firebase)
  void resendOTP() {
    if (canResend) {
      // Add your custom resend OTP logic here
      print('OTP resent');
      setState(() {
        resendTimeLeft = 180; // Reset the countdown to 3 minutes
        canResend = false;
      });
      startResendOTPCountdown(); // Restart the countdown
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A996F), Color(0xFF09462F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            // Splash Image
            Positioned(
              left: 140,
              top: 130, // Positioned the same as in sign-up page
              child: Image.asset(
                'assets/images/logo.png',
                width: 90,
                height: 82,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center alignment
                children: [
                  SizedBox(
                      height:
                          230), // Adjusted to move the text under the splash image
                  // First Text (Styled as per the image you provided)
                  Text(
                    'كلمة المرور لمرة واحدة',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'GE SS Two',
                      color: Colors.white,
                      height: 1.21,
                    ),
                    textAlign: TextAlign.center, // Center the text
                  ),
                  SizedBox(height: 10),
                  // Second Text with phone number (Styled as per the image)
                  Text(
                    'يرجى كتابة رمز التحقق كلمة المرور لمرة واحدة المرسلة إلى رقم الهاتف ${widget.phoneNumber}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'GE SS Two',
                      color: Colors.white,
                      height: 1.24,
                    ),
                    textAlign: TextAlign.center, // Center the text
                  ),
                  SizedBox(height: 20),
                  // OTP input fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _otpField(),
                      _otpField(),
                      _otpField(),
                      _otpField(),
                      _otpField(),
                      _otpField(),
                    ],
                  ),
                  SizedBox(height: 40),
                  // Updated Button (Styled same as sign-up page)
                  ElevatedButton(
                    onPressed: verifyOTP,
                    child: Text('التحقق من الرمز'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 5,
                      minimumSize:
                          Size(308, 52), // Ensure the button is the same size
                    ),
                  ),
                  SizedBox(height: 20),
                  // Resend OTP text
                  GestureDetector(
                    onTap: canResend
                        ? resendOTP
                        : null, // Only allow resend after 3 minutes
                    child: Text(
                      canResend
                          ? 'إعادة إرسال رمز التحقق؟'
                          : 'إعادة الإرسال بعد ${resendTimeLeft} ثانية',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: canResend
                            ? Colors.white
                            : Colors.grey, // Disable link while waiting
                      ),
                      textAlign: TextAlign.right,
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

  // OTP Field Widget for the OTP input
  Widget _otpField() {
    return Container(
      width: 40, // Adjusted width to fit 6 fields
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        style:
            TextStyle(color: Colors.white), // Set the input text color to white
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus(); // Move focus to the next field
          }
          // Auto-submit OTP once 6 digits are entered
          if (otpController.text.length == 6) {
            verifyOTP();
          }
        },
      ),
    );
  }
}