import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:help_chat/consts/shared_pref.dart';
import 'package:help_chat/models/menu_item.dart';
import 'package:help_chat/models/user.dart';
import 'package:help_chat/page/agent/list_room.dart';
import 'package:help_chat/page/user/inquiry_page.dart';

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
    MenuItem(title: 'Help', icon: Icons.help, userRole: "USER"),
    MenuItem(title: 'List Room', icon: Icons.notes_rounded, userRole: "AGENT"),
    MenuItem(title: 'Settings', icon: Icons.settings, userRole: "AGENT"),
    MenuItem(title: 'Profile', icon: Icons.person, userRole: "AGENT"),
    // MenuItem(title: 'Messages', icon: Icons.message),
    // MenuItem(title: 'Notifications', icon: Icons.notifications),
  ];

  @override
  void initState() {
    super.initState();
    isLogin = false;
    setState(() {
      _loadUserPref();
      isLoading = true;
    });
  }

  Future<void> _loadUserPref() async {
    String? existUser = await SharedPref.getUserPref();
    if (existUser != null && existUser.isNotEmpty) {
      setState(() {
        user = User.fromJson(jsonDecode(existUser));
        isLogin = true;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      // Navigator.pushNamed(context, "/login");
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
      filteredMenu = menuItems;
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
                  case "help":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const InquiryPage();
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
                  default:
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
