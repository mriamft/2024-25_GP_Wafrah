import 'package:flutter/material.dart';

import 'acc_link_page.dart';

import 'transactions_page.dart';








import 'home_page.dart';

import 'saving_plan_page.dart';

import 'settings_page.dart';

 

class BanksPage extends StatelessWidget {

  final String userName;

  final String phoneNumber;

  final List<Map<String, dynamic>> accounts;

 

  const BanksPage({

    super.key,

    required this.userName,

    required this.phoneNumber,

    this.accounts = const [],

  });

 

  // Method to build account card

  Widget _buildAccountCard(Map<String, dynamic> account) {

    Map<String, String> accountTypeTranslations = {

      'CurrentAccount': 'الحساب الجاري',

      'SavingsAccount': 'حساب التوفير',

      'CheckingAccount': 'حساب الشيكات',

      'CreditAccount': 'حساب الائتمان',

    };

 

    String accountSubType = account['AccountSubType'] ?? 'نوع الحساب';

    String translatedAccountSubType = accountTypeTranslations[accountSubType] ?? accountSubType;

 

    return Container(

      margin: const EdgeInsets.only(bottom: 20),

      width: 340,

      height: 50,

      decoration: BoxDecoration(

        color: Color(0xFFD9D9D9),

        borderRadius: BorderRadius.circular(8),

      ),

      child: Row(

        mainAxisAlignment: MainAxisAlignment.end,

        children: [

          Expanded(

            child: Row(

              mainAxisAlignment: MainAxisAlignment.end,

              children: [

                Text(

                  'ر.س',

                  style: TextStyle(

                    color: Color(0xFF5F5F5F),

                    fontSize: 16,

                    fontFamily: 'GE-SS-Two-Light',

                  ),

                ),

                SizedBox(width: 5),

                Text(

                  account['Balance'] ?? '0',

                  style: TextStyle(

                    color: Color(0xFF313131),

                    fontSize: 20,

                    fontWeight: FontWeight.bold,

                    fontFamily: 'GE-SS-Two-Bold',

                  ),

                  textAlign: TextAlign.right,

                  overflow: TextOverflow.ellipsis,

                ),

              ],

            ),

          ),

          SizedBox(width: 10),

          Column(

            mainAxisAlignment: MainAxisAlignment.center,

            crossAxisAlignment: CrossAxisAlignment.end,

            children: [

              Padding(

                padding: const EdgeInsets.only(right: 20),

                child: Text(

                  translatedAccountSubType,

                  style: TextStyle(

                    color: Color(0xFF3D3D3D),

                    fontSize: 13,

                    fontWeight: FontWeight.bold,

                    fontFamily: 'GE-SS-Two-Bold',

                  ),

                  overflow: TextOverflow.ellipsis,

                ),

              ),

              Padding(

                padding: const EdgeInsets.only(right: 20),

                child: Row(

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    Text(

                      account['IBAN'] ?? 'رقم الايبان',

                      style: TextStyle(

                        color: Color(0xFF5F5F5F),

                        fontSize: 13,

                        fontFamily: 'GE-SS-Two-Light',

                      ),

                      overflow: TextOverflow.ellipsis,

                    ),

                    SizedBox(width: 5),

                    Text(

                      'رقم الآيبان',

                      style: TextStyle(

                        color: Color(0xFF3D3D3D),

                        fontSize: 13,

                        fontFamily: 'GE-SS-Two-Bold',

                      ),

                    ),

                  ],

                ),

              ),

            ],

          ),

          SizedBox(width: 10),

          Padding(

            padding: const EdgeInsets.only(right: 10),

            child: Image.asset(

              'assets/images/SAMA_logo.png',

              width: 30,

              height: 30,

              fit: BoxFit.contain,

            ),

          ),

        ],

      ),

    );

  }

 

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Color(0xFFF9F9F9),

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

            top: 202,

            left: 12,

            right: 12,

            child: Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                IconButton(

                  icon: Icon(

                    Icons.add_circle,

                    color: Color(0xFF3D3D3D),

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

                Text(

                  'الحسابات البنكية',

                  style: TextStyle(

                    color: Color(0xFF3D3D3D),

                    fontSize: 16,

                    fontWeight: FontWeight.bold,

                    fontFamily: 'GE-SS-Two-Bold',

                  ),

                ),

              ],

            ),

          ),

          Positioned(

            top: 240,

            left: 12,

            child: Align(

              alignment: Alignment.centerLeft,

              child: OutlinedButton(

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

                style: TextButton.styleFrom(
    backgroundColor: Colors.transparent, // Ensures no background color
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
  ),

                child: Row(

                  mainAxisSize: MainAxisSize.min,

                  children: const [

                    Icon(

                      Icons.edit,

                      color: Color(0xFF3D3D3D),

                    ),

                    SizedBox(width: 5),

                    Text(

                      '',

                      style: TextStyle(

                        color: Color(0xFF3D3D3D),

                      ),

                    ),

                  ],

                ),

              ),

            ),

          ),

          

          Positioned(

            top: 350,

            left: 12,

            right: 12,

            child: SingleChildScrollView(

              child: Column(

                children: accounts.isNotEmpty

                    ? accounts.map((account) {

                        return _buildAccountCard(account);

                      }).toList()

                    : [

                        Center(

                          child: Text(

                            'لم تقم بإضافة حساباتك البنكية',

                            style: TextStyle(

                              color: Color(0xFF3D3D3D),

                              fontSize: 16,

                              fontFamily: 'GE-SS-Two-Light',

                            ),

                          ),

                        ),

                      ],

              ),

            ),

          ),

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

                    offset: Offset(0, -5),

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

                          accounts: accounts,

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

                          accounts: accounts,

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

                          accounts: accounts,

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

            color: Color(0xFF2C8C68),

            size: 30,

          ),

          Text(

            label,

            style: TextStyle(

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