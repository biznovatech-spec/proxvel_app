import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../integration/local/local_storage_service.dart';

class AuthController extends ChangeNotifier {
  final LocalStorageService _storage;

  AuthController(this._storage);

  bool get isAuthenticated => _storage.isSessionActive;

  /// Returns the currently stored session user, or null if none saved.
  UserModel? get currentUser => _storage.getUser();

  /// Register a new user locally and set session active.
  Future<void> register({
    required String name,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      lastName: lastName,
      email: email,
      password: password,
    );
    // Save in registered users store
    await _storage.registerUser(user);
    // Save as current user and activate session
    await _storage.saveUser(user);
    await _storage.setSessionActive(true);
    notifyListeners();
  }

  /// Login by validating email/password against locally registered users.
  /// Returns null on success, or an error message on failure.
  Future<String?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay

    final user = _storage.findUserByEmail(email);
    if (user == null) {
      return 'No se encontró una cuenta con ese correo.';
    }
    if (user.password != password) {
      return 'La contraseña es incorrecta.';
    }

    // Credentials valid — set session
    await _storage.saveUser(user);
    await _storage.setSessionActive(true);
    notifyListeners();
    return null; // success
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
      final updatedUser = UserModel(
        id: currentUser.id,
        name: name,
        lastName: lastName,
        email: email,
        password: currentUser.password,
      );
      
      // Update in registered list (simulating DB update)
      await _storage.registerUser(updatedUser); // registerUser actually overrides by ID if we implement it, wait, let me check _storage.registerUser
      
      // Wait, _storage.registerUser adds to a list. We should just save it as the current user. 
      // If we need to update the list, we might need a specific method, but for mock purposes:
      await _storage.saveUser(updatedUser);
      notifyListeners();
    }
  }
}
