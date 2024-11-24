import 'package:flutter/material.dart';
import 'api_service.dart'; // Ensure the ApiService is imported
import 'package:url_launcher/url_launcher.dart'; // Import for URL launching
import 'gpt_service.dart'; // Import GPT service
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'banks_page.dart'; // Import the BanksPage file
import 'storage_service.dart';


class AccLinkPage extends StatefulWidget {
  final String userName; // Accept userName from previous page
  final String phoneNumber; // Accept phoneNumber from previous page
  final StorageService _storageService = StorageService();

  AccLinkPage({
    super.key,
    required this.userName,
    required this.phoneNumber,
  });

  @override
  _AccLinkPageState createState() => _AccLinkPageState();
}

class _AccLinkPageState extends State<AccLinkPage> {
  Color _arrowColor = const Color(0xFF3D3D3D); // Default arrow color
  final ApiService _apiService = ApiService(); // Initialize ApiService
  final GPTService _gptService = GPTService(); // Initialize GPT service
  String _accessToken = '';
  String _authorizationCode = '';
  String _finalAccessToken = '';
  List<Map<String, dynamic>> _accounts = []; // List to store retrieved accounts
  StreamSubscription? _sub; // For uni_links
  bool _isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    _initUniLinks(); // Initialize uni_links listener for deep links
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // UniLinks Initialization
  Future<void> _initUniLinks() async {
    _sub = linkStream.listen((String? link) async {
      if (link != null) {
        Uri uri = Uri.parse(link);
        String? code =
            uri.queryParameters['code']; // Extract the authorization code
        if (code != null) {
          if (mounted) {
            setState(() {
              _authorizationCode = code;
              _isLoading = true; // Show loading when returning from the browser
            });
          }

          await _exchangeAuthorizationCode(); // Process authorization code

          if (mounted) {
            setState(() {
              _isLoading = false; // Stop loading after processing
            });
          }
        }
      }
    }, onError: (err) {
      _showErrorDialog('Error handling deep link: $err');
    });
  }

  // Main function to handle all steps in order (1 to 9)
  void _startApiProcess() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Step 1: Get Well-Known Endpoint
      await _apiService.getWellKnownEndpoint();

      // Step 2: Get Access Token
      String accessToken = await _apiService.getAccessToken();
      setState(() {
        _accessToken = accessToken;
      });

      // Step 3: Create Account Access Consent
      await _apiService.createConsent(_accessToken);

      // Step 4: Create JWT for PAR
      String jwt = await _apiService.createJwt();

      // Step 5: POST to PAR
      String requestUri = await _apiService.postToPAR(jwt);

