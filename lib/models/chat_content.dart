class ChatContent {
    int roomId;
    String? userId;
    int? agentId;
    String? userName;
    String? agentName;
    String? content;
    int timeSent;
    bool? isAgent;

    ChatContent({
        required this.roomId,
        this.userId,
        this.agentId,
        this.userName,
        this.agentName,
        this.content,
        required this.timeSent,
        this.isAgent = false,
    });

    ChatContent copyWith({
        int? roomId,
        String? userId,
        int? agentId,
        String? userName,
        String? agentName,
        String? content,
        int? timeSent,
        required bool isAgent,
    }) => 
        ChatContent(
            roomId: roomId ?? this.roomId,
            userId: userId ?? this.userId,
            agentId: agentId ?? this.agentId,
            userName: userName ?? this.userName,
            agentName: agentName ?? this.agentName,
            content: content ?? this.content,
            timeSent: timeSent ?? this.timeSent,
            isAgent: isAgent,
        );

    factory ChatContent.fromJson(Map<String, dynamic> json) => ChatContent(
        roomId: json["roomId"],
        userId: json["userId"],
        agentId: json["agentId"],
        userName: json["userName"],
        agentName: json["agentName"],
        content: json["content"],
        timeSent: json["timeSent"],
        isAgent: json["isAgent"],
    );

    Map<String, dynamic> toJson() => {
        "roomId": roomId,
        "userId": userId,
        "agentId": agentId,
        "userName": userName,
        "agentName": agentName,
        "content": content,
        "timeSent": timeSent,
        "isAgent": isAgent,
    };
}
