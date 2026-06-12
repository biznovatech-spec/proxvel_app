class UserModel {
  final String id;
  final String name;
  final String lastName;
  final String email;
  final String password; // Local-only simulated password (not hashed)

  UserModel({
    required this.id,
    required this.name,
    this.lastName = '',
    required this.email,
    this.password = '',
  });

  /// Full display name.
  String get fullName =>
      lastName.isNotEmpty ? '$name $lastName' : name;

  /// Construye un usuario desde el backend (GET /users/demo o /users/{id}).
  factory UserModel.fromApiJson(Map<String, dynamic> json) => UserModel(
        id: json['user_id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        lastName: json['lastName'] ?? '',
        email: json['email'],
        password: json['password'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lastName': lastName,
        'email': email,
        'password': password,
      };
}
