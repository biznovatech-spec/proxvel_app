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

/// Result item. La compatibilidad/label solo existen cuando el orden IA está
/// activo y hay perfil; en búsqueda normal son null (no se inventan scores).
class SearchResultItem {
  final DestinationModel destination;
  final int? compatibility;
  final String? label; // 'Recomendado', 'Parcialmente', 'Normal'

  SearchResultItem({
    required this.destination,
    this.compatibility,
    this.label,
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

  /// Orden por recomendación IA. Apagado por defecto: la búsqueda es normal.
  bool aiSortEnabled = false;

  /// True cuando se pidió orden IA pero el usuario no tiene perfil viajero.
  /// La UI muestra un aviso para completar el perfil; los resultados se
  /// mantienen en orden normal (sin inventar scores).
  bool aiBlockedNoProfile = false;

  SearchController(this._destinationService, this._storageService);

  /// [aiSort] activa/desactiva el orden por IA.
  /// [hasProfile] indica si el usuario tiene perfil viajero (lo pasa la vista
  /// leyendo ProfileController), necesario para poder ordenar por IA.
  Future<void> search({
    SearchFilters? newFilters,
    bool? aiSort,
    bool hasProfile = false,
  }) async {
    if (newFilters != null) filters = newFilters;
    if (aiSort != null) aiSortEnabled = aiSort;
    isLoading = true;
    error = null;
    aiBlockedNoProfile = false;
    notifyListeners();

    try {
      final all = await _destinationService.getDestinations();

      // Populate filter options from real data (descarta vacíos).
      availableCities =
          all.map((d) => d.city).where((s) => s.trim().isNotEmpty).toSet().toList()
            ..sort();
      availableCategories = all
          .map((d) => d.category)
          .where((s) => s.trim().isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      availableClimates = all
          .map((d) => d.climate)
          .where((s) => s.trim().isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      // Apply text + faceted filters (sin filtros sobre datos inexistentes).
      final filtered = all.where((d) {
        if (filters.query.isNotEmpty) {
          _storageService.addRecentSearch(filters.query);
          final q = filters.query.toLowerCase();
          final matches = d.name.toLowerCase().contains(q) ||
              d.city.toLowerCase().contains(q) ||
              d.region.toLowerCase().contains(q) ||
              d.category.toLowerCase().contains(q) ||
              d.description.toLowerCase().contains(q);
          if (!matches) return false;
        }
        if (filters.city != null && d.city != filters.city) return false;
        if (filters.category != null && d.category != filters.category) {
          return false;
        }
        return true;
      }).toList();

      if (aiSortEnabled && hasProfile) {
        // ── Orden IA: enriquecer con compatibilidad real y ordenar desc. ──
        final enriched = <SearchResultItem>[];
        for (final d in filtered) {
          final compat = await _destinationService.getCompatibility(d.id);
          final label = compat >= AppConstants.compatibilityRecommended
              ? 'Recomendado'
              : compat >= AppConstants.compatibilityPartial
                  ? 'Parcialmente'
                  : 'Normal';
          enriched.add(SearchResultItem(
            destination: d,
            compatibility: compat,
            label: label,
          ));
        }
        final compatFiltered = filters.minCompatibility != null
            ? enriched
                .where((r) => (r.compatibility ?? 0) >= filters.minCompatibility!)
                .toList()
            : enriched;
        compatFiltered.sort(
            (a, b) => (b.compatibility ?? 0).compareTo(a.compatibility ?? 0));
        results = compatFiltered;
      } else {
        // ── Orden normal: alfabético. Sin scores IA inventados. ──
        if (aiSortEnabled && !hasProfile) {
          aiBlockedNoProfile = true;
        }
        filtered.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        results = filtered
            .map((d) => SearchResultItem(destination: d))
            .toList();
      }
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
    }

    isLoading = false;
    notifyListeners();
  }

  void clearFilters() {
    filters = SearchFilters(query: filters.query);
    search(aiSort: aiSortEnabled);
  }
}
