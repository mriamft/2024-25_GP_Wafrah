import 'package:flutter/material.dart';
import 'package:wafrah/signup_page.dart'; 

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  int currentIndex = 0; 
  final PageController _pageController =
      PageController(); 

  final List<String> images = [
    'assets/images/first_info.png', 
    'assets/images/second_info.png',
    'assets/images/third_info.png', 
  ];

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index; 
    });
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: images.length,
            reverse: true, 
            itemBuilder: (context, index) {
              return SizedBox(
                width: 300,
                height: 500,
                child: Transform.translate(
                  offset:
                      const Offset(0, -80), 
                  child: Image.asset(
                    images[index], 
                    fit: BoxFit.scaleDown, 
                  ),
                ),
              );
            },
          ),

          if (currentIndex == 0) 
            Positioned(
              top: 40,
              right: 15,
              child: GestureDetector(
                onTap: _goBack, 
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white, 
                  size: 28,
                ),
              ),
            ),

          if (currentIndex == images.length - 1)
            Positioned(
              bottom: 15,
              left: (MediaQuery.of(context).size.width - 80) / 2,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2C8C68), Color(0xFF8FD9BD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}