import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/traveler_profile_model.dart';
import '../integration/services/profile_service.dart';
import '../integration/services/user_service.dart';
import '../integration/local/local_storage_service.dart';
import '../integration/api/api_client.dart';

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

      if (userId != null) {
        // 2. Consultar backend
        if (_userService != null) {
          try {
            user = await _userService.getUserById(userId);
            try {
              profile = await _profileService.getTravelerProfile(userId);
            } catch (profileError) {
              final isProfileNotFound = profileError is ApiException && profileError.statusCode == 404;
              if (isProfileNotFound) {
                profile = null; // Normal para un usuario nuevo sin perfil
              } else {
                rethrow;
              }
            }
            
            // Actualizar caché local si hubo éxito
            if (user != null) await _storageService.saveUser(user!);
            if (profile != null) {
              await _storageService.saveProfile(profile!);
            } else {
              // Si no hay perfil, asegurarse de no mantener uno viejo en cache
              // (Se manejará en LocalStorageService, pero evitamos cargarlo)
            }
          } catch (e) {
            // Fallback normal por falta de internet u otro error
            error = 'No pudimos cargar tu información. Intenta nuevamente.';
            user = localUser;
            // IMPORTANTE: NO hacemos fallback al perfil local aquí, 
            // porque podría pertenecer a un usuario anterior si no se limpió bien.
            profile = null;
          }
        } else {
          // Si no hay UserService inyectado
          user = localUser;
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

  /// Limpia todo el estado en memoria. Llamar al logout/cambio de usuario.
  void clearState() {
    user = null;
    profile = null;
    error = null;
    isLoading = false;
    notifyListeners();
  }

  Future<void> updatePreferences(TravelerProfileModel updatedProfile) async {
    final userId = user?.id;
    if (userId != null) {
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

  /// Cambia la preferencia "Aplicar IA en toda la app".
  /// Usa PATCH parcial (no recalcula pesos en backend). Optimista con reversión.
  Future<void> setApplyAiGlobally(bool value) async {
    final userId = user?.id;
    final current = profile;
    if (current == null) return; // Sin perfil no hay preferencia que aplicar.

    final previous = current;
    profile = current.copyWithAi(value);
    notifyListeners();

    if (userId == null) {
      // Sin sesión backend: persistir solo local.
      await _storageService.saveProfile(profile!);
      return;
    }

    try {
      final updated = await _profileService.patchTravelerProfile(
        userId: userId,
        updates: {'apply_ai_globally': value},
      );
      profile = updated;
      await _storageService.saveProfile(updated);
      notifyListeners();
    } catch (e) {
      // Revertir si falla la persistencia.
      profile = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    user = null;
    profile = null;
    await _storageService.clearAllUserData();
    await _storageService.setSessionActive(false);
    notifyListeners();
  }
}