      // Step 6: Compute Authorization Code URL and Launch Browser
      String authorizationUrl = await _apiService.computeAuthorizationCodeUrl();
      await launch(authorizationUrl, forceSafariVC: false, forceWebView: false);
    } catch (e) {
      _showErrorDialog('Error during API process: $e');
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  // Step 7: Exchange Authorization Code for Access Token
  Future<void> _exchangeAuthorizationCode() async {
    try {
      if (_authorizationCode.isEmpty) {
        _showErrorDialog('Error: Authorization code is required.');
        return;
      }

      String token =
          await _apiService.exchangeCodeForAccessToken(_authorizationCode);
      setState(() {
        _finalAccessToken = token;
      });

      // Step: Get Account Details (Before fetching transactions)
      await _getAccountDetails();
    } catch (e) {
      _showErrorDialog('Error exchanging authorization code: $e');
    }
  }

  // Fetch Account Details and Transactions
  Future<void> _getAccountDetails() async {
    try {
      final List<dynamic> accounts =
          await _apiService.getAccountDetails(_finalAccessToken);

      List<Map<String, dynamic>> accountsWithBalances = [];

      for (var account in accounts) {
        String accountId = account['AccountId'];
        String accountSubType = account['AccountSubType'] ?? 'نوع الحساب';
        String iban = account['AccountIdentifiers'][0]['Identification'];
        String balance =
            await _apiService.getAccountBalance(_finalAccessToken, accountId);

        // Fetch transactions
        List<Map<String, dynamic>> transactions = await _apiService
            .getAccountTransactions(_finalAccessToken, accountId);

        // Categorize transactions
        List<Map<String, dynamic>> categorizedTransactions = [];
        for (var transaction in transactions) {
          String transactionInfo =
              transaction['TransactionInformation'] ?? 'معلومات غير متوفرة';
          String category = 'غير مصنف'; // Default category

          try {
            category = await _gptService.categorizeTransaction(transactionInfo);
          } catch (e) {
            print('Error categorizing transaction: $e');
          }

          categorizedTransactions.add({
            ...transaction, // Include all original transaction data
            'Category': category, // Add the category
          });
        }

        accountsWithBalances.add({
          'IBAN': iban,
          'AccountSubType': accountSubType,
          'Balance': balance,
          'transactions': categorizedTransactions,
        });
      }

      // Save accounts locally using StorageService
    await widget._storageService.saveAccountDataLocally(
        widget.phoneNumber, accountsWithBalances);

      if (mounted) {
        setState(() {
          _accounts = accountsWithBalances;
        });

        _redirectToBanksPage();
      }
    } catch (e) {
      _showErrorDialog('Error fetching account details or balance: $e');
    }
  }




  // Redirect to BanksPage with Accounts
  void _redirectToBanksPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BanksPage(
          userName: widget.userName,
          phoneNumber: widget.phoneNumber,
          accounts: _accounts,
        ),
      ),
    );
  }

  // Show Error Dialog
  void _showErrorDialog(String errorMessage) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          body: Stack(
            children: [
              // Back Arrow
              Positioned(
                top: 60,
                right: 15,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _arrowColor = Colors.grey;
                    });
                    Future.delayed(const Duration(milliseconds: 100), () {
                      setState(() {
                        _arrowColor = const Color(0xFF3D3D3D);
                      });
                      Navigator.pop(context);
                    });
                  },
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: _arrowColor,
                    size: 28,
                  ),
                ),
              ),

              // Title
              const Positioned(
                top: 58,
                left: 135,
                child: Text(
                  'إضافة حساب بنكي',
                  style: TextStyle(
                    color: Color(0xFF3D3D3D),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GE-SS-Two-Bold',
                  ),
                ),
              ),

              // Instruction Text 1
              const Positioned(
                top: 130,
                left: 28,
                child: Text(
                  'الرجاء قراءة المعلومات التالية قبل أن تكمل إجراءات الربط',
                  style: TextStyle(
                    color: Color(0xFF3D3D3D),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GE-SS-Two-Bold',
                  ),
                ),
              ),

              // Instruction Text 2
              const Positioned(
                top: 152,
                left: 49,
                child: SizedBox(
                  width: 300,
                  child: Text(
                    'أنت الآن تسمح لنا بقراءة بياناتك المصرفية من حسابك البنكي، نقوم بذلك من خلال معايير الخدمات المصرفية المفتوحة والتي تسمح لنا بالحصول على معلوماتك وعرضها في وفرة دون معرفة بيانات اعتمادك البنكية (مثل كلمة السر لحسابك البنكي)',
                    style: TextStyle(
                      color: Color(0xFF3D3D3D),
                      fontSize: 10,
                      fontFamily: 'GE-SS-Two-Light',
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),

              // Instruction Text 3
              const Positioned(
                top: 260,
                left: 60,
                child: Text(
                  'سوف نبدأ إجراءات الربط لجميع حساباتك البنكية عن طريق',
                  style: TextStyle(
                    color: Color(0xFF3D3D3D),
                    fontSize: 12,
                    fontFamily: 'GE-SS-Two-Light',
                  ),
                ),
              ),

              // Bar for bank information
              Positioned(
                top: 280,
                left: 21,
                child: Container(
                  width: 330,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: 35.0),
                      child: Text(
                        'ساما (البنك السعودي المركزي)',
                        style: TextStyle(
                          color: Color(0xFF3D3D3D),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'GE-SS-Two-Bold',
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // First SAMA Image
              Positioned(
                left: 315,
                top: 290.5,
                child: Image.asset(
                  'assets/images/SAMA_logo.png',
                  width: 30,
                  height: 30,
                ),
              ),

              // Submit Button
              Positioned(
                bottom: 40,
                left: 40,
                child: SizedBox(
                  width: 274,
                  height: 47,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D3D3D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      shadowColor: Colors.black,
                      elevation: 5,
                    ),
                    onPressed: _startApiProcess,
                    child: const Text(
                      'الاستمرار في اجراءات الربط',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'GE-SS-Two-Light',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Loading Overlay
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF69BA9C),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
