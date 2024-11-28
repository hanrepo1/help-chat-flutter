import 'dart:convert';
import 'dart:developer';
import 'package:help_chat/models/quick_text.dart';
import 'package:help_chat/services/quick_text_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:help_chat/components/my_text_field.dart';
import 'package:help_chat/models/chat_content.dart';
import 'package:help_chat/models/chat_room.dart';
import 'package:help_chat/services/chat_service.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class AgentChatPage extends StatefulWidget {
  final ChatRoom? chatRoom;

  const AgentChatPage({super.key, this.chatRoom});

  @override
  State<AgentChatPage> createState() => _AgentChatPageStates();
}

class _AgentChatPageStates extends State<AgentChatPage> {
  final ChatService chatService = ChatService();
  final QuickTextService quickTextService = QuickTextService();
  final String WEBSOCKET_PATH = "ws://192.168.18.112:8080/chat/websocket";
  late StompClient stompClient;

  final TextEditingController _controller = TextEditingController();
  late ChatRoom chatRoom;
  late List<ChatContent> chatContent = [];
  late List<QuickText> listQuickText= [];
  bool isLoading = false;
  bool quickText = false;

  DateTime epoch = DateTime.now();

  @override
  void initState() {
    super.initState();
    chatRoom = widget.chatRoom!;
    getData();
    getQuickText();

    log('initState: ${chatRoom.toJson()}');

    stompClient = StompClient(
      config: StompConfig(
        url: WEBSOCKET_PATH,
        // beforeConnect: () async {
        //   // Handle loading state before connection
        //   log('Connecting to WebSocket...');
        //   await getData();
        //   return Future.value();
        // },
        onConnect: (StompFrame frame) {
          log("onConnect headers: ${frame.headers}"); // Log the frame body
          stompClient.subscribe(
            destination: "/topic/${chatRoom.roomId}",
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
    setState(() {
      isLoading = true;
    });
    log("fetching chat rooms...");
    try {
      final fetchedChatContent =
          await chatService.getChatContent(chatRoom.roomId!);
      log("Fetched chat content: ${fetchedChatContent}");
      if (fetchedChatContent != null && fetchedChatContent.isNotEmpty) {
        setState(() {
          chatContent =
              fetchedChatContent; // Update the state with new chat content
        });
      } else {
        log("No chat content fetched or fetched content is empty.");
      }
    } catch (e) {
      log("Error fetching chat rooms: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getQuickText() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchQuickText = await quickTextService.getQuickText();
      if (fetchQuickText != null && fetchQuickText.isNotEmpty) {
        setState(() {
          listQuickText = fetchQuickText;
        });
      } else {
        log("No quick text fetched or fetched content is empty.");
      }
    } catch (e) {
      log("Error fetching quick text: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
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
                Navigator.pushReplacementNamed(context, "/home");
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
      setState(() {
        chatContent.add(messageData); // Add the new message
      });
    }
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty && text[0] == '/') {
      setState(() {
        quickText = true;
      });
    } else {
      setState(() {
        quickText = false;
      });
    }
  }

  void sendMessage() async {
    log("sendMessage called");

    final message = ChatContent(
        roomId: chatRoom.roomId!,
        userId: chatRoom.userId,
        userName: chatRoom.userName,
        agentId: chatRoom.agentId ?? 1,
        agentName: "agentName",
        content: _controller.text,
        timeSent: epoch.millisecondsSinceEpoch,
        isAgent: true);
    stompClient.send(
      destination: '/app/send/${message.roomId}',
      body: jsonEncode(message.toJson()),
    );
    log("sendMessage: ${jsonEncode(message.toJson())}");
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
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _buildChatUI(),
      ),
    );
  }

  Widget _buildChatUI() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          _chatHistory(),
          if(quickText) _listQuickText(),
          _textInput(),
        ],
      ),
    );
  }

  Widget _chatHistory() {
    log("history : ${chatContent.length}");
    return Expanded(
      child: ListView.builder(
        itemCount: chatContent.length,
        itemBuilder: (context, index) {
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

  Widget _listQuickText() {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: listQuickText.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(listQuickText[index].message.toString()),
            onTap: () {
              _controller.text = listQuickText[index].message.toString();
              _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length)); // Move cursor to the end
              setState(() {
                quickText = false; // Hide suggestions after selection
              });
            },
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
              hintText: "Send a Message",
              maxLength: 255,
              maxLines: 1,
              onChanged: (val) {
                _onTextChanged(val!);
              },
              suffixIcon: IconButton(
                onPressed: () {
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
