import 'package:flutter/material.dart';

class secondpage extends StatelessWidget {
  const secondpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
      ),
      body: Center(
        child: const Text(
          'This is the second page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}