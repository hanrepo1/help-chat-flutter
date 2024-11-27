class ChatRoom {
    int? roomId;
    String? userId;
    int? agentId;
    String? userName;
    String? content;
    int? dateCreated;

    ChatRoom({
        this.roomId,
        this.userId,
        this.agentId,
        this.userName,
        this.content,
        this.dateCreated,
    });

    ChatRoom copyWith({
        int? roomId,
        String? userId,
        int? agentId,
        String? userName,
        String? content,
        int? dateCreated,
    }) => 
        ChatRoom(
            roomId: roomId ?? this.roomId,
            userId: userId ?? this.userId,
            agentId: agentId ?? this.agentId,
            userName: userName ?? this.userName,
            content: content ?? this.content,
            dateCreated: dateCreated ?? dateCreated,
        );

    factory ChatRoom.fromJson(Map<String, dynamic> json) => ChatRoom(
        roomId: json["roomId"],
        userId: json["userId"],
        agentId: json["agentId"],
        userName: json["userName"],
        content: json["content"],
        dateCreated: json["dateCreated"],
    );

    Map<String, dynamic> toJson() => {
        "roomId": roomId,
        "userId": userId,
        "agentId": agentId,
        "userName": userName,
        "content": content,
        "dateCreated": dateCreated,
    };
}
