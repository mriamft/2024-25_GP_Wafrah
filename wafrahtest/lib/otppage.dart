import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class OTPPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPPage({super.key, required this.verificationId, required this.phoneNumber});

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final TextEditingController otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool canResend = false;
  late Timer _timer;
  int resendTimeLeft = 180; // 3 minutes in seconds

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

  void verifyOTP() async {
    String otp = otpController.text.trim();

    if (otp.isNotEmpty) {
      try {
        // Verify the OTP using the verificationId and OTP entered
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId,
          smsCode: otp,
        );

        // Sign in the user using the credential
        await _auth.signInWithCredential(credential);

        // Navigate to the home page after successful OTP verification
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        print('Error verifying OTP: $e');
        // Optionally, show an error message to the user
      }
    }
  }

  // Method to resend OTP if 3 minutes have passed
  void resendOTP() async {
    if (canResend) {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          print('OTP resent');
          setState(() {
            resendTimeLeft = 180; // Reset the countdown to 3 minutes
            canResend = false;
          });
          startResendOTPCountdown(); // Restart the countdown
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
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
                crossAxisAlignment: CrossAxisAlignment.center, // Center alignment
                children: [
                  const SizedBox(height: 230), // Adjusted to move the text under the splash image
                  // First Text (Styled as per the image you provided)
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
                  // Second Text with phone number (Styled as per the image)
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
                      _otpField(),
                      _otpField(),
                      _otpField(),
                      _otpField(),
                      _otpField(),
                      _otpField(),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Updated Button (Styled same as sign-up page)
                  ElevatedButton(
                    onPressed: verifyOTP,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, 
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 5,
                      minimumSize: const Size(308, 52), // Ensure the button is the same size
                    ),
                    child: Text('التحقق من الرمز'),
                  ),
                  const SizedBox(height: 20),
                  // Resend OTP text
                  GestureDetector(
                    onTap: canResend ? resendOTP : null, // Only allow resend after 3 minutes
                    child: Text(
                      canResend ? 'إعادة إرسال رمز التحقق؟' : 'إعادة الإرسال بعد $resendTimeLeft ثانية',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: canResend ? Colors.white : Colors.grey, // Disable link while waiting
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
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        style: const TextStyle(color: Colors.white), // Set the input text color to white
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus(); // Move focus to the next field
          }
        },
      ),
    );
  }
}
