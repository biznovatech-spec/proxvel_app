import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../core/constants/app_constants.dart';
import '../integration/services/destination_service.dart';
import '../integration/local/local_storage_service.dart';

/// Search filter criteria.
class SearchFilters {
  final String query;
  final String? city;
  final String? category;
  final String? climate;
  final double? maxBudget;
  final int? minCompatibility;

  const SearchFilters({
    this.query = '',
    this.city,
    this.category,
    this.climate,
    this.maxBudget,
    this.minCompatibility,
  });

  bool get hasActiveFilters =>
      city != null ||
      category != null ||
      climate != null ||
      maxBudget != null ||
      minCompatibility != null;

  int get activeFilterCount {
    int count = 0;
    if (city != null) count++;
    if (category != null) count++;
    if (climate != null) count++;
    if (maxBudget != null) count++;
    if (minCompatibility != null) count++;
    return count;
  }

  SearchFilters copyWith({
    String? query,
    String? city,
    String? category,
    String? climate,
    double? maxBudget,
    int? minCompatibility,
    bool clearCity = false,
    bool clearCategory = false,
    bool clearClimate = false,
    bool clearBudget = false,
    bool clearCompatibility = false,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      city: clearCity ? null : (city ?? this.city),
      category: clearCategory ? null : (category ?? this.category),
      climate: clearClimate ? null : (climate ?? this.climate),
      maxBudget: clearBudget ? null : (maxBudget ?? this.maxBudget),
      minCompatibility: clearCompatibility
          ? null
          : (minCompatibility ?? this.minCompatibility),
    );
  }
}

/// Result item enriched with compatibility score and label.
class SearchResultItem {
  final DestinationModel destination;
  final int compatibility;
  final String label; // 'Recomendado', 'Parcialmente', 'Normal'

  SearchResultItem({
    required this.destination,
    required this.compatibility,
    required this.label,
  });
}

class SearchController extends ChangeNotifier {
  final DestinationService _destinationService;
  final LocalStorageService _storageService;
  bool isLoading = false;
  List<SearchResultItem> results = [];
  SearchFilters filters = const SearchFilters();
  String? error;

  // Unique values for filter options (populated from data)
  List<String> availableCities = [];
  List<String> availableCategories = [];
  List<String> availableClimates = [];

  SearchController(this._destinationService, this._storageService);

  Future<void> search({SearchFilters? newFilters}) async {
    if (newFilters != null) filters = newFilters;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final all = await _destinationService.getDestinations();

      // Populate filter options from data
      availableCities = all.map((d) => d.city).toSet().toList()..sort();
      availableCategories = all.map((d) => d.category).toSet().toList()..sort();
      availableClimates = all.map((d) => d.climate).toSet().toList()..sort();

      // Apply filters
      var filtered = all.where((d) {
        // Text query
        if (filters.query.isNotEmpty) {
          // If searching by text, save it as a recent search
          _storageService.addRecentSearch(filters.query);
          
          final q = filters.query.toLowerCase();
          final matches = d.name.toLowerCase().contains(q) ||
              d.city.toLowerCase().contains(q) ||
              d.region.toLowerCase().contains(q) ||
              d.category.toLowerCase().contains(q) ||
              d.description.toLowerCase().contains(q);
          if (!matches) return false;
        }
        // City
        if (filters.city != null && d.city != filters.city) return false;
        // Category
        if (filters.category != null && d.category != filters.category) {
          return false;
        }
        // Climate
        if (filters.climate != null && d.climate != filters.climate) {
          return false;
        }
        // Budget
        if (filters.maxBudget != null && d.averageCost > filters.maxBudget!) {
          return false;
        }
        return true;
      }).toList();

      // Enrich with compatibility and classify
      final enriched = <SearchResultItem>[];
      for (final d in filtered) {
        final compat = await _destinationService.getCompatibility(d.id);
        String label;
        if (compat >= AppConstants.compatibilityRecommended) {
          label = 'Recomendado';
        } else if (compat >= AppConstants.compatibilityPartial) {
          label = 'Parcialmente';
        } else {
          label = 'Normal';
        }
        enriched.add(SearchResultItem(
          destination: d,
          compatibility: compat,
          label: label,
        ));
      }

      // Filter by min compatibility if set
      final compatFiltered = filters.minCompatibility != null
          ? enriched
              .where((r) => r.compatibility >= filters.minCompatibility!)
              .toList()
          : enriched;

      // Sort: highest compatibility first
      compatFiltered.sort((a, b) => b.compatibility.compareTo(a.compatibility));

      results = compatFiltered;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  void clearFilters() {
    filters = SearchFilters(query: filters.query);
    search();
  }
}
