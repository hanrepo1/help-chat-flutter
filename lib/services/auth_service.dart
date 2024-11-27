import 'dart:developer';

import 'package:help_chat/consts/shared_pref.dart';
import 'package:help_chat/dto/register_DTO.dart';
import 'package:help_chat/services/http_service.dart';

import '../models/user.dart';

class AuthService {
  static final AuthService _singleton = AuthService._internal();

  final _httpService = HTTPService();

  User? user;

  factory AuthService() {
    return _singleton;
  }

  AuthService._internal();

  Future<User?> getProfile() async {
    try {
      var response = await _httpService.get("/user/me");
      if (response?.status == 200 && response?.content != null) {
        user = User.fromJson(response!.content);
        await SharedPref.storeUserPref(user!);
        return user;
      }
    } catch (e) {
      log(e.toString());
    }

    return null;
  }

  Future<String?> login(String username, String password) async {
    try {
      var response = await _httpService.post("/auth/token", {
        "username": username,
        "password": password,
      });
      log("token : ${response?.content}");
      if (response?.status == 200 && response?.content != null) {
        // Assuming the token is in response.content under the key 'accessToken'
        String accessToken = response?.content;

        // Store the access token for future use
        await SharedPref.storeAccessToken(accessToken);
        
        // Set the bearer token in the HTTP service for future requests
        HTTPService().setup(bearerToken: accessToken);
        await getProfile();

        return null;
      } else {
        // Return the error message from the response if available
        return response?.content ?? "Login failed. Please try again.";
      }
    } catch (e) {
      log(e.toString());
      return e.toString();
    }
  }

  Future<String?> register(RegisterDTO registerDTO) async {
    try {
      var response = await _httpService.post("/user/createUser", {
        "username": registerDTO.username,
        "email": registerDTO.email,
        "password": registerDTO.password,
      });
      if (response?.status == 200 && response?.content != null) {
        return null;
      } else {
        // Return the error message from the response if available
        return response?.content ?? "${response?.status} - Please try again later.";
      }
    } catch (e) {
      log(e.toString());
      return e.toString();
    }
  }
}
