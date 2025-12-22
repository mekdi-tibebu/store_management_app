class User {
  final int? id;
  final String username;
  final String email;
  final bool hasActiveSubscription;
  
  User({
    this.id,
    required this.username,
    required this.email,
    this.hasActiveSubscription = false,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      hasActiveSubscription: json['has_active_subscription'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'has_active_subscription': hasActiveSubscription,
    };
  }
}
