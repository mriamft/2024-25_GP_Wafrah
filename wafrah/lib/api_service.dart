import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'config.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

String generateNonce() {
  return const Uuid().v4();
}

String generateState() {
  return const Uuid().v4();
}

class ApiService {
  String _consentId = '';
  String _codeVerifier = '';
  late StreamSubscription _sub;
  String? authorizationCode;

  ApiService() {
    _initUniLinks();
  }

  // used to capture authorization code from redirect URI
  void _initUniLinks() {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        authorizationCode = uri.queryParameters['code'];
        if (authorizationCode != null) {
          print('Authorization Code: $authorizationCode');
        }
      }
    }, onError: (err) {
      print('Failed to handle incoming link: $err');
    });
  }

  // Step 1: Create HttpClient with Certificates
  Future<HttpClient> _createHttpClientWithCert() async {
    // Load SSL/TLS certificate and private key
    final certPem = await rootBundle
        .loadString('assets/certs/transport-cert-Wafrah-SoftwareStatement.pem');
    final privateKey = await rootBundle
        .loadString('assets/certs/transport-key-Wafrah-SoftwareStatement.key');

    // Create SecurityContext for managing SSL/TLS configuration
    SecurityContext context = SecurityContext.defaultContext;
    context.useCertificateChainBytes(utf8.encode(certPem));
    context.usePrivateKeyBytes(utf8.encode(privateKey));

    // Initialize and return HttpClient to use in API calls
    HttpClient client = HttpClient(context: context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    return client;
  }

  // Step 2: Get OIDC Well-Known End-Point
  Future<void> getWellKnownEndpoint() async {
    // Initialize HttpClient
    final client = await _createHttpClientWithCert();
    // End-point of SAMA metadata
    var url = Uri.parse('${Config.baseUrl}/.well-known/openid-configuration');

    try {
      // Create HTTP GET request to get configuration data
      HttpClientRequest request = await client.getUrl(url);

      // Encode credentials
      request.headers.set('Authorization',
          'Basic ${base64Encode(utf8.encode("${Config.clientId}:${Config.clientSecret}"))}');
      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');

      // Send request and wait for response
      HttpClientResponse response = await request.close();
      // Decode and print the response
      response.transform(utf8.decoder).listen((contents) {
        print(contents);
      });
    } catch (e) {
      // Handle error
      print('Error fetching well-known endpoint: $e');
    }
  }

  // Step 3: Client Credentials Grant (accounts scope)
  Future<String> getAccessToken() async {
    // Create HttpClient
    final client = await _createHttpClientWithCert();
    var url = Uri.parse('https://as1.lab.openbanking.sa/token');

    try {
      // Initialize HTTP POST request
      HttpClientRequest request = await client.postUrl(url);
      // Add our client id and secret to the header
      request.headers.set('Authorization',
          'Basic ${base64Encode(utf8.encode("${Config.clientId}:${Config.clientSecret}"))}');
      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
      // Request body
      request.write('grant_type=client_credentials&scope=accounts openid');

      // Send request and wait for response
      HttpClientResponse response =
          await request.close().timeout(const Duration(seconds: 180));
      // Decode, extract, and return access token
      String responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        return jsonResponse['access_token'];
      } else {
        throw Exception('Failed to get access token: $responseBody');
      }
    } catch (e) {
      // Handle error
      print('Error fetching access token: $e');
      rethrow;
    }
  }

  // Step 4: POST Account Access Consents
  Future<void> createConsent(String accessToken) async {
    // Create HttpClient
    final client = await _createHttpClientWithCert();
    // Endpoint URL
    var url = Uri.parse(
        'https://rs1.lab.openbanking.sa/open-banking/account-information/2022.11.01-final-errata2/account-access-consents');

    try {
      // Initialize HTTP POST request to the account access consents
      HttpClientRequest request = await client.postUrl(url);
      // Add token to the header
      request.headers.set('Authorization', 'Bearer $accessToken');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('x-fapi-financial-id', '');
      request.headers.set('x-fapi-interaction-id', '');

      // Request body
      request.write(jsonEncode({
        "Data": {
          "Permissions": [
            "ReadAccountsBasic",
            "ReadAccountsDetail",
            "ReadBalances",
            "ReadParty",
            "ReadPartyPSU",
            "ReadPartyPSUIdentity",
            "ReadBeneficiariesBasic",
            "ReadBeneficiariesDetail",
            "ReadTransactionsBasic",
            "ReadTransactionsDetail",
            "ReadTransactionsCredits",
            "ReadTransactionsDebits",
            "ReadScheduledPaymentsBasic",
            "ReadScheduledPaymentsDetail",
            "ReadDirectDebits",
            "ReadStandingOrdersBasic",
            "ReadStandingOrdersDetail"
          ],
          "TransactionFromDateTime": "2016-01-01T10:40:00+02:00",
          "TransactionToDateTime": "2025-12-31T10:40:00+02:00",
          "ExpirationDateTime": "2025-12-31T10:40:00+02:00"
        }
      }));

      // Send request and wait for response
      HttpClientResponse response = await request.close();
      // Decode, extract, and response content
      String responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(responseBody);
        _consentId = jsonResponse['Data']['ConsentId'];
        print('Consent created successfully with ID: $_consentId');
      } else {
        throw Exception('Failed to create consent: $responseBody');
      }
    } catch (e) {
      // Handle error
      print('Error creating consent: $e');
      rethrow;
    }
  }

  // Step 5: Create JWT for PAR Request
  Future<String> createJwt() async {
    // Create HttpClient
    final client = await _createHttpClientWithCert();
    // Endpoint URL
    var url =
        Uri.parse('https://rs1.lab.openbanking.sa/o3/v1.0/message-signature');

    try {
      // Initialize HTTP GET request to get JWT
      HttpClientRequest request = await client.getUrl(url);
      request.headers.set('Content-Type', 'application/json');

      // Generate a code verifier
      _codeVerifier = const Uuid().v4() + const Uuid().v4();
      // Hash the code with SHA-256
      var bytes = utf8.encode(_codeVerifier);
      var digest = sha256.convert(bytes);
      String codeChallenge = base64Url.encode(digest.bytes).replaceAll('=', '');

      // Expiration of JWT
      double exp = DateTime.now()
              .add(const Duration(minutes: 5))
              .millisecondsSinceEpoch /
          1000;
      double nbf = DateTime.now().millisecondsSinceEpoch / 1000 - 10;

      // Body
      Map<String, dynamic> body = {
        "header": {"alg": "none"},
        "body": {
          "aud": "https://auth1.lab.openbanking.sa",
          "exp": exp,
          "iss": Config.clientId,
          "scope": "accounts:$_consentId openid",
          "redirect_uri": "wafrah://auth-callback",
          "client_id": Config.clientId,
          "nonce": generateNonce(),
          "state": generateState(),
          "nbf": nbf,
          "response_type": "code",
          "code_challenge_method": "S256",
          "code_challenge": codeChallenge
        }
      };

      // Encode and write request body
      String requestBody = jsonEncode(body);
      request.headers.set('Content-Length', utf8.encode(requestBody).length);
      request.write(requestBody);

      // Send request and wait for response
      HttpClientResponse response = await request.close();
      // Decode and return JWT
      String responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        print('JWT generated: $responseBody');
        return responseBody;
      } else {
        // Handle error
        throw Exception('Failed to generate JWT: $responseBody');
      }
    } catch (e) {
      print('Error creating JWT: $e');
      rethrow;
    }
  }

  // Step 6: POST to PAR Endpoint and return requestUri
  Future<String> postToPAR(String jwt) async {
    // Create HttpClient
    final client = await _createHttpClientWithCert();
    // Endpoint URL
    var url = Uri.parse('https://as1.lab.openbanking.sa/par');

    try {
      // Initialize HTTP POST request
      HttpClientRequest request = await client.postUrl(url);
      request.headers.set('Authorization',
          'Basic ${base64Encode(utf8.encode("${Config.clientId}:${Config.clientSecret}"))}');
      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
      // We will add JWT from previous step to the body
      request.write('request=$jwt');

      // Send request and wait for response
      HttpClientResponse response = await request.close();
      // Decode, extract, and return request_uri
      String responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(responseBody);
        String requestUri = jsonResponse['request_uri'];
        print('Request URI: $requestUri');
        return requestUri;
      } else {
        // Handle error
        throw Exception('Failed to post to PAR: $responseBody');
      }
    } catch (e) {
      print('Error posting to PAR: $e');
      rethrow;
    }
  }

  // Step 7: Compute Authorization Code URL
  Future<String> computeAuthorizationCodeUrl() async {
    try {
      String jwt = await createJwt(); // step5
      String requestUri = await postToPAR(jwt); // step6

      if (_consentId.isEmpty) {
        throw Exception(
            'Invalid ConsentId. Please complete Step 3 successfully.');
      }

      final client = await _createHttpClientWithCert();
      // Auth URI
      var url = Uri.parse(
          'https://rs1.lab.openbanking.sa/o3/v1.0/par-auth-code-url/$_consentId?response_type=code%20id_token&scope=openid%20accounts&request_uri=$requestUri');

      // Initialize HTTP GET request
      HttpClientRequest request = await client.getUrl(url);
      request.headers.set('Authorization',
          'Basic ${base64Encode(utf8.encode("${Config.clientId}:${Config.clientSecret}"))}');
      // Get and decode response
      HttpClientResponse response = await request.close();
      String responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        print('Authorization Code URL: $responseBody');
        return responseBody;
      } else {
        throw Exception(
          // Handle error
            'Failed to compute Authorization Code URL: $responseBody');
      }
    } catch (e) {
      print('Error computing authorization code URL: $e');
      rethrow;
    }
  }

  // Step 8: Exchange Authorization Code for Access Token
  Future<String> exchangeCodeForAccessToken(String authorizationCode) async {
    final client = await _createHttpClientWithCert();
    var url = Uri.parse('https://as1.lab.openbanking.sa/token');

    try {
      // Initialize HTTP POST request
      HttpClientRequest request = await client.postUrl(url);
      request.headers.set('Authorization',
          'Basic ${base64Encode(utf8.encode("${Config.clientId}:${Config.clientSecret}"))}');
      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
      // Write request body
      request.write(
          'grant_type=authorization_code&scope=accounts&code=$authorizationCode&redirect_uri=wafrah://auth-callback&code_verifier=$_codeVerifier');

      // Send request and wait for response
      HttpClientResponse response = await request.close();
      // Decode, extract, and return access token
      String responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        return jsonResponse['access_token'];
      } else {
        // Handle error
        throw Exception('Failed to exchange authorization code: $responseBody');
      }
    } catch (e) {
      print('Error exchanging authorization code: $e');
      rethrow;
    }
  }

  // Step 9: GET All Account Transactions
  Future<void> getAllAccountTransactions(String accessToken) async {
    final client = await _createHttpClientWithCert();
    var url = Uri.parse(
        'https://rs1.lab.openbanking.sa/open-banking/account-information/2022.11.01-final-errata2/accounts');

    try {
      // Initialize HTTP GET request
      HttpClientRequest request = await client.getUrl(url);
      request.headers.set('Authorization', 'Bearer $accessToken');
      request.headers.set('Content-Type', 'application/json');

      // Send request and wait for response
      HttpClientResponse response = await request.close();
      // Decode and parse response
      String responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        List accounts = jsonResponse['Data']['Account'];

        if (accounts.isNotEmpty) { // Ensure user has accounts
          for (var account in accounts) { // Loop through accounts
            String accountId = account['AccountId'];
            print('Fetching transactions for Account ID: $accountId');
            // Call another function to fetch each account's transactions
            await getAccountTransactions(accessToken, accountId);
          }
        } else {
          print('No accounts available for this user.');
        }
      } else {
        // Handle error
        print('Failed to fetch accounts: $responseBody');
      }
    } catch (e) {
      print('Error fetching accounts: $e');
    }
  }

  // Step 10: GET Transactions for a Specific Account
