import 'package:flutter/material.dart';
import 'secondpage.dart'; // Import the second page
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // for Firestore
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

// Entry point of the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
//helllllllllllllllllooooooooooooooooooooo
// ihihihi
  // Initialize WebView for Android without checking if it's null
  WebView.platform = SurfaceAndroidWebView();

  runApp(const MainApp());
}

// Fetch the access token for Lean API
Future<String> getApiAccessToken() async {
  final response = await http.post(
    Uri.parse('https://auth.sandbox.sa.leantech.me/oauth2/token'),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'client_id': '2fd5f0bf-a1b7-48d8-bc4a-e8bf73bdb2da',
      'client_secret': '32666435663062662d613162372d3438',
      'grant_type': 'client_credentials',
      'scope': 'api',
    },
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return data['access_token'];
  } else {
    throw Exception('Failed to get access token');
  }
}

// Fetch user accounts from Lean API
Future<List<dynamic>> fetchAccounts(String entityId, String token) async {
  final response = await http.get(
    Uri.parse('https://sandbox.sa.leantech.me/data/v2/accounts?entity_id=$entityId'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return data['accounts']; // Assuming accounts are in 'accounts' field
  } else {
    throw Exception('Failed to fetch accounts');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String balance = '';
  List<dynamic> accounts = []; // To hold account data

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Fetch User ID and Balance from Firebase
  Future<void> fetchUserData() async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Get User ID
        String userId = user.uid;
        print("User ID: $userId");

        // Fetch user data from Firestore
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        // Check if user document exists
        if (!userData.exists) {
          // If the user document does not exist, create it
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'balance': 0, // Initialize balance (you can adjust this as needed)
            'created_at': FieldValue.serverTimestamp(), // Optional: store creation timestamp
          });
          print("New user document created with ID: $userId");
        } else {
          // Assuming 'balance' is a field in the user document
          setState(() {
            balance = userData['balance'].toString();
            print("Balance: $balance");
          });
        }

        // Get entity_id
        String entityId = userData['entity_id']; // Change this as needed
        String token = await getApiAccessToken(); // Get API access token

        // Fetch accounts using the entity_id and token
        accounts = await fetchAccounts(entityId, token);
        setState(() {
          // Update UI with fetched accounts
        });
        print("Accounts: $accounts");
      } else {
        print("No user is currently signed in.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to the Flutter App!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text('Balance: $balance'),
            const SizedBox(height: 20),
            if (accounts.isNotEmpty)
              Column(
                children: accounts.map<Widget>((account) {
                  return ListTile(
                    title: Text(account['account_name'] ?? 'Account'), // Adjust based on the account structure
                    subtitle: Text('Account ID: ${account['account_id'] ?? 'N/A'}'), // Adjust based on the account structure
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the second page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const secondpage()),
                );
              },
              child: const Text('Go to Second Page'),
            ),
          ],
        ),
      ),
    );
  }
}

class LeanConnect extends StatelessWidget {
  final String customerId;
  final String token;

  LeanConnect({required this.customerId, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect Bank')),
      body: WebView(
        initialUrl: Uri.dataFromString(''' 
          <html>
          <body>
            <script src="https://cdn.leantech.me/link/v2"></script>
            <script>
              Lean.connect({
                app_token: '$token',
                permissions: ["identity","accounts","balance","transactions"],
                customer_id: '$customerId',
                sandbox: true,
                fail_redirect_url: 'https://docs.leantech.me/v2.0-KSA/page/failed-connection',
                success_redirect_url: 'https://docs.leantech.me/v2.0-KSA/page/successful-connection',
                account_type: 'personal',
              });
            </script>
          </body>
          </html>
        ''').toString(),
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
