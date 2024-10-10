import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otppage.dart';  // Import your OTPPage file
import 'dart:async';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showErrorNotification = false; // To control the visibility of the notification
  String errorMessage = ''; // To display dynamic error messages

  // Method to show a notification box at the top of the screen
  void showNotification(String message) {
    setState(() {
      errorMessage = message;
      showErrorNotification = true;
    });

    // Automatically hide the notification after 10 seconds
    Timer(Duration(seconds: 10), () {
      setState(() {
        showErrorNotification = false;
      });
    });
  }

  // Method to handle phone number verification
  void signUp() async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String phoneNumber = phoneNumberController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    // Check if any field is empty
    if (firstName.isEmpty || lastName.isEmpty || phoneNumber.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showNotification('حدث خطأ ما\nلم تقم بملء جميع الحقول');
      return;
    }

    // Check if passwords match
    if (password != confirmPassword) {
      showNotification('حدث خطأ ما\nرمز المرور غير متطابق');
      return;
    }

    // Proceed with phone number verification logic
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPPage(
              verificationId: verificationId,
              phoneNumber: phoneNumberController.text,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

                // Logo Image
                Positioned(
                  left: 140,
                  top: 130,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 90,
                    height: 82,
                  ),
                ),

                // First Name Input
                _buildInputField(
                  top: 235,
                  hintText: 'الاسم الأول',
                  controller: firstNameController,
                ),

                // Last Name Input
                _buildInputField(
                  top: 300,
                  hintText: 'الاسم الأخير',
                  controller: lastNameController,
                ),

                // Phone Number Input
                _buildInputField(
                  top: 365,
                  hintText: 'رقم الجوال',
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
                ),

                // Password Input
                _buildInputField(
                  top: 430,
                  hintText: 'رمز المرور',
                  controller: passwordController,
                  obscureText: true,
                ),

                // Confirm Password Input
                _buildInputField(
                  top: 495,
                  hintText: 'تأكيد رمز المرور',
                  controller: confirmPasswordController,
                  obscureText: true,
                ),

                // Password Requirements Text
                Positioned(
                  left: 24,
                  right: 10,
                  top: 570, // Positioned below the inputs
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'الرجاء اختيار رمز مرور يحقق الشروط التالية:\n'
                      'أن يتكون من 8 خانات على الأقل.\n'
                      'أن يحتوي على رقم.\n'
                      'أن يحتوي على حرف صغير.\n'
                      'أن يحتوي على حرف كبير.\n'
                      'أن يحتوي على رمز خاص.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'GE SS Two',
                        fontSize: 9,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        height: 1.21,
                      ),
                    ),
                  ),
                ),

                // Sign Up Button
                Positioned(
                  left: (MediaQuery.of(context).size.width - 308) / 2,
                  top: 715,
                  child: GestureDetector(
                    onTap: signUp,
                    child: Container(
                      width: 308,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
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

                // Sign Up Text
                Positioned(
                  bottom: 30,
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
                                builder: (context) =>
                                    SignUpPage()), // Navigate to sign-up page
                          );
                        },
                        child: Text(
                          'سجل الآن',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'GE-SS-Two-Light',
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
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

          // Error Notification Box
          if (showErrorNotification)
            Positioned(
              top: 23, // Adjust the position as needed
              left: 20,
              child: Container(
                width: 353,
                height: 57,
                decoration: BoxDecoration(
                  color: Color(0xFFC62C2C), // Red background
                  borderRadius: BorderRadius.all(Radius.circular(10)), // Apply rounded corners
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Text(
                        errorMessage,
                        style: TextStyle(
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

  // Reusable Input Field Widget
  Widget _buildInputField({
    required double top,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
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
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontFamily: 'GE-SS-Two-Light',
                fontSize: 14,
                color: Colors.white,
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(color: Colors.white),
            cursorColor: Colors.white,
          ),
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
    );
  }
}
