import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:help_chat/components/my_text_field.dart';
import 'package:help_chat/models/user.dart';
import 'package:help_chat/services/auth_service.dart';

class ListUser extends StatefulWidget {
  const ListUser({super.key});

  @override
  State<ListUser> createState() => _ListUserState();
}

class _ListUserState extends State<ListUser> {
  final AuthService authService = AuthService();
  final userController = TextEditingController();
  final roleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<User> listUser = [];
  bool isLoading = false;
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
      listUser = (await authService.getAllUser())!;
      log("get Data QT: ${listUser.length.toString()}"); // Fetch chat rooms
    } catch (e) {
      // Handle any errors here
      log("Error fetching user: $e");
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

  void _textBottomSheet(int id, String editUser, String editRole) {
    if (editUser.isNotEmpty && editRole.isNotEmpty) {
      userController.text = editUser;
      roleController.text = editRole;
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
                      enable: false,
                      controller: userController,
                      hintText: 'Username',
                      obscureText: false,
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      errorMsg: _errorMsg,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Username cannot be empty";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: MyTextField(
                      controller: roleController,
                      hintText: 'Role Name',
                      obscureText: false,
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      errorMsg: _errorMsg,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Role cannot be empty";
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
                          width: MediaQuery.of(context).size.width * 0.78,
                          child: TextButton(
                            onPressed: () async {
                              // Handle the update logic here
                              String? update = await authService.updateRole(
                                  id, roleController.text);

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
                                'Update User',
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
                        IconButton(
                          onPressed: () async {
                            // Handle the delete logic here
                            String? delete = await authService.deleteUser(id);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LIST USERS",
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
          _userLists(),
        ],
      ),
    );
  }

  Widget _userLists() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: getData,
        child: ListView.builder(
          itemCount: listUser.length,
          itemBuilder: (context, index) {
            User users = listUser[index];
            return ListTile(
              onTap: () {
                _textBottomSheet(users.id, users.username, users.roleId.name);
              },
              contentPadding: const EdgeInsets.only(top: 20.0),
              isThreeLine: true,
              title: Text(
                "Username : ${users.username}",
              ),
              leading: const Icon(FontAwesomeIcons.person),
              subtitle: Text(
                "Role Name : ${users.roleId.name}",
              ),
            );
          },
        ),
      ),
    );
  }
}
