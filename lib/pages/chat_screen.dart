import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController chatCtrl = TextEditingController();
  final List<Map<String, String>> messages = [];

  void sendMessage() {
    final text = chatCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "message": text});
      // Simple FAQ responses
      if (text.toLowerCase().contains("payment")) {
        messages.add({"sender": "bot", "message": "Payment is done via online method, cash, or wallet."});
      } else if (text.toLowerCase().contains("booking")) {
        messages.add({"sender": "bot", "message": "You can book a service by selecting a provider and confirming the date/time."});
      } else if (text.toLowerCase().contains("plumber")) {
        messages.add({"sender": "bot", "message": "You can find plumbers under 'Plumbing' service on the home page."});
      } else {
        messages.add({"sender": "bot", "message": "Sorry, I didn't understand. Please ask another question."});
      }
      chatCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chatbot / FAQ"), backgroundColor: const Color(0xffc5e3f4)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['sender'] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: isUser ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      msg['message']!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatCtrl,
                    decoration: const InputDecoration(
                      hintText: "Ask a question...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(onPressed: sendMessage, icon: const Icon(Icons.send))
              ],
            ),
          )
        ],
      ),
    );
  }
}
