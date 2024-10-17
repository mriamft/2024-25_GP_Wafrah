import 'package:flutter/material.dart';

class BanksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('البنوك'),
      ),
      body: Center(
        child: Text(
          'البنوك الصفحة',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}