import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Chatbot extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final List<Map<String, dynamic>> accounts;

  const Chatbot({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.accounts = const [],
  });

  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  Color _arrowColor = const Color(0xFF3D3D3D);

  void _onArrowTap() {
    setState(() => _arrowColor = Colors.grey);
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => _arrowColor = const Color(0xFF3D3D3D));
      Navigator.pop(context);
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": message});
      _controller.clear();
    });

    final response = await http.post(
      Uri.parse('http://localhost:5005/webhooks/rest/webhook'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "sender": widget.phoneNumber,
        "message": message,
      }),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      for (var item in data) {
        if (item.containsKey("text")) {
          setState(() {
            _messages.add({"sender": "bot", "text": item["text"]});
          });
        }
      }
    } else {
      setState(() {
        _messages.add({
          "sender": "bot",
          "text": "عذرًا، لم أتمكن من الاتصال بالخادم. حاول لاحقًا."
        });
      });
    }
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isUser = message["sender"] == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF2C8C68) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message["text"],
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontFamily: 'GE-SS-Two-Bold',
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C8C68),
      body: Stack(
        children: [
          // White background container
          Positioned(
            top: -50,
            left: 0,
            right: 0,
            child: Container(
              width: 393,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // Back arrow
          Positioned(
            top: 60,
            right: 15,
            child: GestureDetector(
              onTap: _onArrowTap,
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
            left: 170,
            child: Text(
              'وفرة',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),
          const Positioned(
            top: 88,
            left: 80,
            child: Text(
              'المساعد الذكي الخاص بك',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),

          // Chat area
          Positioned.fill(
            top: 170,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) =>
                        _buildMessage(_messages.reversed.toList()[index]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "اكتب رسالتك...",
                            hintStyle:
                                const TextStyle(fontFamily: 'GE-SS-Two-Bold'),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () => _sendMessage(_controller.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
