import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

// Save the plan data to secure storage
Future<void> savePlanToSecureStorage(Map<String, dynamic> planData) async {
  try {
    String planJson = jsonEncode(planData);
    await secureStorage.write(key: 'savings_plan', value: planJson);
    print("Plan saved successfully.");
  } catch (e) {
    print("Error saving plan to secure storage: $e");
  }
}

// Load the plan from secure storage
Future<Map<String, dynamic>?> loadPlanFromSecureStorage() async {
  try {
    String? planJson = await secureStorage.read(key: 'savings_plan');

    if (planJson != null) {
      // Safely decode the JSON to Map<String, dynamic>
      var decodedData = jsonDecode(planJson);
      if (decodedData is Map<String, dynamic>) {
        return decodedData; // Return the decoded map if valid
      } else {
        print("Error: The data format is not as expected.");
      }
    }
  } catch (e) {
    print("Error loading plan from secure storage: $e");
  }
  return null; // Return null if no valid data is found
}
