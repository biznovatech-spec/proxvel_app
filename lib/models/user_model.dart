class UserModel {
  final String id;
  final String name;
  final String lastName;
  final String email;
  final String password; // Local-only simulated password (not hashed)
  final String role;
  final bool isActive;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    this.lastName = '',
    required this.email,
    this.password = '',
    this.role = 'user',
    this.isActive = true,
    this.avatarUrl,
  });

  /// Full display name.
  String get fullName =>
      lastName.isNotEmpty ? '$name $lastName' : name;

  /// Construye un usuario desde el backend (GET /users/demo o /users/{id}).
  factory UserModel.fromApiJson(Map<String, dynamic> json) => UserModel(
        id: json['user_id'] ?? json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? 'user',
        isActive: json['is_active'] ?? true,
        avatarUrl: json['avatar_url'],
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['user_id'] ?? json['id'] ?? '',
        name: json['name'] ?? '',
        lastName: json['lastName'] ?? '',
        email: json['email'] ?? '',
        password: '', // NO persistir password local
        role: json['role'] ?? 'user',
        isActive: json['is_active'] ?? true,
        avatarUrl: json['avatar_url'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': id,
        'name': name,
        'lastName': lastName,
        'email': email,
        'role': role,
        'is_active': isActive,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

  /// Serializa el usuario para enviarlo al backend (POST /users).
  Map<String, dynamic> toApiJson() => {
        'name': lastName.isNotEmpty ? '$name $lastName'.trim() : name,
        'email': email,
        'password': password,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };
}
