import 'package:flutter/material.dart';

class BanksPage extends StatelessWidget {
  final String userName; // Pass userName from previous pages
  final String phoneNumber;
  
  BanksPage({required this.userName, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('البنوك'),
      ),
      body: Center(
        child: Text(
          'مرحبًا $userName, هذه صفحة البنوك', // Displaying the username
          style: TextStyle(fontSize: 24, fontFamily: 'GE-SS-Two-Bold'),
        ),
      ),
    );
  }
}
