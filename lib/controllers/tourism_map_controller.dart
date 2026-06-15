import 'package:flutter/foundation.dart';
import '../models/map_marker_model.dart';
import '../integration/services/tourism_map_service.dart';

class TourismMapController extends ChangeNotifier {
  final TourismMapService _mapService;

  TourismMapController(this._mapService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<MapMarkerModel> _markers = [];
  List<MapMarkerModel> get markers => _markers;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  List<String> get availableCategories {
    final categories = _markers.map((m) => m.category).whereType<String>().toSet().toList();
    categories.sort();
    return categories;
  }

  List<MapMarkerModel> get filteredMarkers {
    if (_selectedCategory == null) {
      return _markers;
    }
    return _markers.where((m) => m.category == _selectedCategory).toList();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadMarkers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _markers = await _mapService.getMapMarkers();
    } catch (e) {
      _errorMessage = e.toString();
      _markers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
