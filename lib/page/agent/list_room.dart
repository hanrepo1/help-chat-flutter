import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:help_chat/models/chat_room.dart';
import 'package:help_chat/page/agent/agent_chat_page.dart';
import 'package:help_chat/services/chat_service.dart';
import 'package:intl/intl.dart';

class ListRoom extends StatefulWidget {
  const ListRoom({super.key});

  @override
  State<ListRoom> createState() => _ListRoomState();
}

class _ListRoomState extends State<ListRoom> {
  final ChatService chatService = ChatService();
  bool isLoading = false;
  late List<ChatRoom> chatRoom = [];

  @override
  void initState() {
    super.initState();
    log("init: ${chatRoom.length.toString()}");
    getData(); // Fetch data when the widget is initialized
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      chatRoom = (await chatService.getRooms())!;
      log("get Data: ${chatRoom.length.toString()}"); // Fetch chat rooms
    } catch (e) {
      // Handle any errors here
      log("Error fetching chat rooms: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatTime(int epoch) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epoch);

    // Format DateTime to a readable string
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);

    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LIST ROOM",
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading ? const Center(child: CircularProgressIndicator()) : _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    log("build: ${chatRoom.length.toString()}");
    return Padding(
      padding: const EdgeInsets.all(
        10.0,
      ),
      child: Column(
        children: [
          _chatRoomList(),
        ],
      ),
    );
  }

  Widget _chatRoomList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: getData,
        child: ListView.builder(
          itemCount: chatRoom.length,
          itemBuilder: (context, index) {
            ChatRoom listRoom = chatRoom[index];
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AgentChatPage(
                        chatRoom: listRoom,
                      );
                    },
                  ),
                );
              },
              contentPadding: const EdgeInsets.only(top: 20.0),
              isThreeLine: true,
              subtitle: Text(
                listRoom.content!,
              ),
              leading: const Icon(FontAwesomeIcons.fileCircleQuestion),
              title: Text(
                listRoom.userName!,
              ),
              trailing: Text(formatTime(listRoom.dateCreated!)),
            );
          },
        ),
      ),
    );
  }
}
