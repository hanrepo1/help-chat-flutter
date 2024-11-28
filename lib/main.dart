import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:help_chat/page/agent/list_quick_text.dart';
import 'package:help_chat/page/auth/login_tab_view.dart';
import 'package:help_chat/page/user/chat_page.dart';
import 'package:help_chat/page/home_page.dart';
import 'package:help_chat/page/user/inquiry_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // Handle app pause
        log("App is paused");
        break;
      case AppLifecycleState.resumed:
        // Handle app resume
        log("App is resumed");
        break;
      case AppLifecycleState.detached:
        // Handle app detached
        // SharedPref.removeUserPref();
        log("App is detached");
        break;
      case AppLifecycleState.inactive:
        // Handle app inactive
        log("App is inactive");
        break;
      case AppLifecycleState.hidden:
        // Handle app hidden
        log("App is hidden");
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HOME',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: "/home",
      routes: {
        "/login": (context) => const LoginTabView(),
        "/home": (context) => const HomePage(),
        "/inquiry": (context) => const InquiryPage(),
        "/chat": (context) => const ChatPage(),
        "/quickText": (context) => const ListQuickText(),
      },
    );
  }
}