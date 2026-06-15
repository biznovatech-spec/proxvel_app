import 'package:flutter/foundation.dart';
import '../../models/destination_model.dart';
import '../../models/aspect_score_model.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../mock/mock_destination_data_source.dart';
import '../mock/mock_aspect_data_source.dart';

/// Servicio de destinos: API-first con fallback a mock.
///
/// - El detalle (aspectos ABSA, clima, aforo) viene de GET /destinations/{id}
///   con el mes actual, reflejando los resultados de los notebooks.
/// - La explicación y compatibilidad vienen del ranking contextual del
///   usuario demo (GET /recommendations/contextual).
/// - El catálogo de exploración (home/trending) se mantiene con mocks.
class DestinationService {
  final ApiClient? _api;
  DestinationService({ApiClient? apiClient}) : _api = apiClient;

  /// Etiquetas en español para los aspectos ABSA del backend.
  static const Map<String, String> _aspectLabels = {
    'atractivos': 'Atractivos turísticos',
    'costos': 'Costos',
    'seguridad': 'Seguridad',
    'accesibilidad': 'Accesibilidad',
    'limpieza': 'Limpieza',
    'atencion_servicio': 'Atención y servicio',
    'gastronomia': 'Gastronomía',
    'alojamiento': 'Alojamiento',
    'clima': 'Clima',
    'aforo_multitudes': 'Aforo / multitudes',
  };

  // Caches en memoria para evitar llamadas duplicadas por pantalla.
  final Map<String, Map<String, dynamic>> _detailCache = {};
  Map<String, Map<String, dynamic>>? _rankingByDestination;

  Future<List<DestinationModel>> getDestinations() async {
    if (_api != null) {
      try {
        final json = await _api.get('/destinations');
        final items = json['data'] as List? ?? [];

        final parsedList = items
            .whereType<Map<String, dynamic>>()
            .map((item) => DestinationModel.fromApiCatalog(item))
            .toList();

        if (parsedList.isNotEmpty) {
          return parsedList;
        }
      } catch (e) {
        debugPrint(
          '[DestinationService] Falló getDestinations API, usando fallback: $e',
        );
        if (!ApiConfig.useMockFallback) rethrow;
      }
    }

    if (ApiConfig.useMockFallback) {
      debugPrint(
        '[DestinationService] Backend no disponible, usando MockDestinationDataSource como fallback.',
      );
      return MockDestinationDataSource.activeDestinations;
    }
    return [];
  }

  Future<List<DestinationModel>> getRecentSearches() async {
    if (ApiConfig.useMockFallback) {
      await Future.delayed(const Duration(milliseconds: 200));
      return MockDestinationDataSource.recentSearches;
    }
    return [];
  }

  /// Detalle de un destino. API-first (slug del backend), fallback mock.
  Future<DestinationModel?> getDestinationById(String id) async {
    try {
      final detail = await _fetchDetail(id);
      if (detail != null) {
        final dest = DestinationModel.fromApiDetail(detail);
        return dest;
      }
    } catch (e) {
      if (!ApiConfig.useMockFallback) rethrow;
    }
    
    if (ApiConfig.useMockFallback) {
      // Fallback: buscar en mocks por id (slug)
      try {
        return MockDestinationDataSource.destinations.firstWhere(
          (d) => d.id == id,
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Scores ABSA por aspecto (matriz normalizada de la Fase 2 / notebooks).
  Future<List<AspectScoreModel>> getAspectScores(String destinationId) async {
    try {
      final detail = await _fetchDetail(destinationId);
      final aspectMap = detail?['aspect_scores'] as Map<String, dynamic>?;
      if (aspectMap != null) {
        final scores = <AspectScoreModel>[];
        _aspectLabels.forEach((key, label) {
          final value = aspectMap[key];
          if (value is num) {
            scores.add(AspectScoreModel(aspect: label, score: value.toDouble()));
          }
        });
        if (scores.isNotEmpty) return scores;
      }
    } catch (e) {
      if (!ApiConfig.useMockFallback) rethrow;
    }
    
    if (ApiConfig.useMockFallback) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockAspectDataSource.getAspectScores(destinationId);
    }
    return [];
  }

  /// Explicación del ranking contextual (explicacion_final de la Fase 4).
  Future<String> getExplanation(String destinationId) async {
    try {
      final entry = await _rankingEntry(destinationId);
      final explanation = entry?['short_explanation'];
      if (explanation is String && explanation.isNotEmpty) return explanation;
    } catch (e) {
      if (!ApiConfig.useMockFallback) rethrow;
    }
    
    if (ApiConfig.useMockFallback) {
      await Future.delayed(const Duration(milliseconds: 200));
      return MockAspectDataSource.getExplanation(destinationId);
    }
    return 'Aún no hay explicación personalizada disponible para este destino.';
  }

  /// Compatibilidad contextual (% de la Fase 4).
  Future<int> getCompatibility(String destinationId) async {
    try {
      final entry = await _rankingEntry(destinationId);
      final compat = entry?['compatibility_percentage'];
      if (compat is num) return compat.round();
    } catch (e) {
      if (!ApiConfig.useMockFallback) rethrow;
    }
    
    if (ApiConfig.useMockFallback) {
      await Future.delayed(const Duration(milliseconds: 100));
      return MockAspectDataSource.getCompatibility(destinationId);
    }
    return 0;
  }

  // ── Internos ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _fetchDetail(String destinationId) async {
    if (_api == null) return null;
    if (_detailCache.containsKey(destinationId)) {
      return _detailCache[destinationId];
    }
    final json = await _api.get(
      '/destinations/$destinationId',
      queryParams: {'month': '${DateTime.now().month}'},
    );
    final data = json['data'] as Map<String, dynamic>?;
    if (data != null) {
      _detailCache[destinationId] = data;
      return data;
    }
    return null;
  }

  Future<Map<String, dynamic>?> _rankingEntry(String destinationId) async {
    if (_api == null) return null;
    if (_rankingByDestination == null) {
      final json = await _api.get(
        '/recommendations/me',
        queryParams: {'limit': '20'},
      );
      final items = json['data'] as List? ?? [];
      _rankingByDestination = {
        for (final item in items.whereType<Map<String, dynamic>>())
          (item['destination_id'] ?? '') as String: item,
      };
    }
    return _rankingByDestination?[destinationId];
  }
}
