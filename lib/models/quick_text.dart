class QuickText {

  int id;
  String keyword;
  String message;

  QuickText({
    required this.id,
    required this.keyword,
    required this.message,
  });

  factory QuickText.fromJson(Map<String, dynamic> json) => QuickText(
        id: json["id"],
        keyword: json["keyword"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "keyword": keyword,
        "message": message,
    };

}