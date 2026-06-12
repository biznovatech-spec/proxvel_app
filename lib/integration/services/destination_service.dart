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
    await Future.delayed(const Duration(milliseconds: 500));
    // Solo los destinos cubiertos por la tesis (Fases 2-4)
    return MockDestinationDataSource.activeDestinations;
  }

  Future<List<DestinationModel>> getRecentSearches() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockDestinationDataSource.recentSearches;
  }

  /// Detalle de un destino. API-first (slug del backend), fallback mock.
  Future<DestinationModel?> getDestinationById(String id) async {
    final detail = await _fetchDetail(id);
    if (detail != null) {
      final dest = DestinationModel.fromApiDetail(detail);
      // El catálogo del backend no trae cover separado: usa galería o
      // conserva el asset local si el destino también existe en mocks.
      if (dest.imageUrl.isEmpty) {
        final mock = _findMockByName(dest.name);
        if (mock != null) {
          return DestinationModel.fromApiDetail(detail).copyWithImage(
            mock.imageUrl,
            mock.galleryImages,
          );
        }
      }
      return dest;
    }
    // Fallback: buscar en mocks por id (slug)
    try {
      return MockDestinationDataSource.destinations.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Scores ABSA por aspecto (matriz normalizada de la Fase 2 / notebooks).
  Future<List<AspectScoreModel>> getAspectScores(String destinationId) async {
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
    await Future.delayed(const Duration(milliseconds: 300));
    return MockAspectDataSource.getAspectScores(destinationId);
  }

  /// Explicación del ranking contextual (explicacion_final de la Fase 4).
  Future<String> getExplanation(String destinationId) async {
    final entry = await _rankingEntry(destinationId);
    final explanation = entry?['short_explanation'];
    if (explanation is String && explanation.isNotEmpty) return explanation;
    await Future.delayed(const Duration(milliseconds: 200));
    return MockAspectDataSource.getExplanation(destinationId);
  }

  /// Compatibilidad contextual (% de la Fase 4) para el usuario demo.
  Future<int> getCompatibility(String destinationId) async {
    final entry = await _rankingEntry(destinationId);
    final compat = entry?['compatibility_percentage'];
    if (compat is num) return compat.round();
    await Future.delayed(const Duration(milliseconds: 100));
    return MockAspectDataSource.getCompatibility(destinationId);
  }

  // ── Internos ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _fetchDetail(String destinationId) async {
    if (_api == null) return null;
    if (_detailCache.containsKey(destinationId)) {
      return _detailCache[destinationId];
    }
    try {
      final json = await _api.get(
        '/destinations/$destinationId',
        queryParams: {'month': '${DateTime.now().month}'},
      );
      final data = json['data'] as Map<String, dynamic>?;
      if (data != null) {
        _detailCache[destinationId] = data;
        return data;
      }
    } catch (e) {
      debugPrint('[DestinationService] detalle API falló ($destinationId): $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _rankingEntry(String destinationId) async {
    if (_api == null) return null;
    if (_rankingByDestination == null) {
      try {
        final json = await _api.get(
          '/recommendations/contextual',
          queryParams: {'user_id': ApiConfig.demoUserId, 'limit': '10'},
        );
        final items = json['data'] as List? ?? [];
        _rankingByDestination = {
          for (final item in items.whereType<Map<String, dynamic>>())
            (item['destination_id'] ?? '') as String: item,
        };
      } catch (e) {
        debugPrint('[DestinationService] ranking API falló: $e');
        return null;
      }
    }
    return _rankingByDestination?[destinationId];
  }

  DestinationModel? _findMockByName(String name) {
    final lower = name.toLowerCase();
    for (final d in MockDestinationDataSource.destinations) {
      if (d.name.toLowerCase() == lower) return d;
    }
    return null;
  }
}
