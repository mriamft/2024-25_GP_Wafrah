import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'settings_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;

  ResetPasswordPage({required this.userName, required this.phoneNumber});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Color _arrowColor = Color(0xFF3D3D3D);
  bool _showErrorNotification = false;
  String _errorMessage = '';

  bool _isCurrentPasswordVisible = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // State variables for password criteria
  bool isLengthValid = false;
  bool isNumberValid = false;
  bool isLowercaseValid = false;
  bool isUppercaseValid = false;
  bool isSymbolValid = false;

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

  // Method to validate password complexity
  bool validatePassword(String password) {
    return isLengthValid && isNumberValid && isLowercaseValid && isUppercaseValid && isSymbolValid;
  }

  // Reset password method
  Future<void> _resetPassword() async {
    final String currentPassword = _currentPasswordController.text;
    final String newPassword = _newPasswordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = "يجب ملء جميع الحقول";
        _showErrorNotification = true;
      });
      return;
    }

    if (!validatePassword(newPassword)) {
      setState(() {
        _errorMessage = 'رمز المرور لا يحقق الشروط: 8 خانات على الأقل، حرف صغير، حرف كبير، رقم ورمز خاص';
        _showErrorNotification = true;
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = "كلمات المرور الجديدة غير متطابقة";
        _showErrorNotification = true;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://3731-82-167-74-251.ngrok-free.app/reset-password'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تعديل كلمة المرور بنجاح',
              style: TextStyle(fontFamily: 'GE-SS-Two-Light', fontSize: 14, color: Colors.white),
            ),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsPage(
              userName: widget.userName,
              phoneNumber: widget.phoneNumber,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = "فشل تعديل كلمة المرور";
          _showErrorNotification = true;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = "خطأ في الاتصال بالخادم";
        _showErrorNotification = true;
      });
    }
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تأكيد إعادة تعيين كلمة المرور',
          style: TextStyle(fontFamily: 'GE-SS-Two-Bold', color: Color(0xFF3D3D3D)),
        ),
        content: Text(
          'هل أنت متأكد أنك تريد إعادة تعيين كلمة المرور؟',
          style: TextStyle(fontFamily: 'GE-SS-Two-Light', color: Color(0xFF3D3D3D)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إلغاء', style: TextStyle(fontFamily: 'GE-SS-Two-Light', color: Color(0xFF838383))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _resetPassword();
            },
            child: Text('تأكيد', style: TextStyle(fontFamily: 'GE-SS-Two-Light', color: Color(0xFF2C8C68))),
          ),
        ],
      ),
    );
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
      backgroundColor: Color(0xFFF9F9F9),
      body: Stack(
        children: [
          Positioned(
            top: 60,
            right: 15,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_forward_ios, color: _arrowColor, size: 28),
            ),
          ),

          Positioned(
            top: 58,
            left: 110,
            child: Text(
              'إعادة تعيين رمز المرور',
              style: TextStyle(color: Color(0xFF3D3D3D), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'GE-SS-Two-Bold'),
            ),
          ),

          // Current Password Input with Eye Icon
          Positioned(
            top: 135,
            left: 24,
            child: Container(
              width: 325,
              height: 50,
              child: TextField(
                controller: _currentPasswordController,
                textAlign: TextAlign.right,
                obscureText: !_isCurrentPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'رمز المرور الحالي',
                  hintStyle: TextStyle(color: Color(0xFF888888), fontFamily: 'GE-SS-Two-Light'),
                  prefixIcon: IconButton(
                    icon: Icon(
                      _isCurrentPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Color(0xFF3D3D3D),
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

          // New Password Input with Eye Icon
          Positioned(
            top: 205,
            left: 24,
            child: Container(
              width: 325,
              height: 50,
              child: TextField(
                controller: _newPasswordController,
                textAlign: TextAlign.right,
                obscureText: !_isPasswordVisible,
                onChanged: validatePasswordInput,
                decoration: InputDecoration(
                  hintText: 'رمز المرور الجديد',
                  hintStyle: TextStyle(color: Color(0xFF888888), fontFamily: 'GE-SS-Two-Light'),
                  prefixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Color(0xFF3D3D3D),
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

          // Confirm New Password Input with Eye Icon
          Positioned(
            top: 275,
            left: 24,
            child: Container(
              width: 325,
              height: 50,
              child: TextField(
                controller: _confirmPasswordController,
                textAlign: TextAlign.right,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'تأكيد رمز المرور الجديد',
                  hintStyle: TextStyle(color: Color(0xFF888888), fontFamily: 'GE-SS-Two-Light'),
                  prefixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Color(0xFF3D3D3D),
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

          // Password Criteria Instructions
          Positioned(
            top: 330,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildCriteriaText('أن يتكون من 8 خانات على الأقل.', isLengthValid),
                _buildCriteriaText('أن يحتوي على رقم.', isNumberValid),
                _buildCriteriaText('أن يحتوي على حرف صغير.', isLowercaseValid),
                _buildCriteriaText('أن يحتوي على حرف كبير.', isUppercaseValid),
                _buildCriteriaText('أن يحتوي على رمز خاص.', isSymbolValid),
              ],
            ),
          ),

          // Submit Button
          Positioned(
            bottom: 40,
            left: (MediaQuery.of(context).size.width - 220) / 2,
            child: SizedBox(
              width: 220,
              height: 38,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3D3D3D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  shadowColor: Colors.black,
                  elevation: 5,
                ),
                onPressed: _showResetConfirmationDialog,
                child: Text('تعديل', style: TextStyle(fontSize: 20, fontFamily: 'GE-SS-Two-Light')),
              ),
            ),
          ),

          // Error/Confirmation Message
          if (_showErrorNotification)
            Positioned(
              bottom: 100,
              left: (MediaQuery.of(context).size.width - 300) / 2,
              child: Text(_errorMessage, style: TextStyle(color: Colors.red, fontSize: 14)),
            ),
        ],
      ),
    );
  }
}
