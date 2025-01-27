import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wafrah/home_page.dart';
import 'package:wafrah/pass_confirmation_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wafrah/storage_service.dart';
 
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
  final TextEditingController otpController1 = TextEditingController();
  final TextEditingController otpController2 = TextEditingController();
  final TextEditingController otpController3 = TextEditingController();
  final TextEditingController otpController4 = TextEditingController();
  final TextEditingController otpController5 = TextEditingController();
  final TextEditingController otpController6 = TextEditingController();
 
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
 
  bool showErrorNotification = false;
  String errorMessage = '';
  Color notificationColor = Colors.red;
  Timer? _timer; // Nullable Timer instance
  Timer? _notificationTimer; // Timer for showNotification timeout
 
  bool canResend = false;
  int resendTimeLeft = 120; // 2 minutes in seconds
 
  @override
  void initState() {
    super.initState();
    startResendOTPCountdown();
  }
 
  @override
  void dispose() {
    _timer?.cancel(); // Cancel the resend timer
    _notificationTimer?.cancel(); // Cancel the notification timer if active
 
    // Dispose text controllers
    otpController1.dispose();
    otpController2.dispose();
    otpController3.dispose();
    otpController4.dispose();
    otpController5.dispose();
    otpController6.dispose();
 
    super.dispose();
  }
 
  void startResendOTPCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (resendTimeLeft > 0) {
            resendTimeLeft--;
          } else {
            canResend = true;
            _timer?.cancel();
          }
        });
      } else {
        _timer?.cancel();
      }
    });
  }
 
  String getOTP() {
    return otpController1.text +
        otpController2.text +
        otpController3.text +
        otpController4.text +
        otpController5.text +
        otpController6.text;
  }
 
  void showNotification(String message, {Color color = Colors.red}) {
    if (!mounted) return; // Ensure widget is still in the widget tree
 
    setState(() {
      errorMessage = message;
      notificationColor = color;
      showErrorNotification = true;
    });
 
    // Cancel any previous notification timer
    _notificationTimer?.cancel();
    _notificationTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          showErrorNotification = false;
        });
      }
    });
  }
 
  Future<void> verifyOTP() async {
    String otp = getOTP();
    if (otp.isEmpty || otp.length != 6) {
      showNotification('يرجى إدخال رمز التحقق المؤلف من 6 أرقام.');
      return;
    }
 
    final url =
        Uri.parse('https://c2f7-82-167-113-9.ngrok-free.app/verify-otp');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'phoneNumber': widget.phoneNumber,
        'otp': otp,
      }),
    );
 
    if (response.statusCode == 200) {
      showNotification('نجحت العملية\nتم التحقق بنجاح',
          color: const Color(0xFF0FBE7C));

      Timer(const Duration(seconds: 2), () async {
        if (widget.isForget) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PassConfirmationPage(
                phoneNumber: widget.phoneNumber,
              ),
            ),
          );
        } else if (widget.isSignUp) {
          // Add to the database 
          addUserToDatabase();
        } else {
          // Redirect to HomePage with accounts for login
          await _redirectToHomePage();
        }
      });
    } else {
      showNotification(
          'حدث خطأ ما\nرمز التحقق غير صحيح. يرجى المحاولة مرة أخرى.');
    }
  }
 
Future<void> addUserToDatabase() async {
  final url = Uri.parse('https://c2f7-82-167-113-9.ngrok-free.app/adduser');
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode({
      'userName': '${widget.firstName} ${widget.lastName}',
      'phoneNumber': widget.phoneNumber,
      'password': widget.password,
    }),
  );
 
     if (response.statusCode == 200) {
      showNotification("نجحت العملية\nتم التسجيل بنجاح",
          color: const Color(0xFF0FBE7C));
 
    // Wait for 2 seconds before proceeding to load accounts and redirect
    Timer(const Duration(seconds: 2), () async {
      List<Map<String, dynamic>> accounts = [];
 
      try {
        // First, try to load accounts data from the server
        final accountsUrl = Uri.parse('https://c2f7-82-167-113-9.ngrok-free.app/accounts');
 
        final accountsResponse = await http.get(
          accountsUrl,
          headers: {"Content-Type": "application/json"},
        );
 
        if (accountsResponse.statusCode == 200) {
          // Successfully fetched accounts data from the server
          accounts = List<Map<String, dynamic>>.from(jsonDecode(accountsResponse.body));
          print('Accounts loaded from server after adding user: $accounts');
        } else {
          // Failed to fetch from server, load locally
          print('Failed to fetch accounts from server, loading from local storage.');
          accounts = await StorageService().loadAccountDataLocally(widget.phoneNumber);
        }
      } catch (e) {
        // Handle any errors that occur during the server request
        print('Error retrieving accounts from server: $e');
        // Fall back to local storage in case of errors
        try {
          accounts = await StorageService().loadAccountDataLocally(widget.phoneNumber);
          print('Accounts loaded from local storage after adding user: $accounts');
        } catch (e) {
          print('Error loading accounts after adding user: $e');
        }
      }
 
      // Navigate to HomePage with the retrieved account data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userName: '${widget.firstName} ${widget.lastName}',
            phoneNumber: widget.phoneNumber,
            accounts: accounts,
          ),
       ),
      );
    });
  } else {
    showNotification('فشل في إضافة المستخدم. يرجى المحاولة مرة أخرى.');
  }
}
 
