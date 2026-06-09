import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../integration/services/destination_service.dart';
import '../integration/local/local_storage_service.dart';

class HomeController extends ChangeNotifier {
  final DestinationService _service = DestinationService();
  final LocalStorageService _storageService = LocalStorageService();

  bool isLoading = false;
  String currentLocation = 'Lima';
  List<DestinationModel> destinations = [];
  List<DestinationModel> recentSearches = [];

  /// Destinations marked as trending for the hero carousel.
  List<DestinationModel> get trendingDestinations =>
      destinations.where((d) => d.isTrending).toList();

  /// Destinations with a known distance, sorted nearest first.
  List<DestinationModel> get nearbyDestinations {
    var list = destinations.where((d) => d.distanceKm != null).toList();
    final cityMatches = list
        .where((d) => d.city == currentLocation || d.region == currentLocation)
        .toList();
    if (cityMatches.isNotEmpty) {
      list = cityMatches;
    }
    list.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
    return list;
  }

  /// Destinations with estimated travel time (getaway cards).
  List<DestinationModel> get getawayDestinations =>
      destinations.where((d) => d.estimatedDays != null).toList();

  Future<void> loadDestinations() async {
    isLoading = true;
    notifyListeners();
    destinations = await _service.getDestinations();

    // Load recent searches from LocalStorageService
    await _storageService.init(); // Ensure initialized
    final recentNames = _storageService.getRecentSearches();

    final loadedRecents = <DestinationModel>[];
    for (final name in recentNames) {
      try {
        final match = destinations.firstWhere((d) => d.name == name);
        loadedRecents.add(match);
      } catch (_) {}
    }
    recentSearches = loadedRecents;
    isLoading = false;
    notifyListeners();
  }

  void changeLocation(String newCity) {
    if (currentLocation != newCity) {
      currentLocation = newCity;
      notifyListeners();
    }
  }
}
