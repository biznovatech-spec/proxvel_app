import 'user_model.dart';

class AuthLoginResponse {
  final String accessToken;
  final String tokenType;
  final UserModel user;

  AuthLoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthLoginResponse.fromJson(Map<String, dynamic> json) {
    return AuthLoginResponse(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
      user: UserModel.fromApiJson(json['user'] ?? {}),
    );
  }
}
