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
    final local = _storage.getUser();
    if (local != null) return local;

    if (_api != null) {
      try {
        final json = await _api.get('/users/${ApiConfig.demoUserId}');
        final data = json['data'] as Map<String, dynamic>?;
        if (data != null) return UserModel.fromApiJson(data);
      } catch (e) {
        debugPrint('[ProfileService] usuario API falló, usando local: $e');
      }
    }
    return null;
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
      }
    }
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
}
