import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../integration/services/favorites_service.dart';

class FavoritesController extends ChangeNotifier {
  final FavoritesService _favoritesService;
  
  bool isLoading = false;
  List<DestinationModel> favorites = [];
  Set<String> favoriteDestinationIds = {};
  String? error;

  FavoritesController(this._favoritesService);

  Future<void> loadFavorites() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final favModels = await _favoritesService.getFavorites();
      favorites = favModels.map((f) => DestinationModel.fromFavoriteModel(f)).toList();
      favoriteDestinationIds = favorites.map((d) => d.id).toSet();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final isFav = isFavorite(id);
    
    // Optimistic UI update
    if (isFav) {
      favoriteDestinationIds.remove(id);
      favorites.removeWhere((d) => d.id == id);
    } else {
      favoriteDestinationIds.add(id);
    }
    notifyListeners();

    try {
      if (isFav) {
        await _favoritesService.removeFavorite(id);
      } else {
        await _favoritesService.addFavorite(id);
        // We added a new favorite, but we don't have the full model in the list yet.
        // We should reload to get the model with images and data.
        await loadFavorites();
      }
    } catch (e) {
      // Revert optimistic update on failure
      if (isFav) {
        favoriteDestinationIds.add(id);
      } else {
        favoriteDestinationIds.remove(id);
      }
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  bool isFavorite(String id) {
    return favoriteDestinationIds.contains(id);
  }
}

