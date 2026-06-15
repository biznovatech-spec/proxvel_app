import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../../models/traveler_profile_model.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../local/local_storage_service.dart';

/// Servicio de perfil: almacenamiento local primero; si no hay usuario
/// registrado localmente, carga el usuario demo del backend (Fase 3).
class ProfileService {
  final LocalStorageService _storage;
  final ApiClient? _api;
  ProfileService(this._storage, {ApiClient? apiClient}) : _api = apiClient;

  Future<UserModel?> getUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _storage.getUser();
  }

  /// Lista de usuarios demo del backend para selección de perfil.
  Future<List<UserModel>> getDemoUsers() async {
    if (_api != null) {
      try {
        final json = await _api.get('/users/demo');
        final items = json['data'] as List? ?? [];
        return items
            .whereType<Map<String, dynamic>>()
            .map(UserModel.fromApiJson)
            .toList();
      } catch (e) {
        debugPrint('[ProfileService] usuarios demo API falló: $e');
        if (!ApiConfig.useMockFallback) rethrow;
      }
    }
    // No hay fuente mock para usuarios demo: lista vacía en cualquier caso.
    return [];
  }

  Future<TravelerProfileModel?> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _storage.getProfile();
  }

  Future<void> saveProfile(TravelerProfileModel profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _storage.saveProfile(profile);
  }

  // --- Métodos Fase 3B.1 (Backend) ---

  Future<TravelerProfileModel> getTravelerProfile(String userId) async {
    final api = _api;
    if (api == null) throw Exception('API no inicializada');
    try {
      if (kDebugMode) {
        debugPrint('GET PROFILE URL: /users/$userId/traveler-profile');
      }
      final response = await api.get('/users/$userId/traveler-profile');
      if (kDebugMode) {
        debugPrint('PROFILE RESPONSE: $response');
      }
      final data = response['data'] as Map<String, dynamic>;
      return TravelerProfileModel.fromApiJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        rethrow;
      }
      throw Exception('Error al obtener perfil: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener perfil: $e');
    }
  }

  Future<TravelerProfileModel> putTravelerProfile({
    required String userId,
    required TravelerProfileModel profile,
  }) async {
    final api = _api;
    if (api == null) throw Exception('API no inicializada');
    try {
      final body = profile.toApiJson();
      if (kDebugMode) {
        debugPrint('PREFERENCES SAVE BODY: $body');
        debugPrint('PUT PROFILE URL: /users/$userId/traveler-profile');
      }
      
      final response = await api.put('/users/$userId/traveler-profile', body);
      
      if (kDebugMode) {
        debugPrint('PUT PROFILE RESPONSE: $response');
      }
      
      final data = response['data'] as Map<String, dynamic>;
      return TravelerProfileModel.fromApiJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        throw Exception('Usuario no encontrado.');
      } else if (e.statusCode == 422) {
        throw Exception('Error de validación en los datos del perfil.');
      }
      throw Exception('Error al guardar perfil: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al guardar perfil: $e');
    }
  }

  Future<TravelerProfileModel> patchTravelerProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    final api = _api;
    if (api == null) throw Exception('API no inicializada');
    try {
      final response = await api.patch('/users/$userId/traveler-profile', updates);
      final data = response['data'] as Map<String, dynamic>;
      return TravelerProfileModel.fromApiJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        throw Exception('Perfil o usuario no encontrado.');
      } else if (e.statusCode == 422) {
        throw Exception('Error de validación en la actualización del perfil.');
      }
      throw Exception('Error al actualizar perfil: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al actualizar perfil: $e');
    }
  }
}
