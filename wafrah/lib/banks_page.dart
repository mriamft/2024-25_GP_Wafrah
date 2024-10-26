import 'package:flutter/material.dart';
import 'home_page.dart'; // Import your home page
import 'acc_link_page.dart'; // Import the account link page
import 'settings_page.dart'; // Import the settings page
import 'transactions_page.dart'; // Import the transactions page
import 'saving_plan_page.dart'; // Import the saving plan page

class BanksPage extends StatelessWidget {
  final String userName; // Pass userName from previous pages
  final String phoneNumber;
  final List<Map<String, dynamic>>
      accounts; // Optional account details from AccLinkPage

  const BanksPage({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [], // Default to an empty list if not passed
  });

  // Method to build account card
  Widget _buildAccountCard(Map<String, dynamic> account) {
    Map<String, String> accountTypeTranslations = {
      'CurrentAccount': 'الحساب الجاري',
      'SavingsAccount': 'حساب التوفير',
      'CheckingAccount': 'حساب الشيكات',
      'CreditAccount': 'حساب الائتمان',
      // Add more translations as needed
    };

    String accountSubType = account['AccountSubType'] ?? 'نوع الحساب';
    String translatedAccountSubType =
        accountTypeTranslations[accountSubType] ?? accountSubType;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: 340,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Align to the right
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align text and currency to the right
              children: [
                const Text(
                  'ر.س', // Place the currency on the left
                  style: TextStyle(
                    color: Color(
                        0xFF5F5F5F), // Use a lighter grey for the currency symbol
                    fontSize: 16, // Smaller font size for the currency
                    fontFamily:
                        'GE-SS-Two-Light', // Ensure the same font as the project
                  ),
                ),
                const SizedBox(
                    width: 5), // Add some space between currency and balance
                Text(
                  account['Balance'] ??
                      '0', // This can later be dynamic if needed
                  style: const TextStyle(
                    color: Color(0xFF313131),
                    fontSize: 20, // Smaller font size for the balance
                    fontWeight: FontWeight.bold,
                    fontFamily:
                        'GE-SS-Two-Bold', // Ensure the same font as the project
                  ),
                  textAlign: TextAlign.right, // Align the text to the right
                  overflow: TextOverflow.ellipsis, // Handle long text
                ),
              ],
            ),
          ),
          const SizedBox(width: 10), // Adjust spacing between elements
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    right: 20), // Adjust padding for layout
                child: Text(
                  translatedAccountSubType, // Use the translated account subtype
                  style: const TextStyle(
                    color: Color(0xFF3D3D3D),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily:
                        'GE-SS-Two-Bold', // Ensure the same font as the project
                  ),
                  overflow: TextOverflow
                      .ellipsis, // Handle overflow in case of long text
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    right: 20), // Adjust padding for layout
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Make row shrink to content
                  children: [
                    Text(
                      account['IBAN'] ??
                          'رقم الايبان', // Dynamically display the IBAN
                      style: const TextStyle(
                        color: Color(0xFF5F5F5F),
                        fontSize: 13,
                        fontFamily:
                            'GE-SS-Two-Light', // Ensure the same font as the project
                      ),
                      overflow: TextOverflow
                          .ellipsis, // Handle overflow for long IBANs
                    ),
                    const SizedBox(
                        width: 5), // Add space between IBAN and label
                    const Text(
                      'رقم الآيبان', // Label for IBAN
                      style: TextStyle(
                        color: Color(0xFF3D3D3D),
                        fontSize: 13,
                        fontFamily:
                            'GE-SS-Two-Bold', // Same font as the project
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 10), // Space between text and logo
          // SAMA Logo
          Padding(
            padding:
                const EdgeInsets.only(right: 10), // Adjust padding for layout
            child: Image.asset(
              'assets/images/SAMA_logo.png', // Path to SAMA logo
              width: 30, // Set logo width
              height: 30, // Set logo height
              fit: BoxFit.contain, // Fit the logo within the box
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Background color
      body: Stack(
        children: [
          // Green square image
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

          // Title and + Button
          Positioned(
            top: 202,
            left: 12, // Left aligned the + button
            right: 12,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Aligned elements
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: Color(0xFF3D3D3D), // Dark grey color
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccLinkPage(
                          userName: userName,
                          phoneNumber: phoneNumber,
                        ),
                      ),
                    );
                  },
                ),
                const Text(
                  'الحسابات البنكية',
                  style: TextStyle(
                    color: Color(0xFF3D3D3D),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily:
                        'GE-SS-Two-Bold', // Ensure same font as the project
                  ),
                ),
              ],
            ),
          ),

          // Changing and Unlinking Accounts Button
          Positioned(
            top: 240,
            left: 12, // Aligned to the left under the plus button
            child: Align(
              alignment: Alignment.centerLeft, // Align the button to the left
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to AccLinkPage when button is clicked
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccLinkPage(
                        userName: userName,
                        phoneNumber: phoneNumber,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  side: const BorderSide(color: Color(0xFF3D3D3D)),
                ),
                child: const Text(
                  'تغيير وإزالة ربط الحسابات',
                  style: TextStyle(
                    color: Color(0xFF3D3D3D),
                    fontSize: 14,
                    fontFamily:
                        'GE-SS-Two-Light', // Ensure same font as the project
                  ),
                ),
              ),
            ),
          ),

          // Dynamically display accounts or a message if no accounts
          Positioned(
            top: 300,
            left: 12,
            right: 12,
            child: SingleChildScrollView(
              child: Column(
                children: accounts.isNotEmpty
                    ? accounts.map((account) {
                        return _buildAccountCard(account);
                      }).toList() // Convert the Iterable to List<Widget>
                    : [
                        const Center(
                          child: Text(
                            'لم تقم بإضافة حساباتك البنكية',
                            style: TextStyle(
                              color: Color(0xFF3D3D3D),
                              fontSize: 16,
                              fontFamily:
                                  'GE-SS-Two-Light', // Ensure same font as the project
                            ),
                          ),
                        ),
                      ],
              ),
            ),
          ),

          // Bottom Navigation Bar and other UI elements...
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
                  buildBottomNavItem(Icons.settings_outlined, "إعدادات", () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(
                          userName: userName,
                          phoneNumber: phoneNumber,
                          accounts: accounts, // Ensure accounts are passed here
                        ),
                      ),
                    );
                  }),
                  buildBottomNavItem(Icons.credit_card, "سجل المعاملات", () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionsPage(
                          userName: userName,
                          phoneNumber: phoneNumber,
                          accounts: accounts, // Ensure accounts are passed here
                        ),
                      ),
                    );
                  }),
                  buildBottomNavItem(Icons.home_outlined, "الرئيسية", () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          userName: userName,
                          phoneNumber: phoneNumber,
                          accounts: accounts, // Ensure accounts are passed here
                        ),
                      ),
                    );
                  }),
                  buildBottomNavItem(Icons.calendar_today, "خطة الإدخار", () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SavingPlanPage(
                          userName: userName,
                          phoneNumber: phoneNumber,
                          accounts: accounts, // Ensure accounts are passed here
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Item
  Widget buildBottomNavItem(IconData icon, String label, VoidCallback onTap) {
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
