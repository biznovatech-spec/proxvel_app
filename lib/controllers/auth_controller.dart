import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../integration/local/secure_token_storage.dart';
import '../integration/local/local_storage_service.dart';
import '../integration/services/user_service.dart';
import '../integration/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final LocalStorageService _storage;
  final SecureTokenStorage _secureStorage;
  final UserService? _userService;
  final AuthService? _authService;

  AuthController(this._storage, this._secureStorage, [this._userService, this._authService]);

  bool get isAuthenticated => _storage.isSessionActive;

  /// Returns the currently stored session user, or null if none saved.
  UserModel? get currentUser => _storage.getUser();

  Future<void> saveToken(String token) async => await _secureStorage.saveAccessToken(token);
  Future<void> clearToken() async => await _secureStorage.deleteAccessToken();
  Future<bool> hasToken() async => await _secureStorage.hasAccessToken();

  Future<void> register({
    required String name,
    required String lastName,
    required String email,
    required String password,
  }) async {
    if (_userService == null) throw Exception('Servicio de usuarios no disponible.');
    if (_authService == null) throw Exception('Servicio de autenticación no disponible.');
    
    // Concatena nombres antes de enviar si es necesario
    final unifiedName = lastName.isNotEmpty ? '$name $lastName'.trim() : name;

    // Llama al backend
    await _userService.createUser(
      name: unifiedName,
      email: email,
      password: password,
    );

    // Auto-login post-registro
    try {
      final loginResponse = await _authService.login(
        email: email,
        password: password,
      );
      
      await saveToken(loginResponse.accessToken);
      await _storage.saveUser(loginResponse.user);
      await _storage.setSessionActive(true);
      notifyListeners();
    } catch (e) {
      throw Exception('Tu cuenta fue creada, pero no se pudo iniciar sesión automáticamente. Inicia sesión manualmente.');
    }
  }

  /// Autentica usando JWT y guarda la sesión
  Future<String?> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return 'Correo y contraseña son requeridos.';
    }
    
    if (_authService == null) return 'Servicio de autenticación no disponible.';
    
    try {
      final response = await _authService.login(email: email.trim(), password: password);
      
      await saveToken(response.accessToken);
      await _storage.saveUser(response.user);
      await _storage.setSessionActive(true);
      notifyListeners();
      
      return null; // Null means success (no error)
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> logout() async {
    await clearToken();
    await _storage.clearAllUserData(); // Borrado estricto de seguridad
    await _storage.setSessionActive(false);
    notifyListeners();
  }

  /// Restaura la sesión validando el token contra el backend
  Future<bool> restoreSession() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      await _storage.setSessionActive(false);
      notifyListeners();
      return false;
    }

    if (_authService == null) return false;

    try {
      final user = await _authService.me();
      await _storage.saveUser(user);
      await _storage.setSessionActive(true);
      notifyListeners();
      return true;
    } catch (e) {
      // Si falla (por ejemplo 401), limpiamos sesión
      await logout();
      return false;
    }
  }

  /// Updates the current user's profile info
  Future<void> updateUserProfile({
    required String name,
    required String lastName,
    required String email,
  }) async {
    final currentUser = _storage.getUser();
    if (currentUser != null) {
      final unifiedName = lastName.isNotEmpty ? '$name $lastName'.trim() : name;
      
      if (_userService != null) {
        final realUser = await _userService.updateUser(
          userId: currentUser.id,
          name: unifiedName,
        );
        await _storage.saveUser(realUser);
      } else {
        final updatedUser = UserModel(
          id: currentUser.id,
          name: name,
          lastName: lastName,
          email: email, // Nota: el correo solo se actualiza localmente por ahora
          password: currentUser.password,
          role: currentUser.role,
        );
        await _storage.saveUser(updatedUser);
      }
      notifyListeners();
    }
  }
}
