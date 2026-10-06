import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:translator_project/core/styles/app_colors.dart';
import 'package:translator_project/screens/history_page.dart';
import 'package:translator_project/screens/home_page.dart';
import 'dart:async';

import '../core/styles/app_text_styles.dart';
import '../services/pythonService.dart';
import '../services/serviceRoutes.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  void _sendMessage() async{
    final String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _messages.add({
          "sender": "user",
          "message": message,
          "timestamp": DateTime.now(),
          "type": "text",
        });
        _isTyping = true;
      });
      _messageController.clear();

      PythonService pService = PythonService();



      await pService.post(ChatBot.CHAT, {"query": message})
          .then((rsp) async {
        debugPrint("Rsp CHAT: ${rsp.toString()}");
        Map<String, dynamic> responseJSON = json.decode(json.encode(rsp));
        if (responseJSON['success']) {
          String botMessage = responseJSON["data"].toString();
          await Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _messages.add({
                "sender": "bot",
                "message": botMessage,
                "timestamp": DateTime.now(),
                "type": "text",
              });
              _isTyping = false;
            });
          });
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Unable to interact with chatbot , check backend")),
          );
        }
      });
      // Simulate bot typing and responding after a delay

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Pen2Pixel",
          style: AppTextStyles.textStyleSFProText.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        backgroundColor: AppColors.colorWhite,
        actions: [
          Row(
            children: [
              Icon(Icons.home),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => HomePage(),
                    ),
                  );
                },
                child: Text(
                  "Home",
                  style: AppTextStyles.textStyleSFProText,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.history),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => HistoryPage(),
                    ),
                  );
                },
                child: Text(
                  "History",
                  style: AppTextStyles.textStyleSFProText,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.account_circle_outlined),

              SizedBox(width: 30),
            ],
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_messages.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smart_toy,
                        color: Colors.blue,
                        size: 80,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Welcome to Notes Summariser ChatBot!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "I'm here to assist you with translations and more.",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Type a message to get started!",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == _messages.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              const CircleAvatar(child: Icon(Icons.smart_toy)),
                              const SizedBox(width: 10),
                              Text(
                                "Bot is typing...",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final message = _messages[index];
                    final isUserMessage = message["sender"] == "user";
                    final timestamp =
                        DateFormat('hh:mm a').format(message["timestamp"]);

                    return Align(
                      alignment: isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isUserMessage
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isUserMessage
                                  ? Colors.blue[100]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message["message"],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Text(
                            timestamp,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (_isTyping) const LinearProgressIndicator(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type your message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
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
