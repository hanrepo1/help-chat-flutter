import 'dart:convert';

import 'package:help_chat/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  // Method to store the access token
  static Future<void> storeAccessToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
  }

  // Method to retrieve the access token
  static Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // Optional: Method to remove the access token
  static Future<void> removeAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
  }

  static Future<void> storeUserPref(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
  } 

  static Future<String?> getUserPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user');
  } 
}