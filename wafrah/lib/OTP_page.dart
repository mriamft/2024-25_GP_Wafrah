import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wafrah/home_page.dart';

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
  // Use six different controllers for each OTP field
  final TextEditingController otpController1 = TextEditingController();
  final TextEditingController otpController2 = TextEditingController();
  final TextEditingController otpController3 = TextEditingController();
  final TextEditingController otpController4 = TextEditingController();
  final TextEditingController otpController5 = TextEditingController();
  final TextEditingController otpController6 = TextEditingController();

  bool canResend = false;
  late Timer _timer;
  int resendTimeLeft = 120; // 2 minutes in seconds

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

  // Combine the values of all OTP fields
  String getOTP() {
    return otpController1.text +
        otpController2.text +
        otpController3.text +
        otpController4.text +
        otpController5.text +
        otpController6.text;
  }

  // Method to verify OTP with the backend (using Twilio)
  Future<void> verifyOTP() async {
    String otp = getOTP();
    if (otp.isEmpty || otp.length != 6) {
      _showErrorSnackBar('Please enter the 6-digit OTP.');
      return;
    }

    final url = Uri.parse('https://c63a-2001-16a2-dd76-e900-187a-b232-83ee-9150.ngrok-free.app/verify-otp'); // Replace with your backend URL
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'phoneNumber': widget.phoneNumber,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      addUserToDatabase(); // OTP verified, proceed to add user
    } else {
      _showErrorSnackBar('Invalid OTP. Please try again.');
    }
  }

  // Add user to the database after OTP is verified
  Future<void> addUserToDatabase() async {
    final url = Uri.parse('https://c63a-2001-16a2-dd76-e900-187a-b232-83ee-9150.ngrok-free.app/adduser'); // Replace with your backend URL
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'userName': '${widget.firstName} ${widget.lastName}',
        'phoneNumber': widget.phoneNumber,
        'password': widget.password, // Ensure this is hashed in the backend
      }),
    );

  if (response.statusCode == 200) {
    // Navigate to HomePage after the user is added successfully
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          userName: widget.firstName,
          phoneNumber: widget.phoneNumber,

        ),
      ),
    );
  } else {
    _showErrorSnackBar('Failed to add user. Please try again.');
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

  // Resend OTP logic remains the same

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
                      _otpField(otpController1),
                      _otpField(otpController2),
                      _otpField(otpController3),
                      _otpField(otpController4),
                      _otpField(otpController5),
                      _otpField(otpController6),
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
  // OTP Field Widget for the OTP input
// Method to resend OTP if 3 minutes have passed
Future<void> resendOTP() async {
  if (canResend) {
    final url = Uri.parse('https://c63a-2001-16a2-dd76-e900-187a-b232-83ee-9150.ngrok-free.app/send-otp'); // Replace with your backend URL
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({'phoneNumber': widget.phoneNumber}),
    );

    if (response.statusCode == 200) {
      setState(() {
        resendTimeLeft = 180; // Reset the countdown to 3 minutes
        canResend = false;
      });
      startResendOTPCountdown(); // Restart the countdown
    } else {
      _showErrorSnackBar('Failed to resend OTP. Please try again.');
    }
  }
}


  Widget _otpField(TextEditingController controller) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        style: TextStyle(color: Colors.white),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus(); // Move focus to the next field
          }
        },
      ),
    );
  }
}
