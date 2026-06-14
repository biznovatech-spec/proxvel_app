import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/traveler_profile_model.dart';
import '../integration/services/profile_service.dart';
import '../integration/services/user_service.dart';
import '../integration/local/local_storage_service.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _profileService;
  final UserService? _userService;
  final LocalStorageService _storageService;
  bool isLoading = false;
  UserModel? user;
  TravelerProfileModel? profile;
  String? error;

  // ignore: prefer_initializing_formals
  ProfileController(this._profileService, this._storageService, {UserService? userService}) : _userService = userService;

  Future<void> loadProfileData() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      // 1. Obtener usuario actual desde caché local (id real)
      final localUser = _storageService.getUser();
      final userId = localUser?.id;

      if (userId != null && userId.startsWith('U000')) {
        // 2. Consultar backend
        if (_userService != null) {
          try {
            user = await _userService.getUserById(userId);
            profile = await _profileService.getTravelerProfile(userId);
            
            // Actualizar caché local si hubo éxito
            if (user != null) await _storageService.saveUser(user!);
            if (profile != null) await _storageService.saveProfile(profile!);
          } catch (e) {
            // Fallback en caso de error
            error = 'Mostrando datos locales (offline o error API).';
            user = localUser;
            profile = _storageService.getProfile() ?? await _profileService.getProfile();
          }
        } else {
          // Si no hay UserService inyectado
          user = localUser;
          profile = _storageService.getProfile();
        }
      } else {
        // No hay usuario activo
        user = null;
        profile = null;
        error = 'No se encontró un usuario activo. Regístrate o inicia sesión para continuar.';
      }
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> updatePreferences(TravelerProfileModel updatedProfile) async {
    final userId = user?.id;
    if (userId != null && userId.startsWith('U000')) {
      // Llamada real al backend
      final realProfile = await _profileService.putTravelerProfile(
        userId: userId,
        profile: updatedProfile,
      );
      profile = realProfile;
      await _storageService.saveProfile(realProfile);
    } else {
      // Fallback local
      profile = updatedProfile;
      await _storageService.saveProfile(updatedProfile);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _storageService.setSessionActive(false);
  }
}
