import 'dart:developer';

import 'package:help_chat/dto/quick_text_DTO.dart';
import 'package:help_chat/models/quick_text.dart';
import 'package:help_chat/services/http_service.dart';

class QuickTextService {

  static final QuickTextService _singleton = QuickTextService._internal();

  final HTTPService _httpService = HTTPService();

  factory QuickTextService() {
    return _singleton;
  }

  QuickTextService._internal();

  final String initialPath = "/quickText";

  Future<List<QuickText>?> getQuickText() async {
    String path = "$initialPath/getAll";
    var response = await _httpService.get(path);
    if (response?.status == 200 && response?.content != null) {
      List content = response!.content;
      List<QuickText> chatRoom = content.map((e) => QuickText.fromJson(e)).toList();
      return chatRoom;
    }
    return null;
  }

  Future<String?> createQuickText(QuickTextDTO quickTextDTO) async {
    String path = "$initialPath/create";
    try {
      final body = {
        "keyword": quickTextDTO.keyword,
        "message": quickTextDTO.message,
      };
      var response = await _httpService.post(path, queryParameters: body);
      if (response?.status == 200 && response?.content != null) {
        return null;
      } else {
        // Return the error message from the response if available
        return response?.content ?? "${response?.status} - ${response?.content}";
      }
    } catch (e) {
      log(e.toString());
      return e.toString();
    }
  }

  Future<String?> updateQuickText(int id, QuickTextDTO quickTextDTO) async {
    String path = "$initialPath/update/$id";
    try {
      var response = await _httpService.put(path, {
        "keyword": quickTextDTO.keyword,
        "message": quickTextDTO.message,
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

  Future<String?> deleteQuickText(int id) async {
    String path = "$initialPath/delete/$id";
    try {
      var response = await _httpService.put(path, {});
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