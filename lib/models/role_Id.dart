class RoleId {
  int id;
  String name;
  String displayName;
  String description;
  DateTime createdAt;
  DateTime updatedAt;

  RoleId({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  RoleId copyWith({
    int? id,
    String? name,
    String? displayName,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      RoleId(
        id: id ?? this.id,
        name: name ?? this.name,
        displayName: displayName ?? this.displayName,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory RoleId.fromJson(Map<String, dynamic> json) => RoleId(
        id: json["id"],
        name: json["name"],
        displayName: json["displayName"],
        description: json["description"],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "displayName": displayName,
        "description": description,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
