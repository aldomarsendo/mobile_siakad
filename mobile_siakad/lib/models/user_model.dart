class User {
  final String id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final String role;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    required this.role,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? {};
    final roles = userJson['roles'] as List<dynamic>?;
    final role = roles != null && roles.isNotEmpty 
      ? roles.first['name'].toString()
      : 'user';

    return User(
      id: userJson['id'].toString(),
      name: userJson['name'] ?? '',
      email: userJson['email'] ?? '',
      emailVerifiedAt: userJson['email_verified_at'] ?? null,
      createdAt: userJson['created_at'] ?? null,
      updatedAt: userJson['updated_at'] ?? null,
      role: role,
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'role': role,
      'token': token,
    };
  }
}
