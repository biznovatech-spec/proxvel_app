import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio para el manejo seguro del JWT u otros tokens confidenciales.
/// Emplea flutter_secure_storage (Keychain en iOS, EncryptedSharedPreferences en Android).
class SecureTokenStorage {
  final _storage = const FlutterSecureStorage();
  
  static const _tokenKey = 'jwt_access_token';

  /// Guarda el Access Token.
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Recupera el Access Token. Retorna null si no existe.
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Elimina el Access Token, cerrando la sesión de forma efectiva a nivel de auth.
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Retorna true si hay un token guardado.
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
