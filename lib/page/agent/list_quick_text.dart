import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:help_chat/components/my_text_field.dart';
import 'package:help_chat/dto/quick_text_DTO.dart';
import 'package:help_chat/models/quick_text.dart';
import 'package:help_chat/services/quick_text_service.dart';
import 'package:intl/intl.dart';

class ListQuickText extends StatefulWidget {
  const ListQuickText({super.key});

  @override
  State<ListQuickText> createState() => _ListQuickTextState();
}

class _ListQuickTextState extends State<ListQuickText> {
  final QuickTextService quickTextService = QuickTextService();
  final keywordController = TextEditingController();
  final messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<QuickText> listQuickText = [];

  bool isLoading = false;
  bool isEdit = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    getData(); // Fetch data when the widget is initialized
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      listQuickText = (await quickTextService.getQuickText())!;
      log("get Data QT: ${listQuickText.length.toString()}"); // Fetch chat rooms
    } catch (e) {
      // Handle any errors here
      log("Error fetching quick text: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _displayDialog(String? message) {
    // String title = message == null ? "Failed" : "Success";
    String content = message ?? "Success";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop();
                // Navigate to home and remove the login route from the stack
                getData();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _textBottomSheet(int id, String addKeyword, String addMessage) {
    if (addKeyword.isNotEmpty && addMessage.isNotEmpty) {
      keywordController.text = addKeyword;
      messageController.text = addMessage;
      setState(() {
        isEdit = true;
      });
    } else {
      setState(() {
        isEdit = false;
      });
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: MyTextField(
                      controller: keywordController,
                      hintText: 'Keyword',
                      obscureText: false,
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      errorMsg: _errorMsg,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Keyword cannot be empty";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: MyTextField(
                      controller: messageController,
                      hintText: 'Message',
                      obscureText: false,
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      errorMsg: _errorMsg,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Message cannot be empty";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: isEdit
                              ? MediaQuery.of(context).size.width * 0.78
                              : MediaQuery.of(context).size.width * 0.9,
                          child: TextButton(
                            onPressed: () async {
                              // Handle the update logic here
                              QuickTextDTO dto = QuickTextDTO.empty;
                              dto.keyword = keywordController.text;
                              dto.message = messageController.text;

                              String? update = isEdit
                                  ? await quickTextService.updateQuickText(
                                      id, dto)
                                  : await quickTextService.createQuickText(dto);

                              if (update != null) {
                                _displayDialog(update);
                              } else {
                                _displayDialog(null);
                              }
                            },
                            style: TextButton.styleFrom(
                              elevation: 3.0,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 5,
                              ),
                              child: Text(
                                'Update Quick Text',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (isEdit)
                          IconButton(
                            onPressed: () async {
                              // Handle the delete logic here
                              String? delete =
                                  await quickTextService.deleteQuickText(id);

                              if (delete != null) {
                                _displayDialog(delete);
                              } else {
                                _displayDialog(null);
                              }
                              
                            },
                            icon: const Icon(FontAwesomeIcons.trashCan),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    log("build: ${listQuickText.length.toString()}");
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LIST QUICK TEXT",
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    return Padding(
      padding: const EdgeInsets.all(
        10.0,
      ),
      child: Column(
        children: [
          _quickTextList(),
          _addButton(),
        ],
      ),
    );
  }

  Widget _quickTextList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: getData,
        child: ListView.builder(
          itemCount: listQuickText.length,
          itemBuilder: (context, index) {
            QuickText quickText = listQuickText[index];
            return ListTile(
              onTap: () {
                _textBottomSheet(
                    quickText.id, quickText.keyword, quickText.message);
              },
              contentPadding: const EdgeInsets.only(top: 20.0),
              isThreeLine: true,
              subtitle: Text(
                quickText.message,
              ),
              leading: const Icon(FontAwesomeIcons.speakap),
              title: Text(
                quickText.keyword,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _addButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: TextButton(
          onPressed: () async {
            keywordController.text = "";
            messageController.text = "";
            _textBottomSheet(0, "", "");
          },
          style: TextButton.styleFrom(
              elevation: 3.0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            child: Text(
              'New Quick Text',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
