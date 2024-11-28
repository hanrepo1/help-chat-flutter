import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:help_chat/components/my_text_field.dart';
import 'package:help_chat/models/chat_room.dart';
import 'package:help_chat/page/user/chat_page.dart';
import 'package:help_chat/services/chat_service.dart';

class InquiryPage extends StatefulWidget {
  final String? userId;
  final String? username;

  const InquiryPage({super.key, this.username, this.userId});
  @override
  State<InquiryPage> createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage> {
  final ChatService chatService = ChatService();
  final nameController = TextEditingController();
  final inquiryController = TextEditingController();
  late String? userId = "";
  late bool? isUser;

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.username == null || widget.username!.isEmpty) {
        isUser = false;
      } else {
        nameController.text = widget.username!;
        userId = widget.userId;
        isUser = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white60,
        title: const Text(
          "INQUIRY",
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            isUser == null ? const Center(child: CircularProgressIndicator(),) : _buildUI(),
          ],
        ),
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Form(
        // key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: MyTextField(
                    enable: !isUser!,
                    controller: nameController,
                    hintText: 'Name',
                    obscureText: false,
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                    prefixIcon: const Icon(CupertinoIcons.person),
                    // errorMsg: "Input a name",
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Please fill in this field';
                      } else if (!RegExp(r'^[\w-\.]+@([\w-]+.)+[\w-]{2,4}$')
                          .hasMatch(val)) {
                        return 'Please enter a valid name';
                      }
                      return null;
                    })),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: MyTextField(
                controller: inquiryController,
                hintText: 'Inquiry Problem',
                obscureText: false,
                keyboardType: TextInputType.multiline,
                prefixIcon: const Icon(FontAwesomeIcons.noteSticky),
                maxLines: 5,
                maxLength: 255,
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Please fill in this field';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: TextButton(
                onPressed: () async {
                  // Call the startChat method to create a chat room
                  ChatRoom? chatRoom = await chatService.startChat(
                    userId,
                    nameController.text,
                    inquiryController.text,
                  );
                  if (chatRoom != null) {
                    // If roomId is successfully retrieved, navigate to ChatPage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ChatPage(
                            chatRoom: chatRoom, // Pass the roomId to ChatPage
                          );
                        },
                      ),
                    );
                  } else {
                    // Handle the case where the chat room could not be created
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Failed to create chat room.")),
                    );
                  }
                },
                style: TextButton.styleFrom(
                    elevation: 3.0,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60))),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  child: Text(
                    'Continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
