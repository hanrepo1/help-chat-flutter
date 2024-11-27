import 'package:help_chat/models/role_Id.dart';

class User {
  int id;
  String username;
  String email;
  RoleId roleId;
  DateTime createdAt;
  DateTime updatedAt;
  String createdBy;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.roleId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  User copyWith({
    int? id,
    String? username,
    String? email,
    RoleId? roleId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) =>
      User(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        roleId: roleId ?? this.roleId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        createdBy: createdBy ?? this.createdBy,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        roleId: RoleId.fromJson(json['roleId']),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        createdBy: json["createdBy"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "email": email,
        'roleId': roleId.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        "createdBy": createdBy,
      };
}
