import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:help_chat/components/my_text_field.dart';
import 'package:help_chat/models/chat_content.dart';
import 'package:help_chat/models/chat_room.dart';
import 'package:help_chat/services/chat_service.dart';
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatPage extends StatefulWidget {
  final ChatRoom? chatRoom;

  const ChatPage({super.key, this.chatRoom});

  @override
  State<ChatPage> createState() => _ChatPageStates();
}

class _ChatPageStates extends State<ChatPage> {
  final ChatService chatService = ChatService();
  final String WEBSOCKET_PATH = "ws://192.168.18.112:8080/chat/websocket";
  late StompClient stompClient;

  final TextEditingController _controller = TextEditingController();
  late ChatRoom chatRoom;
  late List<ChatContent> chatContent = [];
  bool firstMessageSent = false;

  @override
  void initState() {
    super.initState();
    chatRoom = widget.chatRoom!;
    log('initState: ${jsonEncode(chatRoom.toJson())}');

    stompClient = StompClient(
      config: StompConfig(
        url: WEBSOCKET_PATH,
        beforeConnect: () async {
          // Handle loading state before connection
          log('Connecting to WebSocket...');
          await getData();
          return Future.value();
        },
        onConnect: (StompFrame frame) {
          log("onConnect: ${frame.body}"); // Log the frame body
          stompClient.subscribe(
            destination: '/topic/${chatRoom.roomId}',
            callback: (StompFrame frame) {
              _handleIncomingMessage(frame.body);
              log("callback: ${frame.toString()}");
            },
          );
        },
        onWebSocketError: (dynamic error) {
          // Handle WebSocket errors
          _showErrorDialog(error);
        },
        onDisconnect: (StompFrame frame) {
          // Handle disconnection
          log('Disconnected from WebSocket');
        },
        onStompError: (StompFrame frame) {
          // Handle STOMP protocol errors
          _showErrorDialog(frame.body.toString());
        },
      ),
    );
    stompClient.activate();
  }

  @override
  void dispose() {
    stompClient.deactivate(); // Close the channel when disposing
    _controller.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    try {
      final fetchedChatContent =
          await chatService.getChatContent(chatRoom.roomId!);
      if (fetchedChatContent != null) {
        setState(() {
          chatContent =
              fetchedChatContent; // Update the state with new chat content
        });
      }
    } catch (e) {
      // Handle any errors here
      log("Error fetching chat rooms: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connection Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                // Navigator.of(context).pop();
                Navigator.popAndPushNamed(context, "/home");
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handleIncomingMessage(String? messageBody) async {
    log("_handleIncomingMessage: $messageBody");
    if (messageBody != null) {
      final messageData = ChatContent.fromJson(jsonDecode(messageBody));
      chatContent.add(messageData);

      await getData();
    }
  }

  void sendMessage() async {
    log("sendMessage called");
    DateTime epoch = DateTime.now();
    chatRoom.content = chatRoom.content == null || chatRoom.content!.isEmpty
        ? _controller.text
        : chatRoom.content;
    final message = ChatContent(
      roomId: chatRoom.roomId!,
      userId: chatRoom.userId,
      userName: chatRoom.userName,
      content: _controller.text,
      timeSent: epoch.millisecondsSinceEpoch,
      isAgent: false,
    );
    stompClient.send(
      destination: '/app/send/${message.roomId}',
      body: jsonEncode(message.toJson()),
    );
    log("sendMessage: ${jsonEncode(message.toJson())}");
    chatRoom.content = "";
    _controller.clear();

    await getData();
  }

  String formatTime(int epoch) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epoch);

    // Format DateTime to a readable string
    String formattedDate = DateFormat('yy/MM/dd – kk:mm').format(dateTime);

    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Page'),
        centerTitle: true,
      ),
      body: Center(
        child: _buildChatUI(),
      ),
    );
  }

  Widget _buildChatUI() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          _chatHistory(),
          _textInput(),
        ],
      ),
    );
  }

  Widget _chatHistory() {
    return Expanded(
      child: ListView.builder(
        itemCount: chatContent.length,
        itemBuilder: (context, index) {
          log("isAgent : ${chatContent[index].isAgent}");
          log("nameUser : ${chatContent[index].userName}");
          return ListTile(
            title: Text(
              chatContent[index].isAgent!
                  ? chatContent[index].agentName.toString()
                  : chatContent[index].userName.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(chatContent[index].content ?? ""),
            trailing: Text(formatTime(chatContent[index].timeSent)),
          );
        },
      ),
    );
  }

  Widget _textInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: _controller,
              keyboardType: TextInputType.text,
              obscureText: false,
              maxLength: 255,
              maxLines: 1,
              hintText: "Send a Message",
              suffixIcon: IconButton(
                onPressed: () {
                  log("onPressed: ${_controller.text.isNotEmpty}");
                  if (_controller.text.isNotEmpty) {
                    sendMessage();
                  }
                },
                icon: const Icon(Icons.send),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
