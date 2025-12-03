class User {
  final String id;
  final String email;
  final String token;
  final String? username;

  User({
    required this.id,
    required this.email,
    required this.token,
    this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      username: json['username'],
    );
  }
}
