import 'package:flutter/material.dart';
import 'package:help_chat/page/auth/login_tab_view.dart';
import 'package:help_chat/page/user/chat_page.dart';
import 'package:help_chat/page/home_page.dart';
import 'package:help_chat/page/user/inquiry_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
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
            fontWeight: FontWeight.bold
          )
        )
      ),
      initialRoute: "/home",
      routes: {
        "/login": (context) => const LoginTabView(),
        "/home": (context) => const HomePage(),
        "/inquiry": (context) => const InquiryPage(),
        "/chat": (context) => const ChatPage(),
      },
    );
  }
}