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

  // Method to show an alert dialog with customizable text and right-aligned content
  void showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Directionality(
            textDirection: TextDirection.rtl, // Align the title to the right
            child: Text(title),
          ),
          content: Directionality(
            textDirection: TextDirection.rtl, // Align the message to the right
            child: Text(message),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('موافق'),  // Customize the button text (OK in Arabic)
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFF3D3D3D), // Button background color (#3D3D3D)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100), // Set button radius to 100px
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
            ),
          ],
        );
      },
    );
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
      showAlertDialog('معلومات مفقودة', 'الرجاء ملء جميع الحقول المطلوبة.');
      return;
    }

    // Check if passwords match
    if (password != confirmPassword) {
      showAlertDialog('  رمز المرور', 'رمز المرور المدخل غير متطابق.');
      return;
    }

    // Proceed with phone number verification
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
              Image.asset('assets/images/logo.png', width: 90, height: 82),
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
                style: TextStyle(color: Colors.white), // Ensure white text in input field
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
                style: TextStyle(color: Colors.white), // Ensure white text in input field
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
                style: TextStyle(color: Colors.white), // Ensure white text in input field
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
                style: TextStyle(color: Colors.white), // Ensure white text in input field
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
                style: TextStyle(color: Colors.white), // Ensure white text in input field
                obscureText: true,
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 20),
              // Password Requirements
              Container(
                width: 199,
                height: 86,
                child: Text(
                  'الرجاء اختيار رمز مرور يحقق الشروط التالية:\n'
                  'أن يتكون من 8 خانات على الأقل.\n'
                  'أن يحتوي على رقم.\n'
                  'أن يحتوي على حرف صغير.\n'
                  'أن يحتوي على حرف كبير.\n'
                  'أن يحتوي على رمز خاص.',
                  style: TextStyle(
                    fontFamily: 'GE SS Two',
                    fontWeight: FontWeight.w300,
                    fontSize: 9,
                    height: 1.21, // Line height adjusted
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                ),
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
              SizedBox(height: 5), // Reduced the space to 5px
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
