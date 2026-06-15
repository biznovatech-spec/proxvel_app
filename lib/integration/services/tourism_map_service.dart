import 'package:flutter/foundation.dart';
import '../../models/map_marker_model.dart';
import '../api/api_client.dart';

class TourismMapService {
  final ApiClient? _api;

  TourismMapService({ApiClient? apiClient}) : _api = apiClient;

  Future<List<MapMarkerModel>> getMapMarkers() async {
    if (_api == null) {
      debugPrint('[TourismMapService] ApiClient is null, returning empty markers');
      return [];
    }

    try {
      final response = await _api.get('/tourism/map-markers');
      final dataList = response['data'] as List<dynamic>?;
      
      if (dataList != null) {
        return dataList
            .map((e) => MapMarkerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[TourismMapService] Error fetching map markers: $e');
      throw Exception('Failed to load map markers.');
    }
  }
}
