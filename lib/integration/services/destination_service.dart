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
  // _detailCache: clave "id|mes". _rankingByMonth: clave = mes (0 = actual).
  final Map<String, Map<String, dynamic>> _detailCache = {};
  final Map<int, Map<String, Map<String, dynamic>>> _rankingByMonth = {};

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
  Future<DestinationModel?> getDestinationById(String id, {int? month}) async {
    try {
      final detail = await _fetchDetail(id, month: month);
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
  Future<List<AspectScoreModel>> getAspectScores(String destinationId, {int? month}) async {
    try {
      final detail = await _fetchDetail(destinationId, month: month);
      final aspectMap = detail?['aspect_scores'] as Map<String, dynamic>?;
      if (aspectMap != null) {
        final scores = <AspectScoreModel>[];
        _aspectLabels.forEach((key, label) {
          // clima y aforo_multitudes NO son aspectos ABSA de reseñas: son señales
          // contextuales (Fase 4, datos reales del mes). Se excluyen de la lista
          // ABSA y se muestran aparte vía getDestinationContext().
          if (key == 'clima' || key == 'aforo_multitudes') return;
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
  Future<String> getExplanation(String destinationId, {int? month}) async {
    try {
      final entry = await _rankingEntry(destinationId, month: month);
      // El motor V1 manda explanation.summary; se usa eso (con respaldos).
      final exp = entry?['explanation'];
      if (exp is Map && exp['summary'] is String && (exp['summary'] as String).isNotEmpty) {
        return exp['summary'] as String;
      }
      final short = entry?['short_explanation'];
      if (short is String && short.isNotEmpty) return short;
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
  Future<int> getCompatibility(String destinationId, {int? month}) async {
    try {
      final entry = await _rankingEntry(destinationId, month: month);
      // El motor V1 manda compatibility_percent (con respaldo al nombre largo).
      final compat = entry?['compatibility_percent'] ?? entry?['compatibility_percentage'];
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

  /// Contexto REAL del mes (clima + aforo), NO de reseñas. Viene de
  /// GET /destinations/{id}?month= en `context` / `weather_detail`.
  /// Devuelve scores 0-1 (alto = mejor) y etiquetas legibles.
  Future<Map<String, dynamic>> getDestinationContext(String destinationId, {int? month}) async {
    try {
      final detail = await _fetchDetail(destinationId, month: month);
      final ctx = detail?['context'] as Map<String, dynamic>?;
      final wd = detail?['weather_detail'] as Map<String, dynamic>?;
      if (ctx != null) {
        return {
          'clima_score': (ctx['weather_score'] as num?)?.toDouble(),
          'clima_label': ctx['weather_category'] as String?,
          'aforo_score': (ctx['crowd_score'] as num?)?.toDouble(),
          'aforo_label': ctx['crowd_level'] as String?,
          'month_name': wd?['month_name'] as String?,
        };
      }
    } catch (e) {
      if (!ApiConfig.useMockFallback) rethrow;
    }
    return {};
  }

  // ── Internos ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _fetchDetail(String destinationId, {int? month}) async {
    if (_api == null) return null;
    final mes = month ?? DateTime.now().month;
    final cacheKey = '$destinationId|$mes';
    if (_detailCache.containsKey(cacheKey)) {
      return _detailCache[cacheKey];
    }
    final json = await _api.get(
      '/destinations/$destinationId',
      queryParams: {'month': '$mes'},
    );
    final data = json['data'] as Map<String, dynamic>?;
    if (data != null) {
      _detailCache[cacheKey] = data;
      return data;
    }
    return null;
  }

  Future<Map<String, dynamic>?> _rankingEntry(String destinationId, {int? month}) async {
    if (_api == null) return null;
    final mes = month ?? 0; // 0 = mes actual (lo decide el backend)
    if (!_rankingByMonth.containsKey(mes)) {
      final json = await _api.get(
        '/recommendations/me',
        queryParams: {'limit': '20', if (month != null) 'month': '$month'},
      );
      final items = json['data'] as List? ?? [];
      _rankingByMonth[mes] = {
        for (final item in items.whereType<Map<String, dynamic>>())
          (item['destination_id'] ?? '') as String: item,
      };
    }
    return _rankingByMonth[mes]?[destinationId];
  }
}
