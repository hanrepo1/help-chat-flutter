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

  Future<String?> login(String username, String password) async {
    var response;
    try {
      final body = {
        "username": username,
        "password": password,
      };
      response = await _httpService.post("/auth/token", queryParameters: body);
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
      return response.toString();
    }
  }

  Future<String?> register(RegisterDTO registerDTO) async {
    try {
      final body = {
        "username": registerDTO.username,
        "email": registerDTO.email,
        "password": registerDTO.password,
      };
      var response = await _httpService.post("/user/createUser", queryParameters: body);
      if (response?.status == 200 && response?.content != null) {
        return null;
      } else {
        // Return the error message from the response if available
        return response?.content ??
            "${response?.status} - Please try again later.";
      }
    } catch (e) {
      log(e.toString());
      return e.toString();
    }
  }

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

  Future<List<User>?> getAllUser() async {
    try {
      var response = await _httpService.get("/user/getAllUser");
      if (response?.status == 200 && response?.content != null) {
        List content = response!.content;
        List<User> listUser = content.map((e) => User.fromJson(e)).toList();
        return listUser;
      }
    } catch (e) {
      log(e.toString());
    }

    return null;
  }

  Future<String?> updateRole(int id, String roleName) async {
    try {
      var response = await _httpService.put("/user/updateRole/$id", {
        "roleName": roleName,
      });
      if (response?.status == 200 && response?.content != null) {
        return null;
      } else {
        // Return the error message from the response if available
        return response?.content ??
            "${response?.status} - Please try again later.";
      }
    } catch (e) {
      log(e.toString());
      return e.toString();
    }
  }

  Future<String?> deleteUser(int id) async {
    try {
      var response = await _httpService.put("/user/deleteUser/$id", {});
      if (response?.status == 200 && response?.content != null) {
        return null;
      } else {
        // Return the error message from the response if available
        return response?.content ??
            "${response?.status} - Please try again later.";
      }
    } catch (e) {
      log(e.toString());
      return e.toString();
    }
  }
}
