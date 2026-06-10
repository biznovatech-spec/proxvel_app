import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../integration/services/destination_service.dart';
import '../integration/local/local_storage_service.dart';

class FavoritesController extends ChangeNotifier {
  final LocalStorageService _storage;
  final DestinationService _destinationService;
  bool isLoading = false;
  List<DestinationModel> favorites = [];
  String? error;

  FavoritesController(this._storage, this._destinationService);

  Future<void> loadFavorites() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final allIds = _storage.getFavorites();
      final allDests = await _destinationService.getDestinations();
      favorites = allDests.where((d) => allIds.contains(d.id)).toList();
      // Resolver favoritos del backend (slugs) que no están en el catálogo local
      final foundIds = favorites.map((d) => d.id).toSet();
      for (final id in allIds.where((id) => !foundIds.contains(id))) {
        final dest = await _destinationService.getDestinationById(id);
        if (dest != null) favorites.add(dest);
      }
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final allIds = _storage.getFavorites();
    if (allIds.contains(id)) {
      await _storage.removeFavorite(id);
    } else {
      await _storage.addFavorite(id);
    }
    await loadFavorites();
  }
  
  bool isFavorite(String id) {
    return _storage.getFavorites().contains(id);
  }
}
