import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wafrah/config.dart';

class GPTService {
  // Predefined categories
  final List<String> predefinedCategories = [
    "التعليم",
    "الترفيه",
    "المدفوعات الحكومية",
    "البقالة",
    "الصحة",
    "القروض",
    "الاستثمار",
    "الإيجار",
    "المطاعم",
    "تسوق",
    "الراتب والإيرادات",
    "التحويلات",
    "النقل",
    "السفر",
    "أخرى"
  ];

  /// Method to categorize a transaction
  Future<String> categorizeTransaction(String transactionInfo) async {
    const String url = 'https://api.openai.com/v1/chat/completions';
    const String categories =
        'التعليم، الترفيه، المدفوعات الحكومية، البقالة، الصحة، القروض، الاستثمار، الإيجار، المطاعم، تسوق، الراتب والإيرادات، التحويلات، النقل، السفر، أخرى';

    final messages = [
      {
        "role": "system",
        "content":
            "You are a helpful assistant that categorizes transactions into predefined categories in Arabic. Always respond with one of the exact categories provided."
      },
      {
        "role": "user",
        "content": '''
صنف المعاملة التالية إلى إحدى الفئات التالية:
الفئات: $categories.

معلومات المعاملة: $transactionInfo

الفئة:
'''
      }
    ];

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer ${Config.apiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': messages,
          'max_tokens': 10,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        final String rawCategory =
            data['choices'][0]['message']['content'].trim();

        // Normalize the category to handle slight variations
        return _findClosestCategory(rawCategory);
      } else {
        throw Exception('Failed to fetch category: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Method to find the closest category using Levenshtein distance
  String _findClosestCategory(String rawCategory) {
    int _levenshteinDistance(String a, String b) {
      if (a == b) return 0;
      if (a.isEmpty) return b.length;
      if (b.isEmpty) return a.length;

      List<List<int>> matrix = List.generate(
        a.length + 1,
        (_) => List.filled(b.length + 1, 0),
      );

      for (int i = 0; i <= a.length; i++) {
        matrix[i][0] = i;
      }
      for (int j = 0; j <= b.length; j++) {
        matrix[0][j] = j;
      }

      for (int i = 1; i <= a.length; i++) {
        for (int j = 1; j <= b.length; j++) {
          int cost = a[i - 1] == b[j - 1] ? 0 : 1;
          matrix[i][j] = [
            matrix[i - 1][j] + 1, // Deletion
            matrix[i][j - 1] + 1, // Insertion
            matrix[i - 1][j - 1] + cost // Substitution
          ].reduce((a, b) => a < b ? a : b);
        }
      }

      return matrix[a.length][b.length];
    }

    // Allow small differences
    int threshold = 2;

    String? closestCategory;

    for (String category in predefinedCategories) {
      int distance = _levenshteinDistance(rawCategory, category);
      if (distance <= threshold) {
        closestCategory = category;
        break; // Stop at the first close match
      }
    }

    return closestCategory ?? "أخرى"; // Default to "أخرى" if no match
  }
}