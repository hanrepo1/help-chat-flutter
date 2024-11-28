class QuickTextDTO {

  String keyword;
  String message;

  QuickTextDTO({
    required this.keyword,
    required this.message,
  });

  static final empty = QuickTextDTO(
		keyword: '', 
		message: '',
	);
}