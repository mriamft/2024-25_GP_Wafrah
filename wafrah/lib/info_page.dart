import 'package:flutter/material.dart';
import 'package:wafrah/signup_page.dart'; // Import your sign-up page

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  int currentIndex = 0; // Track the current dashboard index
  final PageController _pageController =
      PageController(); // Controller for the PageView

  // Images for the dashboards
  final List<String> images = [
    'assets/images/first_info.png', // First dashboard image
    'assets/images/second_info.png', // Second dashboard image
    'assets/images/third_info.png', // Third dashboard image
  ];

  // Change the current dashboard index
  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index; // Update current index
    });
  }

  // Method to navigate back
  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView for swiping between images
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: images.length,
            reverse: true, // Enable navigation from right to left
            itemBuilder: (context, index) {
              return SizedBox(
                width: 300, // Fixed width for the image
                height: 500, // Fixed height for the image
                child: Transform.translate(
                  offset: Offset(0, -80), // Move the images up by 80 pixels
                  child: Image.asset(
                    images[index], // Display images
                    fit: BoxFit.scaleDown, // Scale down if needed
                  ),
                ),
              );
            },
          ),

          // Back Arrow - only show on the first image
          if (currentIndex == 0) // Conditional rendering
            Positioned(
              top: 40,
              right: 15,
              child: GestureDetector(
                onTap: _goBack, // Navigate back to the previous page
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white, // Set the arrow color to white
                  size: 28,
                ),
              ),
            ),

          // Gradient Button Circle when on the last page
          if (currentIndex == images.length - 1) // Show only on the last image
            Positioned(
              bottom: 15,
              left: (MediaQuery.of(context).size.width - 80) / 2,
              child: GestureDetector(
                onTap: () {
                  // Navigate to sign-up page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
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
