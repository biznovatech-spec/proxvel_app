import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/destination_model.dart';
import '../integration/services/favorites_service.dart';

/// Favoritos LOCAL-first: la fuente de verdad es el almacenamiento del
/// dispositivo (shared_preferences). El backend se sincroniza best-effort
/// (si responde, se fusiona; si falla, se mantiene lo local). Así el favorito
/// NUNCA se desmarca por un problema de red.
class FavoritesController extends ChangeNotifier {
  final FavoritesService _favoritesService;
  static const _prefsKey = 'local_favorites_v1';

  bool isLoading = false;
  List<DestinationModel> favorites = [];
  Set<String> favoriteDestinationIds = {};
  String? error;

  FavoritesController(this._favoritesService);

  Future<void> loadFavorites() async {
    isLoading = true;
    error = null;
    notifyListeners();

    await _loadLocal();

    // Backend best-effort: fusiona lo que devuelva sin romper lo local.
    try {
      final favModels = await _favoritesService.getFavorites();
      bool changed = false;
      for (final f in favModels) {
        final d = DestinationModel.fromFavoriteModel(f);
        if (!favoriteDestinationIds.contains(d.id)) {
          favorites.add(d);
          favoriteDestinationIds.add(d.id);
          changed = true;
        }
      }
      if (changed) await _saveLocal();
    } catch (_) {
      // offline / backend caído: se mantiene lo local.
    }

    isLoading = false;
    notifyListeners();
  }

  /// Marca/desmarca. Pasa el `model` al MARCAR para poder mostrarlo en la
  /// pantalla de Favoritos aunque el backend no responda.
  Future<void> toggleFavorite(String id, [DestinationModel? model]) async {
    final isFav = isFavorite(id);
    if (isFav) {
      favoriteDestinationIds.remove(id);
      favorites.removeWhere((d) => d.id == id);
    } else {
      favoriteDestinationIds.add(id);
      if (model != null && !favorites.any((d) => d.id == id)) {
        favorites.add(model);
      }
    }
    notifyListeners();
    await _saveLocal();

    // Sincroniza al backend sin revertir si falla.
    try {
      if (isFav) {
        await _favoritesService.removeFavorite(id);
      } else {
        await _favoritesService.addFavorite(id);
      }
    } catch (_) {}
  }

  bool isFavorite(String id) => favoriteDestinationIds.contains(id);

  Future<void> _loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null && raw.isNotEmpty) {
        final list = (jsonDecode(raw) as List)
            .map((e) => DestinationModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        favorites = list;
        favoriteDestinationIds = list.map((d) => d.id).toSet();
      }
    } catch (_) {}
  }

  Future<void> _saveLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode(favorites.map((d) => d.toJson()).toList()),
      );
    } catch (_) {}
  }
}
