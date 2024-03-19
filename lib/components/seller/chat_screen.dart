import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:agro/config.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  bool isTurboMode = false; // Default mode is normal

  void _sendMessage() async {
    final messageText = _controller.text.trim();
    if (messageText.isNotEmpty) {
      setState(() {
        messages.add({"text": messageText, "isUser": true});
        _controller.clear();
      });
      await Future.delayed(const Duration(milliseconds: 1000)); // Allow list to rebuild
      _scrollToBottom();

      // Display "Processing" message
      setState(() {
        messages.add({"text": "Processing...", "isUser": false});
      });

      // Fetch response message
      final responseMessage = await _fetchResponse(messageText);

      // Replace "Processing" message with fetched message
      setState(() {
        final processingMessageIndex = messages.indexWhere((message) => message["text"] == "Processing...");
        if (processingMessageIndex != -1) {
          messages.removeAt(processingMessageIndex);
        }
        messages.add({"text": responseMessage, "isUser": false});
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<String> _fetchResponse(String message) async {
    final mode = isTurboMode ? "turbo" : "normal";
    if(mode=="turbo"){
      var response = await http.post(Uri.parse(chat),
          body: json.encode({"message": message}),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          _scrollToBottom();
        });
        return data["message"];
      } else {
        return "Error: could not fetch response";
      }

    }else if(mode=="normal"){
      var response = await http.post(
        Uri.parse(chat_local),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'action':'ask','question': message}),
      );
      if (response.statusCode == 200) {

        var data = json.decode(response.body);
        print(data);
        setState(() {
          _scrollToBottom();
        });
        return data["message"];
      } else {
        return "Error: could not fetch response";
      }
    }
    return "error";

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Help'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(isTurboMode ? 'Turbo Mode: On' : 'Turbo Mode: Off'),
                const SizedBox(width: 10),
                Switch(
                  value: isTurboMode,
                  onChanged: (value) {
                    setState(() {
                      isTurboMode = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Center(
                child: Text(
                  "Hello Sir, How can I help you today?",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final bool isUser = message["isUser"];
                  return Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser)
                        const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.man),
                        ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue[200] : Colors.green[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            message["text"],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      if (isUser)
                        const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text('U'),
                        ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Ask anything...'),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
