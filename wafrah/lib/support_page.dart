import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  final String phoneNumber;
  final String userName;

  const SupportPage(
      {super.key, required this.userName, required this.phoneNumber});

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  Color _arrowColor = const Color(0xFF3D3D3D); // Default arrow color

  void _onArrowTap() {
    setState(() {
      _arrowColor = Colors.grey; // Change color on press
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _arrowColor =
            const Color(0xFF3D3D3D); // Reset color after a short delay
      });
      Navigator.pop(context); // Navigate back to settings page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Set background color
      body: Stack(
        children: [
          // Back Arrow
          Positioned(
            top: 60,
            right: 15,
            child: GestureDetector(
              onTap: _onArrowTap, // Change this to the new method
              child: Icon(
                Icons.arrow_forward_ios,
                color: _arrowColor, // Use the dynamic color
                size: 28,
              ),
            ),
          ),

          // Title
          const Positioned(
            top: 58,
            left: 142,
            child: Text(
              'التواصل مع الدعم', // Updated to "Support"
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),

          // Centered Text
          const Center(
            child: Text(
              'هذه الخاصية لم\n تتوفر حتى الآن', // Displayed text in the center
              style: TextStyle(
                fontFamily: 'GE-SS-Two-Bold',
                fontSize: 20,
                color: Color(0xFF838383),
              ),
              textAlign: TextAlign.center, // Center the text
            ),
          ),
        ],
      ),
    );
  }
}
