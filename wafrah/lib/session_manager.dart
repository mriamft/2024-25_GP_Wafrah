import 'dart:async';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:wafrah/main.dart'; 

class SessionManager {
  static Timer? _inactivityTimer;
  static Timer? _confirmationTimer;
  static int _countdown = 60; 
  static late StateSetter _dialogStateSetter; 

  static void startTracking(BuildContext context) {
    _resetTimer(context);
  }

  static void _resetTimer(BuildContext context) {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(minutes: 15), () {
      _showConfirmationDialog(context);
    });
  }

  static void userActivityDetected(BuildContext context) {
    _resetTimer(context);
  }

  static void _showConfirmationDialog(BuildContext context) {
    _countdown = 60; 
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        _startConfirmationTimer(context);

        return StatefulBuilder(
          builder: (context, setState) {
            _dialogStateSetter = setState;

            return AlertDialog(
              title: const Text(
                'تأكيد النشاط',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'GE-SS-Two-Bold',
                  fontSize: 20,
                  color: Color(0xFF3D3D3D),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end, 
                children: [
                  const Text(
                    'لم يتم استخدام البرنامج لمدة ١٠ دقائق هل ترغب بالاستمرار؟',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'GE-SS-Two-Light',
                      fontSize: 16,
                      color: Color(0xFF3D3D3D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'سيتم تسجيل الخروج خلال: $_countdown ثانية',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'GE-SS-Two-Bold',
                      fontSize: 14,
                      color: Color(0xFF8D8D8D),
                    ),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () {
                    _confirmationTimer?.cancel();
                  Navigator.of(context).pop();
                  startTracking(navigatorKey.currentState!.overlay!.context);
                  },
                  child: const Text(
                    'نعم، أرغب بالاستمرار',
                    style: TextStyle(
                      fontFamily: 'GE-SS-Two-Light',
                      fontSize: 16,
                      color: Color(0xFF2C8C68), 
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void _startConfirmationTimer(BuildContext context) {
    _confirmationTimer?.cancel();
    _confirmationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        _countdown--;
        _dialogStateSetter(() {});
      } else {
        _logout();
      }
    });
  }

  static void _logout() {
    _inactivityTimer?.cancel();
    _confirmationTimer?.cancel();

    navigatorKey.currentState?.pushNamed('/');

    Flushbar(
      message: 'لقد تم تسجيل خروجك بنجاح',
      messageText: const Text(
        'لقد تم تسجيل خروجك بنجاح',
        textAlign: TextAlign.right,
        style: TextStyle(
          fontFamily: 'GE-SS-Two-Light',
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF0FBE7C),
      duration: const Duration(seconds: 5),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(8.0),
    ).show(navigatorKey.currentState!.overlay!.context);
  }

  static void dispose() {
    _inactivityTimer?.cancel();
    _confirmationTimer?.cancel();
  }

  static void resetTimer() {
  if (navigatorKey.currentState != null) {
    _resetTimer(navigatorKey.currentState!.overlay!.context);
  }
}

}
