import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otppage.dart';  // Import your OTPPage file

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

  // Method to handle phone number verification
  void signUp() async {
    String phoneNumber = phoneNumberController.text.trim(); // Get the phone number

    if (phoneNumber.isNotEmpty && passwordController.text == confirmPasswordController.text) {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          // Navigate to OTPPage when the code is sent
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPPage(
                verificationId: verificationId,
                phoneNumber: phoneNumberController.text, // Pass phone number to OTPPage
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } else {
      // Handle error if passwords do not match or phone number is empty
      print('Passwords do not match or phone number is empty');
    }
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 80),
              Image.asset('assets/logo.png', width: 90, height: 82),
              SizedBox(height: 40),
              // First Name Input
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الأول',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 10),
              // Last Name Input
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الأخير',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 10),
              // Phone Number Input
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'رقم الجوال',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 10),
              // Password Input
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'رمز المرور',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                obscureText: true,
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 10),
              // Confirm Password Input
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'تأكيد رمز المرور',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                obscureText: true,
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 20),
              // Sign Up Button
              ElevatedButton(
                onPressed: signUp,
                child: Text('تسجيل الدخول'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, 
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Navigate to Login
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text('لديك حساب؟ سجل الدخول'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
