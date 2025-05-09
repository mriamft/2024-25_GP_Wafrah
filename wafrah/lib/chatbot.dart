import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wafrah/session_manager.dart';

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
  List<Map<String, dynamic>> _messages = [];
  bool isTyping = false;
  Color _arrowColor = const Color(0xFF3D3D3D);

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('chat_messages');
    if (stored != null) {
      final List decoded = jsonDecode(stored);
      setState(() {
        _messages = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } else {
      setState(() {
        _messages = [
          {
            "sender": "bot",
            "text":
                "السلام عليكم ${widget.userName.split(' ').first} 👋\n معك *وفرة*، مساعدك الشخصي في إدارة أمورك المالية 💰\n\nاسألني عن رصيدك، مصاريفك، أو تفاصيل معاملاتك بكل سهولة!"
          }
        ];
      });
    }
  }

  Future<void> _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_messages', jsonEncode(_messages));
  }

  Future<void> _clearMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_messages');
    setState(() {
      _messages.clear();
    });
  }

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
      isTyping = true;
    });
    _saveMessages();

    final payload = {
      "sender": widget.phoneNumber,
      "message": message,
      "metadata": {"accounts": widget.accounts}
    };

    final response = await http.post(
      Uri.parse('http://10.0.2.2:5005/webhooks/rest/webhook'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    setState(() => isTyping = false);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      for (var item in data) {
        if (item.containsKey("text")) {
          print("🔵 RASA ردت: ${item["text"]}");
          setState(() {
            _messages.add({"sender": "bot", "text": item["text"]});
          });
          _saveMessages();
        }
      }
    } else {
      setState(() {
        _messages.add({
          "sender": "bot",
          "text": "عذرًا، لم أتمكن من الاتصال بالخادم. حاول لاحقًا."
        });
      });
      _saveMessages();
    }
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isUser = message["sender"] == "user";
    if (isUser) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFD7D7D7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message["text"],
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF3D3D3D),
              fontFamily: 'GE-SS-Two-Bold',
              fontSize: 16,
            ),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.rtl,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Image.asset(
                'assets/images/responseIcon.png',
                width: 30,
                height: 30,
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 250),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message["text"],
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.black87,
                  fontFamily: 'GE-SS-Two-Bold',
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Image.asset(
              'assets/images/responseIcon.png',
              width: 30,
              height: 30,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const AnimatedDots(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3CBA8A), Color(0xFF123427)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              left: 0,
              right: 0,
              child: Container(
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
            Positioned(
              top: 60,
              right: 15,
              child: GestureDetector(
                onTap: _onArrowTap,
                child:
                    Icon(Icons.arrow_forward_ios, color: _arrowColor, size: 28),
              ),
            ),
            // داخل Stack children
            if (_messages.isNotEmpty)
              Positioned(
                top: 133,
                left: 15,
                child: IconButton(
                  icon: const Icon(Icons.delete,
                      color: Color(0xFF3D3D3D), size: 30),
                  onPressed: _clearMessages,
                ),
              ),

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
            Positioned.fill(
              top: 170,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      itemCount: _messages.length + (isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (isTyping && index == 0) return _buildTypingBubble();
                        final actualIndex = isTyping ? index - 1 : index;
                        return _buildMessage(
                            _messages.reversed.toList()[actualIndex]);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFFD7D7D7)),
                          onPressed: () {
                            SessionManager.resetTimer();
                            _sendMessage(_controller.text);
                          },
                        ),

                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            textAlign: TextAlign.right,
                            onChanged: (_) {
                              SessionManager.resetTimer();    
                            },
                            decoration: InputDecoration(
                              hintText: "...اكتب رسالتك",
                              hintStyle: const TextStyle(fontFamily: 'GE-SS-Two-Bold'),
                              filled: true,
                              fillColor: const Color(0xFFD7D7D7),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedDots extends StatefulWidget {
  const AnimatedDots({super.key});
  @override
  _AnimatedDotsState createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotsAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..repeat();
    _dotsAnimation = StepTween(begin: 1, end: 3).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotsAnimation,
      builder: (context, child) {
        return Text(
          "." * _dotsAnimation.value,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontFamily: 'GE-SS-Two-Bold',
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