Future<List<Map<String, dynamic>>> getAccountTransactions(String accessToken, String accountId) async {
  final client = await _createHttpClientWithCert();
  var url = Uri.parse('https://rs1.lab.openbanking.sa/open-banking/account-information/2022.11.01-final-errata2/accounts/$accountId/transactions');

  try {
    // Initialize HTTP GET request
    HttpClientRequest request = await client.getUrl(url);
    request.headers.set('Authorization', 'Bearer $accessToken');
    request.headers.set('Content-Type', 'application/json');

    // Send request and wait for response
    HttpClientResponse response = await request.close();
    // Decode and parse response
    String responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(responseBody);
      return jsonResponse['Data']['Transaction'].cast<Map<String, dynamic>>(); // List of transactions
    } else {
      // Handle error
      throw Exception('Failed to fetch transactions for Account ID $accountId: $responseBody');
    }
  } catch (e) {
    print('Error fetching transactions for Account ID $accountId: $e');
    rethrow;
  }
}


  Future<String> getAccountBalance(String accessToken, String accountId) async {
    // Create HttpClient
    final client = await _createHttpClientWithCert();
    var url = Uri.parse(
        'https://rs1.lab.openbanking.sa/open-banking/account-information/2022.11.01-final-errata2/accounts/$accountId/balances');

    try {
      // Initialize HTTP GET request
      HttpClientRequest request = await client.getUrl(url);
      request.headers.set('Authorization', 'Bearer $accessToken');
      request.headers.set('Content-Type', 'application/json');

      // Send request and wait for response
      HttpClientResponse response = await request.close();
      // Decode and parse response
      String responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        // Extract the amount from the balance data structure
        var balanceInfo = jsonResponse['Data']['Balance'][0];
        String balance = balanceInfo['Amount']['Amount'] // Get balance based on response structure
            .toString(); 
        return balance;
      } else {
        throw Exception(
          // Handle error
            'Failed to fetch balance for Account ID $accountId: $responseBody');
      }
    } catch (e) {
      print('Error fetching balance for Account ID $accountId: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getAccountDetails(String accessToken) async {
    final client = await _createHttpClientWithCert();
    // Endpoint URL
    var url = Uri.parse(
        'https://rs1.lab.openbanking.sa/open-banking/account-information/2022.11.01-final-errata2/accounts');

    try {
      // Initialize HTTP GET request
      HttpClientRequest request = await client.getUrl(url);
      request.headers.set('Authorization', 'Bearer $accessToken');
      request.headers.set('Content-Type', 'application/json');

      // Send request and wait for response
      HttpClientResponse response = await request.close();
      // Decode and parse JSON response
      String responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);

        // Return account's details
        if (jsonResponse['Data'] != null &&
            jsonResponse['Data']['Account'] != null) {
          return jsonResponse['Data']['Account'];
        } else {
           // Handle error
          throw Exception('Unexpected response format in getAccountDetails');
        }
      } else {
        throw Exception('Failed to fetch account details: $responseBody');
      }
    } catch (e) {
      print('Error fetching account details: $e');
      rethrow;
    }
  }


  // Dispose listener
  void dispose() {
    _sub.cancel();
  }
}
