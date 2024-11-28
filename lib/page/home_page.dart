import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:help_chat/consts/shared_pref.dart';
import 'package:help_chat/models/menu_item.dart';
import 'package:help_chat/models/user.dart';
import 'package:help_chat/page/agent/list_quick_text.dart';
import 'package:help_chat/page/agent/list_room.dart';
import 'package:help_chat/page/master/list_user.dart';
import 'package:help_chat/page/user/inquiry_page.dart';
import 'package:help_chat/page/user/list_inquiry.dart';
import 'package:help_chat/services/http_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool isLogin, isLoading;
  User? user;
  List<MenuItem> filteredMenu = [];

  final List<MenuItem> menuItems = [
    MenuItem(title: 'Start Message', icon: Icons.message, userRole: "USER"),
    MenuItem(title: 'List Messages', icon: Icons.list_sharp, userRole: "USER"),
    MenuItem(title: 'List Room', icon: Icons.notes_rounded, userRole: "AGENT"),
    MenuItem(title: 'Users Data', icon: Icons.person, userRole: "MASTER"),
    MenuItem(title: 'Settings', icon: Icons.settings, userRole: "AGENT"),
    // MenuItem(title: 'Notifications', icon: Icons.notifications),
  ];

  @override
  void initState() {
    super.initState();
    setState(() {
      isLogin = false;
      _loadUserPref();
      isLoading = true;
    });
  }

  Future<void> _loadUserPref() async {
    String? existUser = await SharedPref.getUserPref();
    String? token = await SharedPref.getAccessToken();
    if (token != null) {
      log("tokenExist : $token");
      HTTPService().setup(bearerToken: token);
    }
    if (existUser != null && existUser.isNotEmpty) {
      setState(() {
        user = User.fromJson(jsonDecode(existUser));
        log("_loadUserPref : ${user!.username}");
        isLogin = true;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                SharedPref.removeUserPref();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    log("isLogin : $isLogin");
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "HOME PAGE",
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: isLogin
                ? IconButton(
                    onPressed: () {
                      _logout();
                    },
                    icon: const Icon(FontAwesomeIcons.arrowRightToBracket))
                : IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/login");
                    },
                    icon: const Icon(FontAwesomeIcons.doorOpen)),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
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
          _menuButtons(),
        ],
      ),
    );
  }

  Widget _menuButtons() {
    if (user != null) {
      filteredMenu = [];
      setState(() {
        switch (user!.roleId.name) {
          case "USER":
            filteredMenu =
                menuItems.where((item) => item.userRole == "USER").toList();
            break;
          case "AGENT":
            filteredMenu = menuItems
                .where(
                    (item) => item.userRole == "AGENT" || item.userRole == null)
                .toList();
            break;
          case "MASTER":
            filteredMenu = menuItems; // MASTER can access all items
            break;
          default:
            break;
        }
      });
    } else {
      filteredMenu =
          menuItems.where((item) => item.userRole == "USER").toList();
    }

    if (filteredMenu.isNotEmpty) {
      for (var element in filteredMenu) {
        log(element.toString());
      }
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.height * 0.8,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns
          childAspectRatio: 1, // Aspect ratio of each item
        ),
        itemCount: filteredMenu.isEmpty
            ? 0
            : filteredMenu.length, // Use filteredMenu length
        itemBuilder: (context, index) {
          final menuItem = filteredMenu[index]; // Access filtered menu item

          return Card(
            child: InkWell(
              onTap: () {
                switch (menuItem.title.toLowerCase()) {
                  case "start message":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          if (user?.username == null || user!.username.isEmpty) {
                            return const InquiryPage(username: "", userId: "");
                          } else {
                            return InquiryPage(username: user?.username, userId: user?.id.toString());
                          }
                        },
                      ),
                    );
                    break;
                  case "list room":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const ListRoom();
                        },
                      ),
                    );
                    break;
                  case "list messages":
                    if (user?.id != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ListInquiry(userId: "${user!.id}");
                          },
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please login before accessing this feature!"),
                          backgroundColor:
                              Colors.red, // Optional: Change color for error
                        ),
                      );
                    }
                    break;
                  case "users data":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const ListUser();
                        },
                      ),
                    );
                    break;
                  case "settings":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const ListQuickText();
                        },
                      ),
                    );
                    break;
                  default:
                    log("menu name : ${menuItem.title.toLowerCase()}");
                    break;
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(menuItem.icon, size: 50),
                  const SizedBox(height: 10),
                  Text(menuItem.title, style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
