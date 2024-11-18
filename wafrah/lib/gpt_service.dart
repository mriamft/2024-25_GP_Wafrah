import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wafrah/config.dart';

class GPTService {
  Future<String> categorizeTransaction(String transactionInfo) async {
    const String url = 'https://api.openai.com/v1/chat/completions';
    const String categories =
        'التعليم، الترفيه، الحكومة، البقالة، الصحة، القروض، الاستثمار، الإيجار، المطاعم، تسوق، الراتب والإيرادات، التحويلات، النقل، السفر، أخرى';

    // Arabic prompt with categories
    final messages = [
      {
        "role": "system",
        "content":
            "You are a helpful assistant that categorizes transactions into predefined categories in Arabic."
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
        return data['choices'][0]['message']['content'].trim();
      } else {
        throw Exception('Failed to fetch category: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, double>> aggregateTransactions(
      List<Map<String, dynamic>> transactions) async {
    final Map<String, double> categoryTotals = {};

    for (var transaction in transactions) {
      final String transactionInfo = transaction['info'] ??
          ''; // Replace 'info' with the actual field name
      final double amount = transaction['amount'] ??
          0.0; // Replace 'amount' with the actual field name

      if (transactionInfo.isNotEmpty) {
        final String category = await categorizeTransaction(transactionInfo);

        // Aggregate the amounts by category
        if (categoryTotals.containsKey(category)) {
          categoryTotals[category] = categoryTotals[category]! + amount;
        } else {
          categoryTotals[category] = amount;
        }
      }
    }

    return categoryTotals;
  }
}
