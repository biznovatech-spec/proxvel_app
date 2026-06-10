import 'package:flutter/foundation.dart';
import '../../models/recommendation_result_model.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../mock/mock_recommendation_data_source.dart';

/// Servicio de recomendaciones: API-first con fallback a mock.
/// El ranking contextual proviene de las Fases 3+4 de la tesis
/// (WSM + re-ranking clima/aforo) servido por el backend FastAPI.
class RecommendationService {
  final ApiClient? _api;
  RecommendationService({ApiClient? apiClient}) : _api = apiClient;

  Future<List<RecommendationResultModel>> getRecommendations({
    String? userId,
    int limit = 10,
  }) async {
    if (_api != null) {
      try {
        final json = await _api.get(
          '/recommendations/contextual',
          queryParams: {
            'user_id': userId ?? ApiConfig.demoUserId,
            'limit': '$limit',
          },
        );
        final items = json['data'] as List? ?? [];
        if (items.isNotEmpty) {
          return items
              .whereType<Map<String, dynamic>>()
              .map(RecommendationResultModel.fromApiJson)
              .toList();
        }
      } catch (e) {
        debugPrint('[RecommendationService] API falló, usando mock: $e');
      }
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return MockRecommendationDataSource.getRecommendations();
  }
}
