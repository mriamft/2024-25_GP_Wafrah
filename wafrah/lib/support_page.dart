import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  final String phoneNumber;
  final String userName;

  const SupportPage({Key? key, required this.userName, required this.phoneNumber})
      : super(key: key);

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  Color _arrowColor = const Color(0xFF3D3D3D);

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
              'assets/images/green_square2.png',
              width: MediaQuery.of(context).size.width,
              height: 289,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 60,
            right: 15,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
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
          Positioned(
            top: 243,
            left: 121,
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'أهلًا ',
                    style: TextStyle(
                      color: Color(0xFF3D3D3D),
                      fontSize: 35,
                      fontFamily: 'GE-SS-Two-Bold',
                    ),
                  ),
                  TextSpan(
                    text: 'عبير',
                    style: TextStyle(
                      color: Color(0xFF2C8C68),
                      fontSize: 35,
                      fontFamily: 'GE-SS-Two-Bold',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 294,
            left: 20,
            child: Text(
              'كيف نقدر نساعدك؟',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 35,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),
          const Positioned(
            top: 417,
            left: 205,
            child: Text(
              'احنا بخدمتك عبر',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 20,
                fontFamily: 'GE-SS-Two-Light',
              ),
            ),
          ),
          const Positioned(
            top: 521,
            left: 160,
            child: Text(
              '.نرد عادةً في أقل من 10 دقائق',
              style: TextStyle(
                color: Color(0xFF838383),
                fontSize: 15,
                fontFamily: 'GE-SS-Two-Light',
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: 460,
            child: GestureDetector(
              onTap: () {
                launchEmail();
              },
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
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'WafrahApplication@gmail.com',
      queryParameters: {'subject': 'التواصل مع الدعم'},
    );
    print('Launching email: ${emailLaunchUri.toString()}');
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch $emailLaunchUri');
    }
  }
}
