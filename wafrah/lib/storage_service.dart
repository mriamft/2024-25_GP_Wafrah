import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Save account and transaction data
  Future<void> saveAccountDataLocally(List<Map<String, dynamic>> accounts) async {
    String accountsJson = jsonEncode(accounts); // Convert to JSON string
    await _secureStorage.write(key: 'user_accounts', value: accountsJson);
  }

  // Retrieve account and transaction data
  Future<List<Map<String, dynamic>>> loadAccountDataLocally() async {
    String? accountsJson = await _secureStorage.read(key: 'user_accounts');
    if (accountsJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(accountsJson));
    }
    return [];
  }

  // Clear all user data
  Future<void> clearUserData() async {
    await _secureStorage.deleteAll(); // Clears all stored data
  }

  // Save and retrieve tokens
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: 'access_token', value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }
}
