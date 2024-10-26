import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'transactions_page.dart';
import 'saving_plan_page.dart';
import 'banks_page.dart';

class HomePage extends StatefulWidget {
  final String userName; // Dynamic user name passed from SignUp or Login
  final String phoneNumber;
  final List<Map<String, dynamic>> accounts; // Add accounts parameter

  const HomePage({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [], // Default to empty list if not passed
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  int currentPage = 0; // Track the current dashboard
  final PageController _pageController =
      PageController(); // Controller for PageView
  bool _isCirclePressed = false; // Track if the circle button is pressed

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Define the animation for the green square image (from top to its final position y = -100)
    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: const Offset(0, 0))
            .animate(
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
      backgroundColor: const Color(0xFFF9F9F9),
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
                // "أهلًا {userName}!" Greeting Text (Sticky to the right side of the image)
                Positioned(
                  top: 25,
                  right: 20, // Stick to the right side of the image
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: '!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontFamily: 'GE-SS-Two-Light',
                          ),
                        ),
                        const TextSpan(
                          text: 'أهلًا ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontFamily: 'GE-SS-Two-Light',
                          ),
                        ),
                        TextSpan(
                          text: widget.userName, // Use dynamic user name here
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontFamily: 'GE-SS-Two-Bold', // Bold user name
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
                    offset: const Offset(0, 5),
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
              icon: const Icon(Icons.visibility_outlined,
                  color: Color(0xFF9E9E9E)),
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
                const SizedBox(width: 10),
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
                    offset:
                        const Offset(0, -5), // Shadow position (above the bar)
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildBottomNavItem(Icons.settings_outlined, "إعدادات", 0,
                      onTap: () {
                    // Navigate to Settings Page and pass userName and accounts
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SettingsPage(
                                userName: widget.userName,
                                phoneNumber: widget.phoneNumber,
                                accounts: widget
                                    .accounts), // Pass userName and accounts
                        transitionDuration:
                            const Duration(seconds: 0), // Disable transition
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child; // No animation
                        },
                      ),
                      (route) => false,
                    );
                  }), // Outlined settings icon

                  buildBottomNavItem(Icons.credit_card, "سجل المعاملات", 1,
                      onTap: () {
                    // Navigate to Transactions Page and pass userName and accounts
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            TransactionsPage(
                                userName: widget.userName,
                                phoneNumber: widget.phoneNumber,
                                accounts: widget
                                    .accounts), // Pass userName and accounts
                        transitionDuration:
                            const Duration(seconds: 0), // Disable transition
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child; // No animation
                        },
                      ),
                      (route) => false,
                    );
                  }), // Transaction icon

                  buildBottomNavItem(Icons.home_outlined, "الرئيسية", 2,
                      isSelected: true, onTap: () {
                    // Do nothing for home page
                  }), // Outlined home icon

                  buildBottomNavItem(Icons.calendar_today, "خطة الإدخار", 3,
                      onTap: () {
                    // Navigate to Saving Plan Page and pass userName and accounts
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SavingPlanPage(
                                userName: widget.userName,
                                phoneNumber: widget.phoneNumber,
                                accounts: widget
                                    .accounts), // Pass userName and accounts
                        transitionDuration:
                            const Duration(seconds: 0), // Disable transition
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child; // No animation
                        },
                      ),
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
              onTapDown: (_) {
                setState(() {
                  _isCirclePressed = true; // Set the state to pressed
                });
              },
              onTapUp: (_) {
                setState(() {
                  _isCirclePressed = false; // Reset the state after press
                });
                // Navigate to Banks Page and pass userName and accounts
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        BanksPage(
                      userName: widget.userName,
                      phoneNumber: widget.phoneNumber,
                      accounts: widget.accounts, // Pass accounts
                    ), // Pass userName
                    transitionDuration:
                        const Duration(seconds: 0), // Disable transition
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return child; // No animation
                    },
                  ),
                  (route) => false,
                );
              },
              onTapCancel: () {
                setState(() {
                  _isCirclePressed =
                      false; // Reset the state if tap is canceled
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // #F9F9F9 circle without shadow
                  Container(
                    width: 92,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9F9F9),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Gradient green circle that changes when pressed
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isCirclePressed
                            ? [const Color(0xFF1A7A5E), const Color(0xFF6FC3A0)]
                            : [
                                const Color(0xFF2C8C68),
                                const Color(0xFF8FD9BD)
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
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
        color: currentPage == pageIndex ? const Color(0xFF2C8C68) : Colors.grey,
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
            color: const Color(0xFF2C8C68), // Changed to #2C8C68
            size: 30, // Increased size for icons
          ),
          Text(
            label,
            style: const TextStyle(
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
                decoration: const BoxDecoration(
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
          const SizedBox(height: 90), // Adjust height based on design
          const Text(
            'مجموع أموالك',
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontFamily: 'GE-SS-Two-Light',
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'هذه الخاصية سوف تتوفر قريبًا \n Next Sprint', // Divided into two lines
            textAlign: TextAlign.center, // Centered text
            style: TextStyle(
              color: Color(0xFF838383),
              fontSize: 20,
              fontFamily: 'GE-SS-Two-Bold',
            ),
          ),
          const SizedBox(height: 60),
          // "تدفقك المالي لهذا الشهر" shifted more to the right
          const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 1), // Moved more to the right
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
          const SizedBox(height: 10),
          // #F6F6F6 rectangle with corner radius of 8
          Container(
            width: 327,
            height: 166,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
            child: const Stack(
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
                    'هذه الخاصية سوف تتوفر قريبًا \n Next Sprint', // Divided into two lines
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
    return const Padding(
      padding: EdgeInsets.all(16.0),
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
            'هذه الخاصية سوف تتوفر قريبًا \n Next Sprint', // Divided into two lines
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
