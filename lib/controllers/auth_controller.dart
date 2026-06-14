import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../integration/local/local_storage_service.dart';
import '../integration/services/user_service.dart';

class AuthController extends ChangeNotifier {
  final LocalStorageService _storage;
  final UserService? _userService;

  AuthController(this._storage, [this._userService]);

  bool get isAuthenticated => _storage.isSessionActive;

  /// Returns the currently stored session user, or null if none saved.
  UserModel? get currentUser => _storage.getUser();

  /// Register a new user in the backend and set session active.
  Future<void> register({
    required String name,
    required String lastName,
    required String email,
    required String password,
  }) async {
    if (_userService == null) throw Exception('Servicio de usuarios no disponible.');
    
    // Concatena nombres antes de enviar si es necesario
    final unifiedName = lastName.isNotEmpty ? '$name $lastName'.trim() : name;

    // Llama al backend
    final realUser = await _userService.createUser(
      name: unifiedName,
      email: email,
      password: password,
    );

    // Save as current user and activate session
    await _storage.saveUser(realUser);
    await _storage.setSessionActive(true);
    notifyListeners();
  }

  /// Login functionality is temporarily disabled until real JWT is implemented.
  Future<String?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
    return 'El inicio de sesión real estará disponible próximamente.';
  }

  Future<void> logout() async {
    await _storage.setSessionActive(false);
    notifyListeners();
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
      
      if (_userService != null && currentUser.id.startsWith('U000')) {
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
        );
        await _storage.saveUser(updatedUser);
      }
      notifyListeners();
    }
  }
}