Future<void> _redirectToHomePage() async {
      List<Map<String, dynamic>> accounts = [];
 
      try {
        // First, try to load accounts data from the server
        final accountsUrl = Uri.parse('https://c2f7-82-167-113-9.ngrok-free.app/accounts');
 
        final accountsResponse = await http.get(
          accountsUrl,
          headers: {"Content-Type": "application/json"},
        );
 
        if (accountsResponse.statusCode == 200) {
try {
        // First, try to load accounts data from the server
        final accountsUrl = Uri.parse('https://c2f7-82-167-113-9.ngrok-free.app/accounts');
 
        final accountsResponse = await http.get(
          accountsUrl,
          headers: {"Content-Type": "application/json"},
        );
 
        if (accountsResponse.statusCode == 200) {
          // Successfully fetched accounts data from the server
          accounts = List<Map<String, dynamic>>.from(jsonDecode(accountsResponse.body));
          print('Accounts loaded from server after adding user: $accounts');
        } else {
          // Failed to fetch from server, load locally
          print('Failed to fetch accounts from server, loading from local storage.');
        }
      } catch (e) {
        // Handle any errors that occur during the server request
        print('Error retrieving accounts from server: $e');
 
      }
        }
      } catch (e) {
        // Handle any errors that occur during the server request
        print('Error retrieving accounts from server: $e');
      }
 
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          userName: '${widget.firstName} ${widget.lastName}',
          phoneNumber: widget.phoneNumber,
          accounts: accounts,
        ),
      ),
    );
  }
 
  Future<void> resendOTP() async {
    if (canResend) {
      final url =
          Uri.parse('https://c2f7-82-167-113-9.ngrok-free.app/send-otp');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({'phoneNumber': widget.phoneNumber}),
      );
 
      if (response.statusCode == 200) {
        setState(() {
          resendTimeLeft = 180;
          canResend = false;
        });
        startResendOTPCountdown();
      } else {
        showNotification(
            'فشل في إعادة إرسال رمز التحقق. يرجى المحاولة مرة أخرى.');
      }
    }
  }
 
  String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length > 4) {
      return '0${phoneNumber.substring(4)}';
    }
    return phoneNumber;
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
            Positioned(
              left: 140,
              top: 130,
              child: Image.asset(
                'assets/images/logo.png',
                width: 90,
                height: 82,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 230),
                  const Text(
                    'كلمة المرور لمرة واحدة',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'GE-SS-Two-Bold',
                      color: Colors.white,
                      height: 1.21,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'يرجى كتابة رمز التحقق كلمة المرور لمرة واحدة المرسلة إلى رقم الهاتف ${formatPhoneNumber(widget.phoneNumber)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'GE-SS-Two-Light',
                      color: Colors.white,
                      height: 1.24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
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
                    child: const Text(
                      'التحقق من الرمز',
                      style: TextStyle(
                        fontFamily: 'GE-SS-Two-Light',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: canResend ? resendOTP : null,
                    child: Text(
                      canResend
                          ? 'إعادة إرسال رمز التحقق؟'
                          : 'إعادة الإرسال بعد $resendTimeLeft ثانية',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'GE-SS-Two-Light',
                        fontWeight: FontWeight.bold,
                        color: canResend ? Colors.white : Colors.grey,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            if (showErrorNotification)
  Positioned(
    top: 23,
    left: 19,
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
                    Expanded(
                      // Wrap the Text widget with Expanded
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'GE-SS-Two-Light',
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow
                              .ellipsis, // Add this line for overflow handling
                        ),
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