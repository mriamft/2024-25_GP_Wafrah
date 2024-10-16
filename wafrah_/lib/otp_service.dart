import 'package:firebase_auth/firebase_auth.dart';

class OTPService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = '';

  // Send OTP to the phone number
  Future<void> sendOTP(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-sign in when OTP is auto-retrieved
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception('Failed to send OTP: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        // Save the verificationId to verify the OTP later
        this.verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId = verificationId;
      },
    );
  }

  // Verify the OTP
  Future<void> verifyOTP(String otp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    // Try signing in with the credential (OTP verification)
    await _auth.signInWithCredential(credential);
  }
}