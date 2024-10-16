import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OTPPage extends StatefulWidget {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String password;

  OTPPage({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.password,
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

  // Method to verify OTP and add user to the database
  Future<void> verifyOTP() async {
    String otp = otpController.text.trim();

    if (otp.isNotEmpty) {
      // Simulate OTP verification (you can add actual verification logic here)
      if (otp == '123456') { // Just a dummy verification
        await addUserToDatabase(
          widget.firstName,
          widget.lastName,
          widget.phoneNumber,
          widget.password,
        );
        // Navigate to the home page after successful OTP verification
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorSnackBar('OTP is incorrect.');
      }
    } else {
      _showErrorSnackBar('Please enter the OTP.');
    }
  }

  // Method to add user to database
  Future<void> addUserToDatabase(String firstName, String lastName, String phoneNumber, String password) async {
    final url = Uri.parse('https://3f89-82-167-111-148.ngrok-free.app/adduser');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'password': password
      }),
    );

    if (response.statusCode == 200) {
      print('User added successfully');
    } else {
      _showErrorSnackBar('Failed to add user to the database.');
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

  // Method to resend OTP if 3 minutes have passed
  void resendOTP() {
    if (canResend) {
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