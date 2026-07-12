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

  int _mutationGeneration = 0;

  // ignore: prefer_initializing_formals
  ProfileController(this._profileService, this._storageService, {UserService? userService}) : _userService = userService;

  Future<void> loadProfileData() async {
    final currentGeneration = ++_mutationGeneration;
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
          
          // Bloque protegido 1: Cargar User Base
          try {
            user = await _userService.getUserById(userId);
            if (user != null) await _storageService.saveUser(user!);
          } catch (e) {
            user = localUser;
            // Si el user base falla, sí mostramos error global
            if (currentGeneration == _mutationGeneration) {
              error = 'No pudimos cargar tu información de usuario. Intenta nuevamente.';
            }
          }

          // Bloque protegido 2: Cargar Traveler Profile
          try {
            final fetchedProfile = await _profileService.getTravelerProfile(userId);
            if (currentGeneration == _mutationGeneration) {
              profile = fetchedProfile;
              await _storageService.saveProfile(profile!);
            }
          } catch (profileError) {
            if (currentGeneration == _mutationGeneration) {
              final isProfileNotFound = profileError is ApiException && profileError.statusCode == 404;
              if (isProfileNotFound) {
                profile = null; // Normal para un usuario nuevo sin perfil
              } else {
                // Fallo por timeout/500/etc.
                // Degradación elegante: leemos de local pero NO bloqueamos el UI
                final localProfile = _storageService.getProfile();
                profile = localProfile;
                // No seteamos "error global" porque arruinaría la experiencia
              }
            }
          }
          
        } else {
          // Si no hay UserService inyectado
          user = localUser;
        }
      } else {
        // No hay usuario activo
        if (currentGeneration == _mutationGeneration) {
          user = null;
          profile = null;
          error = 'No se encontró un usuario activo. Regístrate o inicia sesión para continuar.';
        }
      }
    } catch (e) {
      if (currentGeneration == _mutationGeneration) {
        error = e.toString();
      }
    }
    
    if (currentGeneration == _mutationGeneration) {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    _mutationGeneration++;
    user = null;
    profile = null;
    error = null;
    isLoading = false;
    notifyListeners();
  }

  Future<void> updatePreferences(TravelerProfileModel updatedProfile) async {
    final userId = user?.id;
    _mutationGeneration++; // Cancela silenciosamente las cargas viejas
    
    error = null;
    isLoading = false;
    
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

    _mutationGeneration++;
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
      _mutationGeneration++;
      profile = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _mutationGeneration++;
    user = null;
    profile = null;
    error = null;
    await _storageService.clearAllUserData();
    await _storageService.setSessionActive(false);
    notifyListeners();
  }
}
