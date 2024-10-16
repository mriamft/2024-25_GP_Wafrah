import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String firstName;
  final String userID;

  ProfilePage({required this.firstName, required this.userID});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Color _arrowColor = Color(0xFF3D3D3D);

  void _onArrowTap() {
    setState(() {
      _arrowColor = Colors.grey;
    });
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _arrowColor = Color(0xFF3D3D3D);
      });
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Back Arrow
          Positioned(
            top: 60,
            right: 15,
            child: GestureDetector(
              onTap: _onArrowTap,
              child: Icon(
                Icons.arrow_forward_ios,
                color: _arrowColor,
                size: 28,
              ),
            ),
          ),

          // Title
          Positioned(
            top: 58,
            left: 145,
            child: Text(
              'الحساب الشخصي',
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
              'هذه الخاصية لم\n تتوفر حتى الآن',
              style: TextStyle(
                fontFamily: 'GE-SS-Two-Bold',
                fontSize: 20,
                color: Color(0xFF838383),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
