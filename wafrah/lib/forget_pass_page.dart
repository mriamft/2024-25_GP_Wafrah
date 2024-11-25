import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wafrah/OTP_page.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgetPassPage extends StatefulWidget {
  const ForgetPassPage({super.key});

  @override
  _ForgetPassPageState createState() => _ForgetPassPageState();
}

class _ForgetPassPageState extends State<ForgetPassPage> {
  final TextEditingController phoneNumberController = TextEditingController();

  bool showErrorNotification = false;
  String errorMessage = '';
  Color notificationColor =
      const Color(0xFFC62C2C); // Default error notification color

  Color _arrowColor = Colors.white; // Default color for the arrow
  Color _buttonColor = Colors.white; // Default color for the button

  // Show notification method
  void showNotification(String message,
      {Color color = const Color(0xFFC62C2C)}) {
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

  // Validate phone number format
  bool validatePhoneNumber(String phoneNumber) {
    final regex = RegExp(r'^\+966[0-9]{9}$');
    return regex.hasMatch(phoneNumber);
  }

  // Check if phone number exists in the database
  Future<bool> phoneNumberExists(String phoneNumber) async {
    final url =
        Uri.parse('https://459b-94-98-211-77.ngrok-free.app/checkPhoneNumber');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({'phoneNumber': phoneNumber}),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['exists'];
    } else {
      showNotification('حدث خطأ ما\nفشل في التحقق من رقم الجوال');
      return false;
    }
  }

  // Handle next button press
  void handleNext() async {
    String phoneNumber = phoneNumberController.text.trim();
    if (validatePhoneNumber(phoneNumber)) {
      bool exists = await phoneNumberExists(phoneNumber);
      if (exists) {
        // Send OTP only if the phone number exists
        final url =
            Uri.parse('https://459b-94-98-211-77.ngrok-free.app/send-otp');
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({'phoneNumber': phoneNumber}),
        );

        if (response.statusCode == 200) {
          // Navigate to OTP page with isForget set to true
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPPage(
                phoneNumber: phoneNumber,
                firstName: '',
                lastName: '',
                password: '',
                isSignUp: false,
                isForget: true,
              ),
            ),
          ).then((_) {
            // Show success notification after returning from OTP page
            showNotification('تم تحديث كلمة المرور بنجاح',
                color: const Color(0xFF07746A)); // Grey color
          });
        } else {
          showNotification('فشل في إرسال رمز التحقق');
        }
      } else {
        // Show notification if the phone number is not registered
        showNotification('رقم الجوال غير مسجل في النظام');
      }
    } else {
      showNotification('حدث خطأ ما\nصيغة رقم الجوال غير صحيحة');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A996F), Color(0xFF09462F)],
          ),
        ),
        child: Stack(
          children: [
            // Back Arrow
            Positioned(
              top: 60,
              right: 15,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                onTapDown: (_) {
                  setState(() {
                    _arrowColor = Colors.grey;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _arrowColor = Colors.white;
                  });
                },
                onTapCancel: () {
                  setState(() {
                    _arrowColor = Colors.white;
                  });
                },
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: _arrowColor,
                  size: 28,
                ),
              ),
            ),

            // Logo Image
            Positioned(
              left: 118,
              top: 102,
              child: Image.asset(
                'assets/images/logo.png',
                width: 129,
                height: 116,
              ),
            ),

            // Title
            const Positioned(
              top: 263,
              left: 75,
              child: Text(
                'تغيير كلمة المرور',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'GE-SS-Two-Bold',
                ),
              ),
            ),

            // Phone Number Input Field
            Positioned(
              left: 24,
              right: 24,
              top: 370,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: phoneNumberController,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-() ]')),
                    ],
                    decoration: const InputDecoration(
                      hintText: '(+966555555555) رقم الجوال',
                      hintStyle: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 313,
                    height: 2.95,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF60B092), Colors.white],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Next Button
            Positioned(
              left: (MediaQuery.of(context).size.width - 308) / 2,
              top: 550,
              child: GestureDetector(
                onTap: handleNext,
                onTapDown: (_) {
                  setState(() {
                    _buttonColor = const Color(0xFFB0B0B0);
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _buttonColor = Colors.white;
                  });
                },
                onTapCancel: () {
                  setState(() {
                    _buttonColor = Colors.white;
                  });
                },
                child: Container(
                  width: 308,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _buttonColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'التالي',
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

            // Notification
            if (showErrorNotification)
              Positioned(
                top: 23,
                left: 4,
                child: Container(
                  width: 353,
                  height: 57,
                  decoration: BoxDecoration(
                    color: notificationColor,
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
}
