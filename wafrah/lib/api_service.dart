import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'config.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  // Initialize uni_links to capture the authorization code from redirect URI
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
    final certPem = await rootBundle
        .loadString('assets/certs/transport-cert-Wafrah-SoftwareStatement.pem');
    final privateKey = await rootBundle
        .loadString('assets/certs/transport-key-Wafrah-SoftwareStatement.key');

    SecurityContext context = SecurityContext.defaultContext;
    context.useCertificateChainBytes(utf8.encode(certPem));
    context.usePrivateKeyBytes(utf8.encode(privateKey));

    HttpClient client = HttpClient(context: context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    return client;
  }

  // Step 2: Get OIDC Well-Known End-Point
  Future<void> getWellKnownEndpoint() async {
    final client = await _createHttpClientWithCert();
    var url = Uri.parse('${Config.baseUrl}/.well-known/openid-configuration');

    try {
      HttpClientRequest request = await client.getUrl(url);
      request.headers.set('Authorization',
          'Basic ${base64Encode(utf8.encode("${Config.clientId}:${Config.clientSecret}"))}');
      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');

      HttpClientResponse response = await request.close();
      response.transform(utf8.decoder).listen((contents) {
        print(contents);
      });
    } catch (e) {
      print('Error fetching well-known endpoint: $e');
    }
  }

  // Step 3: Client Credentials Grant (accounts scope)
  Future<String> getAccessToken() async {
    final client = await _createHttpClientWithCert();
    var url = Uri.parse('https://as1.lab.openbanking.sa/token');

    try {
      HttpClientRequest request = await client.postUrl(url);
      request.headers.set('Authorization',
          'Basic ${base64Encode(utf8.encode("${Config.clientId}:${Config.clientSecret}"))}');
      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
      request.write('grant_type=client_credentials&scope=accounts openid');

      HttpClientResponse response =
          await request.close().timeout(const Duration(seconds: 180));
      String responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        return jsonResponse['access_token'];
      } else {
        throw Exception('Failed to get access token: $responseBody');
      }
    } catch (e) {
      print('Error fetching access token: $e');
      rethrow;
    }
  }

  // Step 3: POST Account Access Consents
  Future<void> createConsent(String accessToken) async {
    final client = await _createHttpClientWithCert();
    var url = Uri.parse(
        'https://rs1.lab.openbanking.sa/open-banking/account-information/2022.11.01-final-errata2/account-access-consents');

    try {
      // final financialID=dotenv.env['FinancialID'] ?? 'default-financial-id';
      // final interactionID=dotenv.env['InteractionID'] ?? 'default-interaction-id';
      HttpClientRequest request = await client.postUrl(url);
      request.headers.set('Authorization', 'Bearer $accessToken');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('x-fapi-financial-id', '');
      request.headers.set('x-fapi-interaction-id', '');

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

      HttpClientResponse response = await request.close();
      String responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(responseBody);
        _consentId = jsonResponse['Data']['ConsentId'];
        print('Consent created successfully with ID: $_consentId');
      } else {
        throw Exception('Failed to create consent: $responseBody');
      }
    } catch (e) {
      print('Error creating consent: $e');
      rethrow;
    }
  }

  // Step 4: Create JWT for PAR Request
  Future<String> createJwt() async {
    final client = await _createHttpClientWithCert();
    var url =
        Uri.parse('https://rs1.lab.openbanking.sa/o3/v1.0/message-signature');

    try {
      HttpClientRequest request = await client.getUrl(url);
      request.headers.set('Content-Type', 'application/json');

      _codeVerifier = const Uuid().v4() + const Uuid().v4();
      var bytes = utf8.encode(_codeVerifier);
      var digest = sha256.convert(bytes);
      String codeChallenge = base64Url.encode(digest.bytes).replaceAll('=', '');

      double exp = DateTime.now()
              .add(const Duration(minutes: 5))
              .millisecondsSinceEpoch /
          1000;
      double nbf = DateTime.now().millisecondsSinceEpoch / 1000 - 10;

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

      String requestBody = jsonEncode(body);
      request.headers.set('Content-Length', utf8.encode(requestBody).length);
      request.write(requestBody);

      HttpClientResponse response = await request.close();
      String responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        print('JWT generated: $responseBody');
        return responseBody;
      } else {
        throw Exception('Failed to generate JWT: $responseBody');
      }
    } catch (e) {
      print('Error creating JWT: $e');
      rethrow;
    }
  }

  // Step 5: POST to PAR Endpoint and return requestUri
  Future<String> postToPAR(String jwt) async {
    final client = await _createHttpClientWithCert();
    var url = Uri.parse('https://as1.lab.openbanking.sa/par');

    try {
      HttpClientRequest request = await client.postUrl(url);
      request.headers.set('Authorization',
          'Basic ${base64Encode(utf8.encode("${Config.clientId}:${Config.clientSecret}"))}');
      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
      request.write('request=$jwt');

      HttpClientResponse response = await request.close();

      String responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(responseBody);
        String requestUri = jsonResponse['request_uri'];
        print('Request URI: $requestUri');
        return requestUri;
      } else {
        throw Exception('Failed to post to PAR: $responseBody');
      }
    } catch (e) {
      print('Error posting to PAR: $e');
      rethrow;
    }
  }

  // Step 6: Compute Authorization Code URL
  Future<String> computeAuthorizationCodeUrl() async {
    try {
      String jwt = await createJwt();
      String requestUri = await postToPAR(jwt);

      if (_consentId.isEmpty) {
        throw Exception(
            'Invalid ConsentId. Please complete Step 3 successfully.');
      }

      final client = await _createHttpClientWithCert();
      var url = Uri.parse(
          'https://rs1.lab.openbanking.sa/o3/v1.0/par-auth-code-url/$_consentId?response_type=code%20id_token&scope=openid%20accounts&request_uri=$requestUri');

      HttpClientRequest request = await client.getUrl(url);
      request.headers.set('Authorization',
          'Basic ${base64Encode(utf8.encode("${Config.clientId}:${Config.clientSecret}"))}');

      HttpClientResponse response = await request.close();

      String responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        print('Authorization Code URL: $responseBody');
        return responseBody;
      } else {
        throw Exception(
            'Failed to compute Authorization Code URL: $responseBody');
      }
    } catch (e) {
      print('Error computing authorization code URL: $e');
      rethrow;
    }
  }

  // Step 7: Exchange Authorization Code for Access Token
  Future<String> exchangeCodeForAccessToken(String authorizationCode) async {
    final client = await _createHttpClientWithCert();
    var url = Uri.parse('https://as1.lab.openbanking.sa/token');

    try {
      HttpClientRequest request = await client.postUrl(url);
      request.headers.set('Authorization',
          'Basic ${base64Encode(utf8.encode("${Config.clientId}:${Config.clientSecret}"))}');
      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');

      request.write(
          'grant_type=authorization_code&scope=accounts&code=$authorizationCode&redirect_uri=wafrah://auth-callback&code_verifier=$_codeVerifier');

      HttpClientResponse response = await request.close();
      String responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        return jsonResponse['access_token'];
      } else {
        throw Exception('Failed to exchange authorization code: $responseBody');
      }
    } catch (e) {
      print('Error exchanging authorization code: $e');
      rethrow;
    }
  }

  // Step 8: GET All Account Transactions
  Future<void> getAllAccountTransactions(String accessToken) async {
    final client = await _createHttpClientWithCert();
    var url = Uri.parse(
        'https://rs1.lab.openbanking.sa/open-banking/account-information/2022.11.01-final-errata2/accounts');

    try {
      HttpClientRequest request = await client.getUrl(url);
      request.headers.set('Authorization', 'Bearer $accessToken');
      request.headers.set('Content-Type', 'application/json');

      HttpClientResponse response = await request.close();
      String responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        List accounts = jsonResponse['Data']['Account'];

        if (accounts.isNotEmpty) {
          for (var account in accounts) {
            String accountId = account['AccountId'];
            print('Fetching transactions for Account ID: $accountId');
            await getAccountTransactions(accessToken, accountId);
          }
        } else {
          print('No accounts available for this user.');
        }
      } else {
        print('Failed to fetch accounts: $responseBody');
      }
    } catch (e) {
      print('Error fetching accounts: $e');
    }
  }

  // Step 9: GET Transactions for a Specific Account
  Future<List<Map<String, dynamic>>> getAccountTransactions(
      String accessToken, String accountId) async {
    final client = await _createHttpClientWithCert();
    var url = Uri.parse(
        'https://rs1.lab.openbanking.sa/open-banking/account-information/2022.11.01-final-errata2/accounts/$accountId/transactions');

    try {
      HttpClientRequest request = await client.getUrl(url);
      request.headers.set('Authorization', 'Bearer $accessToken');
      request.headers.set('Content-Type', 'application/json');

      HttpClientResponse response = await request.close();
      String responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        List<dynamic> transactions = jsonResponse['Data']['Transaction'];
        // Return the list of transactions, each item should be a map.
        return transactions.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Failed to fetch transactions for Account ID $accountId: $responseBody');
      }
    } catch (e) {
      print('Error fetching transactions for Account ID $accountId: $e');
      rethrow;
    }
  }

  Future<String> getAccountBalance(String accessToken, String accountId) async {
    final client = await _createHttpClientWithCert();
    var url = Uri.parse(
        'https://rs1.lab.openbanking.sa/open-banking/account-information/2022.11.01-final-errata2/accounts/$accountId/balances');

    try {
      HttpClientRequest request = await client.getUrl(url);
      request.headers.set('Authorization', 'Bearer $accessToken');
      request.headers.set('Content-Type', 'application/json');

      HttpClientResponse response = await request.close();
      String responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        // Extract the amount from the balance data structure
        var balanceInfo = jsonResponse['Data']['Balance'][0];
        String balance = balanceInfo['Amount']['Amount']
            .toString(); // Adjust if balance is within a nested map
        return balance;
      } else {
        throw Exception(
            'Failed to fetch balance for Account ID $accountId: $responseBody');
      }
    } catch (e) {
      print('Error fetching balance for Account ID $accountId: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getAccountDetails(String accessToken) async {
    final client = await _createHttpClientWithCert();
    var url = Uri.parse(
        'https://rs1.lab.openbanking.sa/open-banking/account-information/2022.11.01-final-errata2/accounts');

    try {
      HttpClientRequest request = await client.getUrl(url);
      request.headers.set('Authorization', 'Bearer $accessToken');
      request.headers.set('Content-Type', 'application/json');

      HttpClientResponse response = await request.close();
      String responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);

        // Check and access nested structure
        if (jsonResponse['Data'] != null &&
            jsonResponse['Data']['Account'] != null) {
          return jsonResponse['Data']['Account'];
        } else {
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

  // Dispose listener on app close
  void dispose() {
    _sub.cancel();
  }
}
