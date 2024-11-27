class RegisterDTO {
  String username;
  String email;
  String password;

  RegisterDTO({
    required this.username,
    required this.email,
    required this.password,
  });

  static final empty = RegisterDTO(
		username: '', 
		email: '', 
		password: '',
	);
}