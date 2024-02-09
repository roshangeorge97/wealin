import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;
import 'dart:convert';

FirebaseAuth auth = FirebaseAuth.instance;

class Status {
  final String processId;
  final String status;
  final Result? result; // Make result nullable

  const Status({
    required this.processId,
    required this.status,
    this.result, // Make result nullable
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      processId: json['process_id'] as String,
      status: json['status'] as String,
      result: json['result'] != null
          ? Result.fromJson(json['result'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Result {
  final String? text; // Make text nullable

  const Result({
    this.text, // Make text nullable
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      text: json['text'] as String?,
    );
  }
}

class Album {
  final String message;
  final String process_id;
  final String status_url;

  const Album({
    required this.message,
    required this.process_id,
    required this.status_url,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      message: json['message'] as String,
      process_id: json['process_id'] as String,
      status_url: json['status_url'] as String,
    );
  }
}

class ChatPage extends StatefulWidget {
  final firebase_auth.User? user = FirebaseAuth.instance.currentUser;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _inputController = TextEditingController();
  List<String> chatMessages = [];
  String? displayName;
  String? phoneNumber;
  int _bottomNavigationBarIndex = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatBot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(chatMessages[index]),
                );
              },
            ),
          ),
          // Input field for user messages
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_inputController.text);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      chatMessages.add("You: $message");
    });

    try {
      final String result = await _callApi(message);
      // Check if the result is "IN_PROGRESS"
      if (result == "IN_PROGRESS") {
        setState(() {
          chatMessages.add(
              "Bot: Processing..."); // Display a message indicating processing
        });
      } else {
        // Display the result when it's completed
        setState(() {
          chatMessages.add("Bot: $result");
        });
      }
    } catch (e) {
      print("Error calling API: $e");

      if (e is http.ClientException) {
        setState(() {
          chatMessages.add(
              "Bot: Network error. Please check your internet connection.");
        });
      } else {
        setState(() {
          chatMessages.add(
              "Bot: Error in processing your request. Please try again later.");
        });
      }
    }

    // Clear the input field after sending the message
    _inputController.clear();
  }

  Future<String> _callApi(String message) async {
    final String apiUrl =
        "https://api.monsterapi.ai/v1/generate/llama2-7b-chat";

    final Map<String, dynamic> payload = {
      "beam_size": 1,
      "max_length": 256,
      "repetition_penalty": 1.2,
      "temp": 0.98,
      "top_k": 40,
      "top_p": 0.9,
      "prompt": message,
    };

    final Map<String, String> headers = {
      "accept": "application/json",
      "content-type": "application/json",
      "authorization":
          "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6IjA3ZGQyYTU0YTBkMWM3MjFkM2RkZGI4NDg4ZjEwZjk2IiwiY3JlYXRlZF9hdCI6IjIwMjQtMDItMDNUMTM6NDE6MzguMDYxMzM3In0.oBHmuo0cBr8xzRxxqPveBZY-Nzdxdv_ZvFnBV9bV1Tk",
    };

    final http.Response response = await http.post(Uri.parse(apiUrl),
        body: jsonEncode(payload), headers: headers);

    print(response.body);

    final Album album =
        Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    final String processId = album.process_id;
    print(processId);
    print("=================================================================");
    return _checkStatus(processId, headers); // Return the Future<String>
  }

  Future<String> _checkStatus(
      String processId, Map<String, String> headers) async {
    final String statusUrl = "https://api.monsterapi.ai/v1/status/$processId";
    final http.Response statusResponse =
        await http.get(Uri.parse(statusUrl), headers: headers);

    print(statusResponse.body);

    final Status statusData = Status.fromJson(
        jsonDecode(statusResponse.body) as Map<String, dynamic>);
    final String status = statusData.status;
    if (status == "COMPLETED") {
      if (statusData.result != null && statusData.result!.text != null) {
        return statusData.result!.text!;
      } else {
        return "Result or text is null"; // Handle the case where result or text is null
      }
    } else {
      // Delay and then recursively call _checkStatus
      await Future.delayed(Duration(seconds: 5));
      return await _checkStatus(processId, headers);
    }
  }
}
