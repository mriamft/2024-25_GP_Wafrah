import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'transactions_page.dart';
import 'saving_plan_page.dart';
import 'banks_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  int currentPage = 0; // Track the current dashboard
  PageController _pageController = PageController(); // Controller for PageView

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    // Define the animation for the green square image (from top to its final position y = -100)
    _offsetAnimation =
        Tween<Offset>(begin: Offset(0, -1), end: Offset(0, 0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start the animation when the page is opened
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Green square animation
          SlideTransition(
            position: _offsetAnimation,
            child: Stack(
              children: [
                // Green square image (keep the original aspect ratio)
                Positioned(
                  top: -100, // Final stop position for y
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/images/green_square.png',
                    width: MediaQuery.of(context).size.width,
                    height: 289,
                    fit: BoxFit.contain, // Keep original aspect ratio
                  ),
                ),
                // "أهلًا عبير!" Greeting Text (Sticky to the right side of the image)
                Positioned(
                  top: 25,
                  right: 20, // Stick to the right side of the image
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontFamily: 'GE-SS-Two-Light',
                          ),
                        ),
                        TextSpan(
                          text: 'أهلًا ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontFamily: 'GE-SS-Two-Light',
                          ),
                        ),
                        TextSpan(
                          text: 'عبير',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontFamily: 'GE-SS-Two-Bold', // Bold "عبير"
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main white card for content (dashboard)
          Positioned(
            top: 80,
            left: 19,
            right: 19,
            child: Container(
              height: 610, // Reduced height of the dashboard
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                children: [
                  buildFirstDashboard(),
                  buildSecondDashboard(),
                ],
              ),
            ),
          ),

          // Restored Eye Icon
          Positioned(
            top: 100,
            right: 30,
            child: IconButton(
              icon: Icon(Icons.visibility_outlined, color: Color(0xFF9E9E9E)),
              iconSize: 31,
              onPressed: () {},
            ),
          ),

          // Circle indicators for dashboard navigation
          Positioned(
            bottom: 150, // Positioned higher
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildDot(0),
                SizedBox(width: 10),
                buildDot(1),
              ],
            ),
          ),

          // Bottom Navigation Bar with shadow
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 77,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Shadow color
                    blurRadius: 10, // Shadow blur
                    offset: Offset(0, -5), // Shadow position (above the bar)
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildBottomNavItem(Icons.settings_outlined, "إعدادات", 0,
                      onTap: () {
                    // Navigate to Settings Page with no transition
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                      (route) => false,
                    );
                  }), // Outlined settings icon
                  buildBottomNavItem(Icons.credit_card, "سجل المعاملات", 1,
                      onTap: () {
                    // Navigate to Transactions Page with no transition
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => TransactionsPage()),
                      (route) => false,
                    );
                  }), // Transaction icon
                  buildBottomNavItem(Icons.home_outlined, "الرئيسية", 2,
                      isSelected: true, onTap: () {
                    // Do nothing for home page
                  }), // Outlined home icon
                  buildBottomNavItem(Icons.calendar_today, "خطة الإدخار", 3,
                      onTap: () {
                    // Navigate to Saving Plan Page with no transition
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => SavingPlanPage()),
                      (route) => false,
                    );
                  }), // Plan icon
                ],
              ),
            ),
          ),

          // Circular Button above the Navigation Bar (F9F9F9 circle + gradient green circle)
          Positioned(
            bottom: 45, // Adjusted the position to be more lower
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // Navigate to Banks Page with no transition
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => BanksPage()),
                  (route) => false,
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // #F9F9F9 circle without shadow
                  Container(
                    width: 92,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Color(0xFFF9F9F9),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Gradient green circle
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2C8C68), Color(0xFF8FD9BD)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dot for switching between dashboards
  Widget buildDot(int pageIndex) {
    return Container(
      width: 10, // Smaller width
      height: 10, // Smaller height
      decoration: BoxDecoration(
        color: currentPage == pageIndex ? Color(0xFF2C8C68) : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  // Bottom Navigation Item
  Widget buildBottomNavItem(IconData icon, String label, int index,
      {bool isSelected = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Color(0xFF2C8C68), // Changed to #2C8C68
            size: 30, // Increased size for icons
          ),
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF2C8C68), // Changed to #2C8C68
              fontSize: 12, // Adjusted font size
              fontFamily: 'GE-SS-Two-Light', // Same font as the interface
            ),
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Color(0xFF2C8C68), // Current page indicator color
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // First Dashboard Layout
  Widget buildFirstDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 90), // Adjust height based on design
          Text(
            'مجموع أموالك',
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontFamily: 'GE-SS-Two-Light',
            ),
          ),
          SizedBox(height: 10),
          Text(
            'هذه الخاصية لم تتوفر\nحتى الآن', // Divided into two lines
            textAlign: TextAlign.center, // Centered text
            style: TextStyle(
              color: Color(0xFF838383),
              fontSize: 20,
              fontFamily: 'GE-SS-Two-Bold',
            ),
          ),
          SizedBox(height: 60),
          // "تدفقك المالي لهذا الشهر" shifted more to the right
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding:
                  const EdgeInsets.only(right: 1), // Moved more to the right
              child: Text(
                'تدفقك المالي لهذا الشهر',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontFamily: 'GE-SS-Two-Light',
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          // #F6F6F6 rectangle with corner radius of 8
          Container(
            width: 327,
            height: 166,
            decoration: BoxDecoration(
              color: Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 25,
                  top: -20,
                  child: Icon(
                      Icons
                          .keyboard_arrow_down_rounded, // Thinner and rounded "^" arrow
                      color: Color(0xFFC62C2C),
                      size: 90),
                ),
                Positioned(
                  right: 30,
                  top: -20,
                  child: Icon(
                      Icons
                          .keyboard_arrow_up_rounded, // Thinner and rounded "^" arrow
                      color: Color(0xFF2C8C68),
                      size: 90),
                ),
                Positioned(
                  right: 63,
                  bottom: 110,
                  child: Text(
                    'الدخل',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontFamily: 'GE-SS-Two-Light',
                    ),
                  ),
                ),
                Positioned(
                  left: 55,
                  bottom: 110,
                  child: Text(
                    'الصرف',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontFamily: 'GE-SS-Two-Light',
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'هذه الخاصية لم تتوفر\nحتى الآن', // Divided into two lines
                    textAlign: TextAlign.center, // Centered text
                    style: TextStyle(
                      color: Color(0xFF838383),
                      fontSize: 20,
                      fontFamily: 'GE-SS-Two-Bold',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Second Dashboard Layout
  Widget buildSecondDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 90),
          Text(
            'تحليل النفقات',
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontFamily: 'GE-SS-Two-Light',
            ),
          ),
          SizedBox(height: 10),
          Text(
            'هذه الخاصية لم تتوفر\nحتى الآن', // Divided into two lines
            textAlign: TextAlign.center, // Centered text
            style: TextStyle(
              color: Color(0xFF838383),
              fontSize: 20,
              fontFamily: 'GE-SS-Two-Bold',
            ),
          ),
        ],
      ),
    );
  }
}