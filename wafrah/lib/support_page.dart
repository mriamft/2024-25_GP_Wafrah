import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  final String phoneNumber;
  final String userName;

  const SupportPage({
    super.key,
    required this.userName,
    required this.phoneNumber,
  });

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  Color _arrowColor = const Color(0xFF3D3D3D);

  // Force mailto to use %20 for spaces, avoiding "+" in some clients.
  Future<void> _launchEmail() async {
    final subject = 'طلب دعم وفرة'.replaceAll(' ', '%20');
    final body = 'الى فريق وفرة'.replaceAll(' ', '%20');
    final mailtoUrl =
        'mailto:wafrahapplication@gmail.com?subject=$subject&body=$body';

    final uri = Uri.parse(mailtoUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email client')),
      );
    }
  }

  void _onArrowTap() {
    setState(() {
      _arrowColor = Colors.grey;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _arrowColor = const Color(0xFF3D3D3D);
      });
      Navigator.pop(context);
    });
  }

  /// Extract only the first name from `widget.userName`.
  String getFirstName(String fullName) {
    return fullName.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final firstName = getFirstName(widget.userName);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Background image pinned at the top
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/green_square2.png',
              width: MediaQuery.of(context).size.width,
              height: 289,
              fit: BoxFit.cover,
            ),
          ),
          // Arrow pinned at the top-right
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
          // Title text pinned at the top (near center)
          const Positioned(
            top: 58,
            left: 140,
            child: Text(
              'التواصل مع الدعم',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),

          // Main content in the center of the screen
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // Use SingleChildScrollView in case the text is large or the screen is small
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row for "أهلًا" + first name
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.rtl,
                      children: [
                        const Text(
                          'أهلًا',
                          style: TextStyle(
                            color: Color(0xFF3D3D3D),
                            fontSize: 35,
                            fontFamily: 'GE-SS-Two-Bold',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            firstName,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Color(0xFF2C8C68),
                              fontSize: 35,
                              fontFamily: 'GE-SS-Two-Bold',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // كيف نقدر نساعدك؟
                    const Text(
                      'كيف نقدر نساعدك؟',
                      style: TextStyle(
                        color: Color(0xFF3D3D3D),
                        fontSize: 35,
                        fontFamily: 'GE-SS-Two-Bold',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // احنا بخدمتك عبر
                    const Text(
                      'احنا بخدمتك عبر',
                      style: TextStyle(
                        color: Color(0xFF3D3D3D),
                        fontSize: 20,
                        fontFamily: 'GE-SS-Two-Light',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // The button
                    GestureDetector(
                      onTap: _launchEmail,
                      child: Container(
                        width: 332,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'تواصل معنا عبر البريد الالكتروني',
                            style: TextStyle(
                              color: Color(0xFF3D3D3D),
                              fontSize: 20,
                              fontFamily: 'GE-SS-Two-Light',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    // .نرد عادةً في أقل من 10 دقائق
                    const Text(
                      '.نرد عادةً في أقل من 10 دقائق',
                      style: TextStyle(
                        color: Color(0xFF838383),
                        fontSize: 15,
                        fontFamily: 'GE-SS-Two-Light',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
