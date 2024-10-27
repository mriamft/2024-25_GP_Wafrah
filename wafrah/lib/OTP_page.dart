import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wafrah/home_page.dart';
import 'package:wafrah/pass_confirmation_page.dart';

class OTPPage extends StatefulWidget {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String password;
  final bool isSignUp;
  final bool isForget;

  const OTPPage({
    super.key,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.isSignUp,
    required this.isForget,
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

  bool showErrorNotification = false;
  String errorMessage = '';
  Color notificationColor = Colors.red; // Default notification color

  bool canResend = false;
  late Timer _timer;
  int resendTimeLeft = 120; // 2 minutes in seconds

  @override
  void initState() {
    super.initState();
    startResendOTPCountdown(); // Start countdown on page load
  }

  void startResendOTPCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  // Show notification method
  void showNotification(String message, {Color color = Colors.red}) {
    setState(() {
      errorMessage = message;
      notificationColor = color; // Set notification color dynamically
      showErrorNotification = true;
    });

    Timer(const Duration(seconds: 5), () {
      setState(() {
        showErrorNotification = false;
      });
    });
  }

  // Method to verify OTP with the backend
  Future<void> verifyOTP() async {
    String otp = getOTP();
    if (otp.isEmpty || otp.length != 6) {
      showNotification('يرجى إدخال رمز التحقق المؤلف من 6 أرقام.');
      return;
    }

    final url =
        Uri.parse('https://0813-78-95-248-162.ngrok-free.app/verify-otp');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'phoneNumber': widget.phoneNumber,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      showNotification('تم التحقق بنجاح', color: Colors.grey);

      if (widget.isForget) {
        // Navigate to PassConfirmationPage for password reset
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PassConfirmationPage(
              phoneNumber: widget.phoneNumber,
            ),
          ),
        );
      } else if (widget.isSignUp) {
        addUserToDatabase(); // Proceed with sign-up flow
      } else {
        // Proceed to Home Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              userName: '${widget.firstName} ${widget.lastName}',
              phoneNumber: widget.phoneNumber,
            ),
          ),
        );
      }
    } else {
      showNotification('رمز التحقق غير صحيح. يرجى المحاولة مرة أخرى.');
    }
  }

  // Add user to the database only if it's a sign-up process
  Future<void> addUserToDatabase() async {
    final url = Uri.parse('https://0813-78-95-248-162.ngrok-free.app/adduser');
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
      showNotification("تم التسجيل بنجاح", color: Colors.grey);
      // Navigate to HomePage after the user is added successfully
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userName: '${widget.firstName} ${widget.lastName}',
            phoneNumber: widget.phoneNumber,
          ),
        ),
      );
    } else {
      showNotification('فشل في إضافة المستخدم. يرجى المحاولة مرة أخرى.');
    }
  }

  // Method to resend OTP if 3 minutes have passed
  Future<void> resendOTP() async {
    if (canResend) {
      final url =
          Uri.parse('https://0813-78-95-248-162.ngrok-free.app/send-otp');
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
        showNotification(
            'فشل في إعادة إرسال رمز التحقق. يرجى المحاولة مرة أخرى.');
      }
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
        decoration: const BoxDecoration(
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
                child: const Icon(
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
                  const SizedBox(height: 230),
                  const Text(
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
                  const SizedBox(height: 10),
                  Text(
                    'يرجى كتابة رمز التحقق كلمة المرور لمرة واحدة المرسلة إلى رقم الهاتف ${widget.phoneNumber}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'GE SS Two',
                      color: Colors.white,
                      height: 1.24,
                    ),
                    textAlign: TextAlign.center, // Center the text
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 40),
                  // Verify OTP Button
                  ElevatedButton(
                    onPressed: verifyOTP,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 5,
                      minimumSize: const Size(308, 52),
                    ),
                    child: const Text('التحقق من الرمز'),
                  ),
                  const SizedBox(height: 20),
                  // Resend OTP text
                  GestureDetector(
                    onTap: canResend ? resendOTP : null,
                    child: Text(
                      canResend
                          ? 'إعادة إرسال رمز التحقق؟'
                          : 'إعادة الإرسال بعد $resendTimeLeft ثانية',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: canResend ? Colors.white : Colors.grey,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            // Notification Message
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
      ),
    );
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
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}
