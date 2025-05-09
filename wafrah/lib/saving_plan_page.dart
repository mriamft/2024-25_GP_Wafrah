import 'package:flutter/material.dart';
import 'goal_page.dart'; 
import 'settings_page.dart';
import 'transactions_page.dart';
import 'home_page.dart';
import 'banks_page.dart';
import 'secure_storage_helper.dart'; 
import 'saving_plan_page2.dart';
import 'chatbot.dart';

class SavingPlanPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final List<Map<String, dynamic>> accounts;

  const SavingPlanPage({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [],
  });

  @override
  _SavingPlanPageState createState() => _SavingPlanPageState();
}

class _SavingPlanPageState extends State<SavingPlanPage> {
  bool _isPressed = false;
  bool _isPlanSaved = false;

  // Define the function to check and navigate to SavingPlanPage2 or GoalPage
  void navigateToSavingPlan() async {
    // Check if there is a saved plan
    var savedPlan = await loadPlanFromSecureStorage();
    // If saved plan exists, navigate to SavingPlanPage2
    if (savedPlan != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SavingPlanPage2(
            userName: widget.userName,
            phoneNumber: widget.phoneNumber,
            accounts: widget.accounts,
            resultData: savedPlan, 
          ),
        ),
      );
    } else {
      // If no saved plan exists, navigate to GoalPage 
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GoalPage(
            userName: widget.userName,
            phoneNumber: widget.phoneNumber,
            accounts: widget.accounts,
          ),
        ),
      );
    }
  }

  // Function to save the plan and update state
  Future<void> _savePlan(Map<String, dynamic> planData) async {
    await savePlanToSecureStorage(planData); // Save the plan securely
    setState(() {
      _isPlanSaved = true; 
    });
    // Navigate to SavingPlanPage2 after saving
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SavingPlanPage2(
          userName: widget.userName,
          phoneNumber: widget.phoneNumber,
          accounts: widget.accounts,
          resultData: planData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/green_square.png',
              width: MediaQuery.of(context).size.width,
              height: 289,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 80, 
            top: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/Saving_image.png',
                  width: 240,
                  height: 400,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          const Positioned(
            left: 56,
            top: 490,
            child: Text(
              'خطة إدخار لهدفك',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 33,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),
          const Positioned(
            left: 39,
            top: 550,
            child: Text(
              'حدد هدفك, والمدة المرغوبة فقط وستحصل على\nخطة إدخار مثالية ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 15,
                fontFamily: 'GE-SS-Two-Light',
              ),
            ),
          ),
          Positioned(
            left: 61,
            top: 610,
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _isPressed = true;
                });
              },
              onTapUp: (_) {
                setState(() {
                  _isPressed = false;
                });
              },
              onTap: () {
                navigateToSavingPlan(); 
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 274,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF3D3D3D),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: _isPressed
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    'استمرار',
                    style: TextStyle(
                      color: _isPressed ? Colors.grey[300] : Colors.white,
                      fontSize: 16,
                      fontFamily: 'GE-SS-Two-Light',
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Navigation Bar
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
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildBottomNavItem(
                    Icons.settings_outlined,
                    "إعدادات",
                    0,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              SettingsPage(
                            userName: widget.userName,
                            phoneNumber: widget.phoneNumber,
                            accounts: widget.accounts,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  buildBottomNavItem(
                    Icons.credit_card,
                    "سجل المعاملات",
                    1,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              TransactionsPage(
                            userName: widget.userName,
                            phoneNumber: widget.phoneNumber,
                            accounts: widget.accounts,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  buildBottomNavItem(
                    Icons.account_balance_outlined,
                    "الحسابات",
                    2,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              BanksPage(
                            userName: widget.userName,
                            phoneNumber: widget.phoneNumber,
                            accounts: widget.accounts,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, right: 0),
                    child: buildBottomNavItem(
                        Icons.calendar_today, "خطة الإدخار", 3,
                        onTap: () {}),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 339,
            top: 785,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF2C8C68),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 44,
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 92,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2C8C68), Color(0xFF8FD9BD)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 44,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              HomePage(
                            userName: widget.userName,
                            phoneNumber: widget.phoneNumber,
                            accounts: widget.accounts,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 650,
            left: 328,
            child: GestureDetector(
              onTap: navigateToChatbot,
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/chatbotIcon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigateToChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chatbot(
          userName: widget.userName,
          phoneNumber: widget.phoneNumber,
          accounts: widget.accounts,
        ),
      ),
    );
  }

  Widget buildBottomNavItem(IconData icon, String label, int index,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFF2C8C68),
            size: 30,
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2C8C68),
              fontSize: 12,
              fontFamily: 'GE-SS-Two-Light',
            ),
          ),
        ],
      ),
    );
  }
}
