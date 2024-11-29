import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Save account and transaction data for a specific user by phoneNumber, to not be conflict with other users
  Future<void> saveAccountDataLocally(String phoneNumber, List<Map<String, dynamic>> accounts) async {
    String accountsJson = jsonEncode(accounts); // Convert to JSON string
    await _secureStorage.write(key: phoneNumber, value: accountsJson);
  }

  // Retrieve account and transaction data for a specific user identified by phoneNumber
  Future<List<Map<String, dynamic>>> loadAccountDataLocally(String phoneNumber) async {
    String? accountsJson = await _secureStorage.read(key: phoneNumber);
    if (accountsJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(accountsJson));
    }
    return [];
  }

  // Clear data for a specific user identified by phoneNumber, so if two users are using same device
  // it doesn't display them all 
  Future<void> clearUserData(String phoneNumber) async {
    await _secureStorage.delete(key: 'user_accounts_$phoneNumber');
  }

  // Clear all stored data (used when logging out)
  Future<void> clearAllUserData() async {
    await _secureStorage.deleteAll();
  }

  // Save access token for a specific user identified by phoneNumber
  Future<void> saveAccessToken(String phoneNumber, String token) async {
    await _secureStorage.write(key: 'access_token_$phoneNumber', value: token);
  }

  // Retrieve access token for a specific user identified by phoneNumber
  Future<String?> getAccessToken(String phoneNumber) async {
    return await _secureStorage.read(key: 'access_token_$phoneNumber');
  }
}
