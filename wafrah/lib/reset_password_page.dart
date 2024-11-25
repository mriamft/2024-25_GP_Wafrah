import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'settings_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;

  const ResetPasswordPage(
      {super.key, required this.userName, required this.phoneNumber});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final Color _arrowColor = const Color(0xFF3D3D3D);
  bool _showNotification = false;
  String _notificationMessage = '';
  Color _notificationColor = Colors.red;

  bool _isCurrentPasswordVisible = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // State variables for password criteria
  bool isLengthValid = false;
  bool isNumberValid = false;
  bool isLowercaseValid = false;
  bool isUppercaseValid = false;
  bool isSymbolValid = false;

  // Show notification method
  void showNotification(String message,
      {Color color = Colors.red, bool navigateAfter = false}) {
    setState(() {
      _notificationMessage = message;
      _notificationColor = color;
      _showNotification = true;
    });

    Timer(const Duration(seconds: 5), () {
      setState(() {
        _showNotification = false;
      });
      if (navigateAfter) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsPage(
              userName: widget.userName,
              phoneNumber: widget.phoneNumber,
            ),
          ),
        );
      }
    });
  }

  // Validate password criteria
  void validatePasswordInput(String password) {
    setState(() {
      isLengthValid = password.length >= 8;
      isNumberValid = password.contains(RegExp(r'\d'));
      isLowercaseValid = password.contains(RegExp(r'[a-z]'));
      isUppercaseValid = password.contains(RegExp(r'[A-Z]'));
      isSymbolValid = password.contains(RegExp(r'[!@#\$&*~]'));
    });
  }

  // Check if passwords meet criteria and match
  bool validatePasswords() {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (!isLengthValid ||
        !isNumberValid ||
        !isLowercaseValid ||
        !isUppercaseValid ||
        !isSymbolValid) {
      showNotification(
          'رمز المرور لا يحقق الشروط: 8 خانات على الأقل، حرف صغير، حرف كبير، رقم ورمز خاص');
      return false;
    }

    if (newPassword != confirmPassword) {
      showNotification("كلمات المرور الجديدة غير متطابقة");
      return false;
    }

    return true;
  }

  // Reset password method
  Future<void> _resetPassword() async {
    final String currentPassword = _currentPasswordController.text;
    final String newPassword = _newPasswordController.text;

    try {
      final response = await http.post(
        Uri.parse('https://459b-94-98-211-77.ngrok-free.app/reset-password'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'phoneNumber': widget.phoneNumber,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        showNotification(
          'تم تعديل كلمة المرور بنجاح',
          color: const Color(0xff07746a2a996f),
          navigateAfter: true,
        );
      } else {
        showNotification("فشل تعديل كلمة المرور");
      }
    } catch (error) {
      showNotification("خطأ في الاتصال بالخادم");
    }
  }

  void _showResetConfirmationDialog() {
    if (validatePasswords()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'تأكيد إعادة تعيين كلمة المرور',
            style: TextStyle(
                fontFamily: 'GE-SS-Two-Bold', color: Color(0xFF3D3D3D)),
          ),
          content: const Text(
            'هل أنت متأكد أنك تريد إعادة تعيين كلمة المرور؟',
            style: TextStyle(
                fontFamily: 'GE-SS-Two-Light', color: Color(0xFF3D3D3D)),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء',
                  style: TextStyle(
                      fontFamily: 'GE-SS-Two-Light', color: Color(0xFF838383))),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _resetPassword();
              },
              child: const Text('تأكيد',
                  style: TextStyle(
                      fontFamily: 'GE-SS-Two-Light', color: Color(0xFF2C8C68))),
            ),
          ],
        ),
      );
    }
  }

  // Helper function for criteria text
  Widget _buildCriteriaText(String text, bool isValid) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontFamily: 'GE-SS-Two-Light',
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: isValid ? Colors.grey : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          Positioned(
            top: 60,
            right: 15,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child:
                  Icon(Icons.arrow_forward_ios, color: _arrowColor, size: 28),
            ),
          ),
          const Positioned(
            top: 58,
            left: 110,
            child: Text(
              'إعادة تعيين رمز المرور',
              style: TextStyle(
                  color: Color(0xFF3D3D3D),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'GE-SS-Two-Bold'),
            ),
          ),
          Positioned(
            top: 135,
            left: 24,
            child: SizedBox(
              width: 325,
              height: 50,
              child: TextField(
                controller: _currentPasswordController,
                textAlign: TextAlign.right,
                obscureText: !_isCurrentPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'رمز المرور الحالي',
                  hintStyle: const TextStyle(
                      color: Color(0xFF888888), fontFamily: 'GE-SS-Two-Light'),
                  prefixIcon: IconButton(
                    icon: Icon(
                      _isCurrentPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF3D3D3D),
                    ),
                    onPressed: () {
                      setState(() {
                        _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 205,
            left: 24,
            child: SizedBox(
              width: 325,
              height: 50,
              child: TextField(
                controller: _newPasswordController,
                textAlign: TextAlign.right,
                obscureText: !_isPasswordVisible,
                onChanged: validatePasswordInput,
                decoration: InputDecoration(
                  hintText: 'رمز المرور الجديد',
                  hintStyle: const TextStyle(
                      color: Color(0xFF888888), fontFamily: 'GE-SS-Two-Light'),
                  prefixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF3D3D3D),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 275,
            left: 24,
            child: SizedBox(
              width: 325,
              height: 50,
              child: TextField(
                controller: _confirmPasswordController,
                textAlign: TextAlign.right,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'تأكيد رمز المرور الجديد',
                  hintStyle: const TextStyle(
                      color: Color(0xFF888888), fontFamily: 'GE-SS-Two-Light'),
                  prefixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF3D3D3D),
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 330,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildCriteriaText(
                    'أن يتكون من 8 خانات على الأقل.', isLengthValid),
                _buildCriteriaText('أن يحتوي على رقم.', isNumberValid),
                _buildCriteriaText('أن يحتوي على حرف صغير.', isLowercaseValid),
                _buildCriteriaText('أن يحتوي على حرف كبير.', isUppercaseValid),
                _buildCriteriaText('أن يحتوي على رمز خاص.', isSymbolValid),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: (MediaQuery.of(context).size.width - 220) / 2,
            child: SizedBox(
              width: 220,
              height: 38,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D3D3D),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  shadowColor: Colors.black,
                  elevation: 5,
                ),
                onPressed: _showResetConfirmationDialog,
                child: const Text('تعديل',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'GE-SS-Two-Light')),
              ),
            ),
          ),
          if (_showNotification)
            Positioned(
              top: 23,
              left: 4,
              child: Container(
                width: 353,
                height: 57,
                decoration: BoxDecoration(
                  color: _notificationColor,
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
                        _notificationMessage,
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
    );
  }
}
