import 'dart:developer';

import 'package:help_chat/models/chat_content.dart';
import 'package:help_chat/models/chat_room.dart';
import 'package:help_chat/services/http_service.dart';

class ChatService {

  static final ChatService _singleton = ChatService._internal();

  final HTTPService _httpService = HTTPService();

  factory ChatService() {
    return _singleton;
  }

  ChatService._internal();

  final String initialPath = "/chat";

  Future<List<ChatRoom>?> getRooms(String filter) async {
    String path = "$initialPath/getRooms";
    var response = await _httpService.get(path);
    if (response?.status == 200 && response?.content != null) {
      List content = response!.content;
      List<ChatRoom> chatRoom = content.map((e) => ChatRoom.fromJson(e)).toList();
      return chatRoom;
    }
    return null;
  }

  Future<List<ChatContent>?> getChatContent(int roomId) async {
    String path = "$initialPath/messages/$roomId";
    var response = await _httpService.get(path);
    // log("chat service_getChatContent : ${(response?.content)}");
    if (response?.status == 200 && response?.content != null) {
      List content = response!.content;
      List<ChatContent> chatRoom = content.map((e) => ChatContent.fromJson(e)).toList();
      log("chat service_getChatContent : ${content}");
      return chatRoom;
    }
    
    return null;
  }

  Future<ChatRoom?> startChat(String name, String content) async {
    String path = "$initialPath/start";
    var data = {
      'userName': name,
      'content': content,
    };
    var response = await _httpService.post(path, data);

    // Check if response is not null and has a status code of 200
    if (response != null && response.status == 200) {
        // Check if the response indicates success
        if (response.content != null && response.success == true) {
            // Extract the room data from the content
          return ChatRoom.fromJson(response.content);
        }
    }

    return null; // Return null if the response is not successful
  }

}